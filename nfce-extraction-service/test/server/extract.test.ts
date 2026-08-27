import request from 'supertest';
import { createServer } from '../../src/server';
import { closeBrowser } from '../../src/browser/browser-manager';
import { startFixtureServer, FixtureServer } from '../fixtures/server';

jest.setTimeout(30_000);

const INTERNAL_KEY = 'test-internal-key';

let fixtureServer: FixtureServer;

beforeAll(async () => {
  process.env.X_INTERNAL_KEY = INTERNAL_KEY;
  fixtureServer = await startFixtureServer();
});

afterAll(async () => {
  delete process.env.X_INTERNAL_KEY;
  await fixtureServer.close();
  await closeBrowser();
});

describe('POST /extract', () => {
  it('returns 401 and never reaches Playwright when the X-Internal-Key header is missing', async () => {
    const app = createServer();
    const response = await request(app).post('/extract').send({ invoiceUrl: `${fixtureServer.url}/success` });
    expect(response.status).toBe(401);
  });

  it('returns 401 when the X-Internal-Key header is wrong', async () => {
    const app = createServer();
    const response = await request(app)
      .post('/extract')
      .set('X-Internal-Key', 'wrong-key')
      .send({ invoiceUrl: `${fixtureServer.url}/success` });
    expect(response.status).toBe(401);
  });

  it('returns 400 when invoiceUrl is missing, without touching Playwright', async () => {
    const app = createServer();
    const response = await request(app).post('/extract').set('X-Internal-Key', INTERNAL_KEY).send({});
    expect(response.status).toBe(400);
  });

  it('returns 400 when invoiceUrl is not a string', async () => {
    const app = createServer();
    const response = await request(app)
      .post('/extract')
      .set('X-Internal-Key', INTERNAL_KEY)
      .send({ invoiceUrl: 123 });
    expect(response.status).toBe(400);
  });

  it('returns 200 with READY status and the extracted data for a successful page', async () => {
    const app = createServer();
    const response = await request(app)
      .post('/extract')
      .set('X-Internal-Key', INTERNAL_KEY)
      .send({ invoiceUrl: `${fixtureServer.url}/success` });
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('READY');
    expect(response.body.data.merchantName).toBe('MERCADO EXEMPLO LTDA');
  });

  it('returns 200 with BLOCKED status and the SEFAZ message for a blocked page', async () => {
    const app = createServer();
    const response = await request(app)
      .post('/extract')
      .set('X-Internal-Key', INTERNAL_KEY)
      .send({ invoiceUrl: `${fixtureServer.url}/blocked` });
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('BLOCKED');
    expect(response.body.message).toBe('Não foi possível validar o acesso.');
  });

  it('returns 200 with TIMEOUT status when the invoice never becomes ready in time', async () => {
    process.env.EXTRACTION_TIMEOUT_MS = '2000';
    const app = createServer();
    try {
      const response = await request(app)
        .post('/extract')
        .set('X-Internal-Key', INTERNAL_KEY)
        .send({ invoiceUrl: `${fixtureServer.url}/never-ready` });
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('TIMEOUT');
    } finally {
      delete process.env.EXTRACTION_TIMEOUT_MS;
    }
  });
});
