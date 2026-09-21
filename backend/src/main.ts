import { createApp } from './bootstrap';

async function bootstrap() {
  const app = await createApp();

  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 BNPL Backend is running on: http://0.0.0.0:${port}`);

  return app;
}

bootstrap();
