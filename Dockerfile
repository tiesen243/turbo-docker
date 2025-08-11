FROM oven/bun:latest AS base

# ===========================
# Turborepo setup stage
# ===========================
FROM base AS setup
WORKDIR /repo
# Install Turbo CLI globally to manage the monorepo build
RUN bun add --global turbo
# Copy all project files into the container
COPY . .
# Prune dependencies to include only what's required for the Next.js app
# This significantly reduces build context and improves build speed
RUN turbo prune @turbo-docker/nextjs --docker

# ===========================
# Builder stage
# ===========================
FROM base AS builder
WORKDIR /build
# Copy pruned output from the install stage (includes only necessary files)
COPY --from=setup /repo/out/full .
# Install dependencies
RUN bun install
# Build the Next.js app with Turbo (including its dependencies)
# -F flag filters by package name
RUN bun run build -F @turbo-docker/nextjs... --ui stream

# ===========================
# Runner stage
# ===========================
FROM base AS runner
WORKDIR /app

# Copy dependencies from the builder stage (node_modules)
COPY --from=builder /build/node_modules ./node_modules

# Set environment to production for optimized runtime behavior
ENV NODE_ENV=production

# Create non-root user/group for better security
RUN addgroup --system --gid 1001 bunjs
RUN adduser --system --uid 1001 nextjs

# Copy public assets (images, fonts, etc.)
COPY --from=builder /build/apps/nextjs/public ./public

# Copy standalone Next.js server build (optimized minimal output)
COPY --from=builder --chown=nextjs:bunjs /build/apps/nextjs/.next/standalone/apps/nextjs .

# Copy static assets for Next.js (JS/CSS chunks, etc.)
COPY --from=builder --chown=nextjs:bunjs /build/apps/nextjs/.next/static ./.next/static

# Switch to non-root user for security
USER nextjs

# Expose the app port
EXPOSE 3000

# Set default port and hostname environment variables
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Start the Next.js standalone server using Bun
# server.js is created by Next.js build output
# https://nextjs.org/docs/pages/api-reference/config/next-config-js/output
CMD ["bun", "server.js"]
