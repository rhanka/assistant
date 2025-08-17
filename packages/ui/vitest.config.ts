import { defineConfig } from 'vitest/config'
import { sveltekit } from '@sveltejs/kit/vite'

export default defineConfig({
  plugins: [sveltekit()],
  test: {
    include: ['src/**/*.{test,spec}.{js,ts}'],
    exclude: ['node_modules', 'build', 'tests/**/*'],
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test-setup.ts'],
    run: true,
    watch: false,
  },
})
