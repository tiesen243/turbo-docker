import baseConfig from '@turbo-docker/eslint-config/base'
import reactConfig from '@turbo-docker/eslint-config/react'

/** @type {import('typescript-eslint').Config} */
export default [
  {
    ignores: ['dist/**'],
  },
  ...baseConfig,
  ...reactConfig,
]
