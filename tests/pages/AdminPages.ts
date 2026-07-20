import { Page, Locator, expect } from '@playwright/test';
import path from 'path';

export class AdminPage {
    readonly page: Page;
    readonly emailInput: Locator;
    readonly passwordInput: Locator;
    readonly loginButton: Locator;
    readonly logoutButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.emailInput = page.locator('input[name="email"]');
        this.passwordInput = page.locator('input[name="password"]');
        this.loginButton = page.locator('button[type="submit"]');
        this.logoutButton = page.locator('form[action*="/logout"] button[type="submit"]');
    }

    async gotoLogin() {
        await this.page.goto('/login');
    }

    async login(email: string, pass: string) {
        await this.gotoLogin();
        await this.emailInput.fill(email);
        await this.passwordInput.fill(pass);
        await this.loginButton.click();
    }

    async logout() {
        await this.logoutButton.click();
    }

    // TC-AD-03: Kelola Produk (Merujuk ke crud_product.blade.php)[cite: 5]
    async addProduct(
        name: string, 
        category: string, 
        stock: string, 
        price: string, 
        desc: string = '', 
        sizes: string = '', 
        sizeStocks: string = '', 
        colors: string = '', 
        colorStocks: string = '',
        promo: string = '',
        imagePath: string) 
        {
        await this.page.goto('/product/manage');
        await this.page.click('button:has-text("Tambah Barang")');
        await this.page.fill('#add_nama_produk', name);
        await this.page.fill('input[name="kategori"]', category);
        await this.page.fill('input[name="stok"]', stock);
        await this.page.fill('input[name="harga"]', price);
        await this.page.fill('input[name="promo"]', promo);
        await this.page.setInputFiles('input[name="gambar_produk[]"]', imagePath);
        await this.page.fill('input[name="available_sizes"]', sizes);
        await this.page.fill('input[name="available_size_stocks"]', sizeStocks);
        await this.page.fill('input[name="available_colors"]', colors);
        await this.page.fill('input[name="available_color_stocks"]', colorStocks)
        await this.page.fill('#add_deskripsi', desc);
    }

    // TC-AD-04: Kelola Pengguna (Merujuk ke crud_user.blade.php)[cite: 6]
    async addUser(name: string, email: string, pass: string) {
        await this.page.goto('/user/manage');
        await this.page.click('button:has-text("Tambah User")');
        await this.page.fill('input[name="name"]', name);
        await this.page.fill('input[name="email"]', email);
        await this.page.fill('input[name="password"]', pass);
        await this.page.locator('#addUserModal form button[type="submit"]').click();
    }

    // TC-AD-05: Verifikasi Pembayaran (Merujuk ke verify_payment.blade.php)[cite: 8]
    async verifyPayment() {
        await this.page.goto('/admin/payment-verification');
        const lunasBtn = this.page.locator('form[action*="/admin/payment-verification/"] button:has-text("Lunas")').first();
        if (await lunasBtn.isVisible()) {
            await lunasBtn.click();
        }
    }

    // TC-AD-06: Kelola Komentar (Merujuk ke crud_comments.blade.php)[cite: 4]
    async deleteComment() {
        await this.page.goto('/admin/comments');
        const deleteBtn = this.page.locator('form[action*="/admin/comments/"] button:has-text("Hapus")').first();
        if (await deleteBtn.isVisible()) {
            await deleteBtn.click();
        }
    }

    // TC-AD-07: Jam Operasional (Merujuk ke dashboard.blade.php)[cite: 7]
    async toggleBusinessHours() {
    await this.page.goto('/admin/dashboard');
    const toggleBtn = this.page.locator('form[action*="business-hours/toggle"] button');
        if (await toggleBtn.isVisible()) {
        // Tunggu navigasi selesai setelah tombol toggle diklik
            await Promise.all([
                this.page.waitForURL(/.*admin\/dashboard/),
                toggleBtn.click()
            ]);
        }
    }
}