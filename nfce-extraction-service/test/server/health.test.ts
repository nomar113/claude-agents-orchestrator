import request from 'supertest';
import { createServer } from '../../src/server';

describe('GET /health', () => {
  it('returns 200 without requiring authentication', async () => {
    const app = createServer();
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });
});
