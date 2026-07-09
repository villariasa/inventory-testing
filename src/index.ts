import 'dotenv/config';
import { serve } from '@hono/node-server';
import { OpenAPIHono } from '@hono/zod-openapi';
import { swaggerUI } from '@hono/swagger-ui';
import { cors } from 'hono/cors';
import { commonRoute } from './inv_v1/routes/common.route.js';
import { itemCategoryRoute } from './inv_v1/routes/itemCategory.route.js';
import { itemRoute } from './inv_v1/routes/item.route.js';
import { unitBinRoute } from './inv_v1/routes/unitBin.route.js';
import { unitsRoute } from './inv_v1/routes/units.route.js';
import { unitItemRoute } from './inv_v1/routes/unitItem.route.js';
import { adjustmentRoute } from './inv_v1/routes/adjustment.route.js';
import { itemImportsRoute } from './inv_v1/routes/itemImports.route.js';
import { inTransitRoute } from './inv_v1/routes/inTransit.route.js';
import { reportsRoute } from './inv_v1/routes/reports.route.js';
import { crossMiscRoute } from './inv_v1/routes/crossMisc.route.js';
import { DatabaseFactory } from './inv_v1/lib/database-factory.js';

const app = new OpenAPIHono();

app.use('*', cors());

app.use('*', async (c, next) => {
  if (c.env && (c.env as any).HYPERDRIVE) {
    const hd = (c.env as any).HYPERDRIVE;
    process.env.DB_HOST = hd.host;
    process.env.DB_PORT = String(hd.port);
    process.env.DB_USER = hd.user;
    process.env.DB_PASSWORD = hd.password;
    process.env.DB_NAME = hd.database;
    DatabaseFactory.getInstance().reloadConfiguration();
  }
  await next();
});



app.route('/inv/v1', commonRoute);
app.route('/inv/v1', itemCategoryRoute);
app.route('/inv/v1', itemRoute);
app.route('/inv/v1', unitBinRoute);
app.route('/inv/v1', unitsRoute);
app.route('/inv/v1', unitItemRoute);
app.route('/inv/v1', adjustmentRoute);
app.route('/inv/v1', itemImportsRoute);
app.route('/inv/v1', inTransitRoute);
app.route('/inv/v1', reportsRoute);
app.route('/inv/v1', crossMiscRoute);

app.doc('/doc', {
  openapi: '3.0.0',
  info: {
    title: 'Inventory API',
    version: 'v1'
  }
});

app.get('/swagger', swaggerUI({ url: '/doc' }));

const port = parseInt(process.env.BACKEND_PORT || '3000');

if (typeof process !== 'undefined' && process.versions && process.versions.node && typeof (globalThis as any).caches === 'undefined') {
  const server = serve({ fetch: app.fetch, port }, () => {
    console.log(`Inventory API running on port ${port}`);
    console.log(`Swagger UI: http://<host>:${port}/swagger`);
  });

  const gracefulShutdown = (signal: string): void => {
    console.log(`\nReceived ${signal}, shutting down...`);
    server.close(() => {
      console.log('Server closed.');
      process.exit(0);
    });
  };

  process.on('SIGINT', () => gracefulShutdown('SIGINT'));
  process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
}


export default app;
