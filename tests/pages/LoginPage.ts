import { Locator, Page } from '@playwright/test';

export class LoginPage {
  [x: string]: any;
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorAlert: Locator;

  constructor(page: Page) {
    this.page = page;
    // Menggunakan locator berdasarkan 'name' yang ada di tag input HTML Anda
    this.emailInput = page.locator('input[name="email"]');
    this.passwordInput = page.locator('input[name="password"]');
    this.loginButton = page.getByRole('button', { name: 'Log In' });
    // Locator untuk pesan error Laravel yang Anda buat
    this.errorAlert = page.locator('.bg-red-50');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, pass: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(pass);
    await this.loginButton.click();
  }
}