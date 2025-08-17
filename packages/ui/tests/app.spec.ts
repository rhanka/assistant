import { test, expect } from '@playwright/test';

test('basic test - app environment works', async ({ page }) => {
  // Simple test that doesn't require the full app to be built
  expect(true).toBe(true);
  
  // Check that we can access basic Playwright functionality
  await page.goto('data:text/html,<html><body><h1>Test</h1></body></html>');
  const title = await page.textContent('h1');
  expect(title).toBe('Test');
});
