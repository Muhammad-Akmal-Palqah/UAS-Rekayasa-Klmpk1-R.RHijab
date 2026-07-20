import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test.describe('Test Case Login Pelanggan', () => {

  test('TC-PL-01: Login pelanggan berhasil', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    
    // Ganti dengan kredensial yang valid di database Anda
    await login.login('aisyah@example.com', 'password123'); 
    
    // Pastikan user dialihkan ke dashboard/halaman setelah login
    await expect(page).toHaveURL(/.*pesan-hijab/); 
  });

  test('TC-PL-02: Login pelanggan dengan password salah', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    
    await login.login('aisyah@example.com', 'salahpassword');
    
  await expect(login.errorAlert).toBeVisible(); 
  
  // Perubahan di sini: gunakan errorAlert
  await expect(login.errorAlert).toContainText('Email atau password salah');
  });
});