import { test, expect } from '@playwright/test';

test('homepage loads successfully', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('h1')).toHaveText('DevOps Assignment');
});

test('backend connection status is shown', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('text=Backend is connected!')).toBeVisible();
});



