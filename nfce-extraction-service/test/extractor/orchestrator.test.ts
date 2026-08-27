import { extractInvoice } from '../../src/extractor/orchestrator';
import { closeBrowser, getOpenContextCount } from '../../src/browser/browser-manager';
import { startFixtureServer, FixtureServer } from '../fixtures/server';

jest.setTimeout(30_000);

let server: FixtureServer;

beforeAll(async () => {
  server = await startFixtureServer();
});

afterAll(async () => {
  await server.close();
  await closeBrowser();
});

describe('extractInvoice', () => {
  it('resolves READY with the extracted data for a successful page', async () => {
    const result = await extractInvoice(`${server.url}/success`);
    expect(result.status).toBe('READY');
    expect(result.data?.merchantName).toBe('MERCADO EXEMPLO LTDA');
    expect(getOpenContextCount()).toBe(0);
  });

  it('resolves BLOCKED with the SEFAZ message for a blocked page', async () => {
    const result = await extractInvoice(`${server.url}/blocked`);
    expect(result.status).toBe('BLOCKED');
    expect(result.message).toBe('Não foi possível validar o acesso.');
    expect(getOpenContextCount()).toBe(0);
  });

  it('resolves TIMEOUT when the invoice never becomes ready in time', async () => {
    process.env.EXTRACTION_TIMEOUT_MS = '2000';
    try {
      const result = await extractInvoice(`${server.url}/never-ready`);
      expect(result.status).toBe('TIMEOUT');
    } finally {
      delete process.env.EXTRACTION_TIMEOUT_MS;
    }
    expect(getOpenContextCount()).toBe(0);
  });

  it('resolves NAVIGATION_ERROR when the target is unreachable', async () => {
    const result = await extractInvoice('http://127.0.0.1:1');
    expect(result.status).toBe('NAVIGATION_ERROR');
    expect(getOpenContextCount()).toBe(0);
  });

  it('resolves READY even when the page reloads several times during polling', async () => {
    server.resetReloadCounter();
    const result = await extractInvoice(`${server.url}/reloading`);
    expect(result.status).toBe('READY');
    expect(result.data?.merchantName).toBe('MERCADO EXEMPLO LTDA');
    expect(getOpenContextCount()).toBe(0);
  });
});
