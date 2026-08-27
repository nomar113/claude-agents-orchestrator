import { JSDOM } from 'jsdom';
import fs from 'fs';
import path from 'path';
import { extractDataFromRJ } from '../../src/extractor/extract';

function loadFixture(name: string): Document {
  const html = fs.readFileSync(path.join(__dirname, '../fixtures', name), 'utf-8');
  return new JSDOM(html).window.document;
}

describe('extractDataFromRJ', () => {
  const data = extractDataFromRJ(loadFixture('rj-success.html'));

  it('extracts merchant identification', () => {
    expect(data.merchantName).toBe('MERCADO EXEMPLO LTDA');
    expect(data.cnpj).toBe('12.345.678/0001-90');
    expect(data.merchantAddress).toBe('Rua Exemplo, 123, Bairro Exemplo, Rio de Janeiro - RJ');
  });

  it('extracts items', () => {
    expect(data.items).toEqual([
      { productName: 'Arroz Branco', code: '123456', quantity: 2, unit: 'UN', unitPrice: 5, totalPrice: 10 },
    ]);
  });

  it('extracts totals', () => {
    expect(data.totalItems).toBe(1);
    expect(data.subtotal).toBe(150);
    expect(data.discount).toBe(10);
    expect(data.total).toBe(140);
    expect(data.taxes).toBe(5);
  });

  it('extracts payments', () => {
    expect(data.payments).toEqual([{ type: 'Dinheiro', value: 140 }]);
  });

  it('extracts the emission date', () => {
    expect(data.date).toBe('27/08/2026 10:15:00-03:00');
  });
});
