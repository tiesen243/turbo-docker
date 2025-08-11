import '@turbo-docker/validators/env'

import type { NextConfig } from 'next'

const nextConfig = {
  reactStrictMode: true,
  output: 'standalone',

  typescript: { ignoreBuildErrors: true },
  eslint: { ignoreDuringBuilds: true },

  transpilePackages: [
    '@turbo-docker/api',
    '@turbo-docker/auth',
    '@turbo-docker/db',
    '@turbo-docker/ui',
    '@turbo-docker/validators',
  ],
} satisfies NextConfig

export default nextConfig
