import { JSDOM } from 'jsdom';
import fs from 'fs';
import path from 'path';
import { isInvoiceReadyRJ } from '../../src/extractor/readiness';

function loadFixture(name: string): Document {
  const html = fs.readFileSync(path.join(__dirname, '../fixtures', name), 'utf-8');
  return new JSDOM(html).window.document;
}

describe('isInvoiceReadyRJ', () => {
  it('returns true when the invoice page has fully rendered', () => {
    expect(isInvoiceReadyRJ(loadFixture('rj-success.html'))).toBe(true);
  });

  it('returns false while the invoice is still loading', () => {
    expect(isInvoiceReadyRJ(loadFixture('rj-loading.html'))).toBe(false);
  });

  it('returns false for a blocked page', () => {
    expect(isInvoiceReadyRJ(loadFixture('rj-blocked.html'))).toBe(false);
  });
});
