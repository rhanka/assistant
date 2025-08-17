import { defineConfig } from 'vitest/config'
import { sveltekit } from '@sveltejs/vite-plugin-svelte'

export default defineConfig({
  plugins: [sveltekit()],
  test: {
    include: ['src/**/*.{test,spec}.{js,ts}'],
    exclude: ['node_modules', 'build'],
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test-setup.ts'],
    run: true,
    watch: false,
  },
})
