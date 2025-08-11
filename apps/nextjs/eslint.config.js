import baseConfig, { restrictEnvAccess } from '@turbo-docker/eslint-config/base'
import nextConfig from '@turbo-docker/eslint-config/next'
import reactConfig from '@turbo-docker/eslint-config/react'

/** @type {import('typescript-eslint').Config} */
export default [
  {
    ignores: ['.next/**'],
  },
  ...baseConfig,
  ...reactConfig,
  ...nextConfig,
  ...restrictEnvAccess,
]
