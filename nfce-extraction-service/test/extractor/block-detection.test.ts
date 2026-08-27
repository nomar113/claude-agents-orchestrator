import { JSDOM } from 'jsdom';
import fs from 'fs';
import path from 'path';
import { getBlockMessageRJ } from '../../src/extractor/block-detection';

function loadFixture(name: string): Document {
  const html = fs.readFileSync(path.join(__dirname, '../fixtures', name), 'utf-8');
  return new JSDOM(html).window.document;
}

describe('getBlockMessageRJ', () => {
  it('returns the .avisoErro message when present', () => {
    expect(getBlockMessageRJ(loadFixture('rj-blocked.html'))).toBe('Não foi possível validar o acesso.');
  });

  it('falls back to keyword scan when there is no .avisoErro element', () => {
    const message = getBlockMessageRJ(loadFixture('rj-blocked-keyword.html'));
    expect(message).not.toBeNull();
    expect(message!.toLowerCase()).toContain('erro na consulta');
  });

  it('returns null for a ready page', () => {
    expect(getBlockMessageRJ(loadFixture('rj-success.html'))).toBeNull();
  });

  it('returns null while the invoice is still loading', () => {
    expect(getBlockMessageRJ(loadFixture('rj-loading.html'))).toBeNull();
  });
});
