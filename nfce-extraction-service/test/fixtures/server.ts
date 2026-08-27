import http from 'http';
import fs from 'fs';
import path from 'path';
import type { AddressInfo } from 'net';

function readFixture(name: string): string {
  return fs.readFileSync(path.join(__dirname, name), 'utf-8');
}

const SUCCESS_HTML = readFixture('rj-success.html');
const BLOCKED_HTML = readFixture('rj-blocked.html');
const BLOCKED_KEYWORD_HTML = readFixture('rj-blocked-keyword.html');
const LOADING_HTML = readFixture('rj-loading.html');

// Simulates the SEFAZ-RJ anti-bot challenge reloading the document a couple of
// times before finally serving the ready invoice.
const RELOAD_COUNT_BEFORE_READY = 2;

export interface FixtureServer {
  url: string;
  resetReloadCounter: () => void;
  close: () => Promise<void>;
}

export async function startFixtureServer(): Promise<FixtureServer> {
  let reloadRequestCount = 0;

  const server = http.createServer((req, res) => {
    const url = req.url ?? '/';

    if (url === '/success') {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(SUCCESS_HTML);
      return;
    }

    if (url === '/blocked') {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(BLOCKED_HTML);
      return;
    }

    if (url === '/blocked-keyword') {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(BLOCKED_KEYWORD_HTML);
      return;
    }

    if (url === '/never-ready') {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(LOADING_HTML);
      return;
    }

    if (url === '/reloading') {
      reloadRequestCount += 1;
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      if (reloadRequestCount <= RELOAD_COUNT_BEFORE_READY) {
        res.end(
          '<html><head><meta http-equiv="refresh" content="0.1;url=/reloading"></head>' +
            '<body>Verificando...</body></html>',
        );
      } else {
        res.end(SUCCESS_HTML);
      }
      return;
    }

    res.writeHead(404);
    res.end('Not found');
  });

  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
  const { port } = server.address() as AddressInfo;

  return {
    url: `http://127.0.0.1:${port}`,
    resetReloadCounter: () => {
      reloadRequestCount = 0;
    },
    close: () =>
      new Promise<void>((resolve, reject) => {
        server.close((err) => (err ? reject(err) : resolve()));
      }),
  };
}
