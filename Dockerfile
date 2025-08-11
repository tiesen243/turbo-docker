FROM oven/bun:latest AS base

# ===========================
# Turborepo setup stage
# ===========================
FROM base AS install
WORKDIR /repo
# Install Turbo CLI globally to manage the monorepo build
RUN bun add --global turbo
# Copy all project files into the container
COPY . .
# Prune to include only dependencies for the Next.js app
RUN turbo prune @turbo-docker/nextjs --docker

# ===========================
# Build stage
# ===========================
FROM base AS build
WORKDIR /build
# Copy pruned output from the install stage
COPY --from=install /repo/out/full .
# Install only production dependencies
RUN bun install
# Build the Next.js app with Turbo (including its dependencies)
# -F flag filters by package name
# --ui stream provides live build output
RUN bun run build -F @turbo-docker/nextjs... --ui stream

# ===========================
# Final runtime image
# ===========================
FROM base AS final
WORKDIR /app
# Copy installed dependencies from the build stage
COPY --from=build /build/node_modules ./node_modules


ENV NODE_ENV=production

RUN addgroup --system --gid 1001 bun
RUN adduser --system --uid 1001 nextjs

# Copy the standalone Next.js build output
COPY --from=build --chown=nextjs:bun /build/apps/nextjs/.next/standalone/apps/nextjs .
# Copy Next.js static files
COPY --from=build --chown=nextjs:bun /build/apps/nextjs/.next/static ./.next/static
# Copy the public assets
COPY --from=build /build/apps/nextjs/public ./public

USER nextjs

EXPOSE 3000

ENV PORT=3000

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/config/next-config-js/output
ENV HOSTNAME="0.0.0.0"
# Start the Next.js standalone server using Bun
CMD ["bun", "server.js"]
