import { test, expect } from '@playwright/test';
import { AdminPage } from '../pages/AdminPages';
import { LoginPage } from '../pages/LoginPage';
 import path from 'path'; // Jangan lupa import path di bagian atas file spec Anda

test.describe('Alur Pengujian Panel Admin (TC-AD-01 s.d TC-AD-08)', () => {

    test('TC-AD-01: Login admin berhasil', async ({ page }) => {
        const loginPage = new LoginPage(page);
        await loginPage.goto();
        await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123');
        
        await expect(page).toHaveURL(/.*admin\/dashboard/);
        await expect(page.locator('h2')).toContainText('DASHBOARD');
    });

    test('TC-AD-02: Akses dashboard admin', async ({ page }) => {
        const loginPage = new LoginPage(page);
        await loginPage.goto();
        await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123');

        await page.goto('/admin/dashboard');
        await expect(page.locator('h3:has-text("KATALOG BARANG")')).toBeVisible();
    });

  

test('TC-AD-03: Mengelola data produk', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123');
    
    const adminPage = new AdminPage(page);
    
    // Mengambil file gambar dari folder fixtures Anda
    const fixtureImagePath = path.join(__dirname, '..', 'fixtures', 'bukti.jpg');

    await adminPage.addProduct(
        'Hijab Testing Automated',   // name
        'Pashmina',                  // category
        '20',                        // stock
        '35000',                     // price
        'Deskripsi produk testing e2e.', // desc
        'S,M,L',                     // sizes
        '10,5,5',                    // sizeStocks
        'Merah,Biru',                // colors
        'Merah:10, Biru:10',         // colorStocks
        'Diskon 20%',                // promo
        fixtureImagePath             // imagePath (mengarah ke folder fixtures)
    );
    
    await page.click('#addProductModal button:has-text("Batal")');
});

    test('TC-AD-04: Mengelola data pengguna', async ({ page }) => {
        const loginPage = new LoginPage(page);
        await loginPage.goto();
        // Memakai akun super_admin karena manajemen user dibatasi rutenya[cite: 10]
        await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123'); 
        
        await page.goto('/user/manage');
        await expect(page.locator('h2')).toContainText('Katalog Data User Pelanggan');
    });

    test('TC-AD-05: Memverifikasi pembayaran', async ({ page }) => {
        const loginPage = new LoginPage(page);
        await loginPage.goto();
        await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123');
        
        const adminPage = new AdminPage(page);
        await adminPage.verifyPayment();
        await expect(page.locator('h2')).toContainText('Verifikasi Pembayaran');
    });

    test('TC-AD-06: Mengelola komentar pelanggan', async ({ page }) => {
        const loginPage = new LoginPage(page);
        await loginPage.goto();
        await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123');
        
        const adminPage = new AdminPage(page);
        await adminPage.deleteComment();
        await expect(page.locator('h2')).toContainText('Manajemen Ulasan & Komentar');
    });

    test('TC-AD-07: Mengaktifkan atau menonaktifkan jam operasional', async ({ page }) => {
        const loginPage = new LoginPage(page);
        await loginPage.goto();
        // Memerlukan hak akses super_admin[cite: 10]
        await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123'); 
        
        const adminPage = new AdminPage(page);
        await adminPage.toggleBusinessHours();
        await expect(page).toHaveURL(/.*admin\/dashboard/);
    });

    test('TC-AD-08: Logout admin', async ({ page }) => {
        const loginPage = new LoginPage(page);
        await loginPage.goto();
        await loginPage.login('admin@rrhijab.com', 'admin@rrhijab123');
        await expect(page).toHaveURL(/.*admin\/dashboard/);

        const adminPage = new AdminPage(page);
        await adminPage.logout();
        await page.waitForURL(/.*login/);
        await expect(page).toHaveURL(/.*login/);
    });

});