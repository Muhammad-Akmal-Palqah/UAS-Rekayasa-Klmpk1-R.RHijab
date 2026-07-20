import { test, expect } from '@playwright/test';
import { RegisterPage } from '../pages/RegisterPage';

test.describe('Test Case Registrasi Pelanggan', () => {

  test('TC-PL-03: Registrasi Pelanggan Baru', async ({ page }) => {
    // Cukup deklarasikan registerPage sekali saja di sini
    const registerPage = new RegisterPage(page);
    
    // 1. Arahkan ke halaman register
    await registerPage.goto();
    await page.waitForURL('**/register');
    
    // 2. Isi data pendaftaran
    await registerPage.register('newuser_test@example.com', 'passwordbaru123');
    
    // 3. Verifikasi
    await expect(page).toHaveURL(/.*register/);
});
});