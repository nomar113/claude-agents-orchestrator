import express, { Express } from 'express';
import { healthRouter } from './routes/health';
import { extractRouter } from './routes/extract';

export function createServer(): Express {
  const app = express();
  app.use(express.json());
  app.use(healthRouter);
  app.use(extractRouter);
  return app;
}

if (require.main === module) {
  const port = Number(process.env.PORT) || 3000;
  // Binds to all interfaces of the container/host network so it is reachable from
  // the Kotlin backend over the internal Docker/VPS network. This service must
  // never be published on a public host port — enforcing that at the network
  // level (Docker internal network, firewall, no public port mapping) is the
  // responsibility of Tarefa 4.0/infra, not of this bind configuration.
  const host = process.env.HOST || '0.0.0.0';

  const app = createServer();
  app.listen(port, host, () => {
    console.log(JSON.stringify({ event: 'server_started', host, port }));
  });
}
