import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    include: ['src/**/*.{test,spec}.ts'],
    exclude: ['node_modules', 'dist'],
    run: true,
    watch: false,
    setupFiles: ['./src/test-setup.ts'],
  },
  resolve: {
    alias: {
      '@nestjs/testing': '@nestjs/testing',
    },
  },
})
