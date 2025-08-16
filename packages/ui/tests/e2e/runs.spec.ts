import { test, expect } from '@playwright/test';

test.describe('Runs Page', () => {
  test('should display runs page in English', async ({ page }) => {
    await page.goto('/en/runs');
    
    // Check page title
    await expect(page.locator('h1')).toContainText('Task Runs');
    
    // Check active runs section
    await expect(page.locator('h3')).toContainText('Active Runs');
    
    // Check sample run
    await expect(page.locator('h4')).toContainText('Run #1');
    await expect(page.locator('text=Plan: 1')).toBeVisible();
    await expect(page.locator('text=Status: running')).toBeVisible();
    await expect(page.locator('text=Progress: 60%')).toBeVisible();
    await expect(page.locator('text=Tasks: 2/3')).toBeVisible();
    
    // Check progress bar
    await expect(page.locator('div[style*="width: 60%"]')).toBeVisible();
  });

  test('should display runs page in French', async ({ page }) => {
    await page.goto('/fr/runs');
    
    // Check page title
    await expect(page.locator('h1')).toContainText('Exécutions de Tâches');
    
    // Check active runs section
    await expect(page.locator('h3')).toContainText('Exécutions Actives');
    
    // Check sample run
    await expect(page.locator('h4')).toContainText('Exécution #1');
    await expect(page.locator('text=Plan: 1')).toBeVisible();
    await expect(page.locator('text=Statut: running')).toBeVisible();
    await expect(page.locator('text=Progression: 60%')).toBeVisible();
    await expect(page.locator('text=Tâches: 2/3')).toBeVisible();
  });

  test('should navigate between pages', async ({ page }) => {
    // Start on runs page
    await page.goto('/en/runs');
    await expect(page.locator('h1')).toContainText('Task Runs');
    
    // Navigate to plans page
    await page.click('a:has-text("Plans")');
    await expect(page.locator('h1')).toContainText('Plans');
    
    // Navigate back to runs page
    await page.click('a:has-text("Runs")');
    await expect(page.locator('h1')).toContainText('Task Runs');
  });

  test('should maintain language preference across navigation', async ({ page }) => {
    // Start on French runs page
    await page.goto('/fr/runs');
    await expect(page.locator('h1')).toContainText('Exécutions de Tâches');
    
    // Navigate to French plans page
    await page.click('a:has-text("Plans")');
    await expect(page.locator('h1')).toContainText('Plans');
    await expect(page.locator('h3')).toContainText('Créer un Nouveau Plan');
    
    // Navigate back to French runs page
    await page.click('a:has-text("Exécutions")');
    await expect(page.locator('h1')).toContainText('Exécutions de Tâches');
  });
});
