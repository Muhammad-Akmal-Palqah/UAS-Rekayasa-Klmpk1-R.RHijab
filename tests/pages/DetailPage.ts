import { Locator, Page } from '@playwright/test';

export class DetailPage {
  // 1. Definisikan tipe propertinya
  readonly commentTextarea: Locator;
  readonly submitCommentBtn: Locator;
  readonly pesanBtn: Locator;

  constructor(public readonly page: Page) {
    // 2. Inisialisasi locator di dalam constructor
    this.commentTextarea = this.page.locator('textarea[name="komentar"]');
    this.submitCommentBtn = this.page.getByRole('button', { name: 'Kirimkan' });
    this.pesanBtn = this.page.locator('a[href*="/checkout"]');
  }
}