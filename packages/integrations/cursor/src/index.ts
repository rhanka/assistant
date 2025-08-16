import { chromium } from '@playwright/test';

export async function openAgentsPage() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('https://cursor.com/agents');
  await page.waitForLoadState('domcontentloaded');
  console.log('Cursor Agents page opened. Complete login manually if needed.');
  // Keep browser open for manual actions
}
