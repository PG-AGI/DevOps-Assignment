import { test, expect } from '@playwright/test';

const baseURL = process.env.NEXT_PUBLIC_E2E_URL || 'http://localhost:3000';

test.describe('Frontend E2E', () => {
  test('shows backend status as connected', async ({ page }: { page: any }) => {
    await page.goto(baseURL);
    await expect(page.locator('.status')).toContainText('connected');
  });

  test('shows backend message from API', async ({ page }: { page: any }) => {
    await page.goto(baseURL);
    await expect(page.locator('.message-box')).toContainText('Backend Message');
    await expect(page.locator('.message-box')).not.toContainText('Failed to connect');
  });
});
