const { test, expect } = require('@playwright/test');

test('homepage loads', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await expect(page).toHaveTitle(/DevOps Assignment/);
});

test('backend message is visible', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await expect(
    page.locator('text=Backend Message')
  ).toBeVisible();
});

