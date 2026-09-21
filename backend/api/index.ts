import express from 'express';
import { createApp } from '../src/bootstrap';

// Vercel compiles this with the project tsconfig, so the decorator metadata
// NestJS relies on is preserved. A warm instance keeps the initialised app, so
// Nest is only bootstrapped on a cold start.
const server = express();
let ready: Promise<void> | null = null;

function init(): Promise<void> {
  if (!ready) {
    ready = createApp(server)
      .then((app) => app.init())
      .then(() => undefined)
      .catch((err) => {
        // Let the next request retry instead of caching a failed boot.
        ready = null;
        throw err;
      });
  }
  return ready;
}

export default async function handler(req: any, res: any) {
  await init();
  return server(req, res);
}
