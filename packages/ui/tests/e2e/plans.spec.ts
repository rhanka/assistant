import { test, expect } from '@playwright/test';

test.describe('Plans Page', () => {
  test('should display plans page in English', async ({ page }) => {
    await page.goto('/en/plans');
    
    // Check page title
    await expect(page.locator('h1')).toContainText('Plans');
    
    // Check create plan form
    await expect(page.locator('h3')).toContainText('Create New Plan');
    await expect(page.locator('input[placeholder="Enter plan title..."]')).toBeVisible();
    await expect(page.locator('button')).toContainText('Create');
    
    // Check sample plan
    await expect(page.locator('h4')).toContainText('Sample Plan');
    await expect(page.locator('text=Status: active')).toBeVisible();
    await expect(page.locator('text=Tasks: 3')).toBeVisible();
  });

  test('should display plans page in French', async ({ page }) => {
    await page.goto('/fr/plans');
    
    // Check page title
    await expect(page.locator('h1')).toContainText('Plans');
    
    // Check create plan form
    await expect(page.locator('h3')).toContainText('Créer un Nouveau Plan');
    await expect(page.locator('input[placeholder="Entrez le titre du plan..."]')).toBeVisible();
    await expect(page.locator('button')).toContainText('Créer');
    
    // Check sample plan
    await expect(page.locator('h4')).toContainText('Sample Plan');
    await expect(page.locator('text=Statut: active')).toBeVisible();
    await expect(page.locator('text=Tâches: 3')).toBeVisible();
  });

  test('should create a new plan', async ({ page }) => {
    await page.goto('/en/plans');
    
    const newPlanTitle = 'Test Plan ' + Date.now();
    
    // Fill in the form
    await page.fill('input[placeholder="Enter plan title..."]', newPlanTitle);
    await page.click('button:has-text("Create")');
    
    // Check that the new plan appears
    await expect(page.locator(`text=${newPlanTitle}`)).toBeVisible();
    await expect(page.locator('text=Status: draft')).toBeVisible();
    await expect(page.locator('text=Tasks: 0')).toBeVisible();
  });

  test('should switch language and maintain navigation', async ({ page }) => {
    await page.goto('/en/plans');
    
    // Check we're on English plans page
    await expect(page.locator('h1')).toContainText('Plans');
    
    // Switch to French
    await page.click('a:has-text("Français")');
    
    // Should be on French plans page
    await expect(page.locator('h1')).toContainText('Plans');
    await expect(page.locator('h3')).toContainText('Créer un Nouveau Plan');
    
    // Switch back to English
    await page.click('a:has-text("English")');
    
    // Should be back on English plans page
    await expect(page.locator('h1')).toContainText('Plans');
    await expect(page.locator('h3')).toContainText('Create New Plan');
  });
});
