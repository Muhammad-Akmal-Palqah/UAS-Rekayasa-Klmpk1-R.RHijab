import { Locator, Page } from '@playwright/test';

export class KatalogPage {
  // 1. Definisikan tipe propertinya saja dulu
  readonly productLinks: Locator;

  constructor(public readonly page: Page) {
    // 2. Inisialisasi locator di dalam constructor setelah 'page' tersedia
    this.productLinks = this.page.locator('a[href*="/katalog/"]');
  }

  async goto() { 
    await this.page.goto('/katalog'); 
  }
}