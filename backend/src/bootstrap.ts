import { INestApplication, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { ExpressAdapter } from '@nestjs/platform-express';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import * as express from 'express';
import * as path from 'path';
import { AppModule } from './app.module';

/**
 * Shared application setup used by both the local server (main.ts) and the
 * Vercel serverless handler (api/index.ts), so the two behave identically.
 */
export async function createApp(
  expressInstance?: express.Express,
): Promise<INestApplication> {
  const app = expressInstance
    ? await NestFactory.create(AppModule, new ExpressAdapter(expressInstance))
    : await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ limit: '10mb', extended: true }));

  const publicPath = path.join(process.cwd(), 'public');
  app.use('/store-test', express.static(path.join(publicPath, 'store-test')));

  const apiPrefix = configService.get('API_PREFIX', 'api/v1');
  app.setGlobalPrefix(apiPrefix);

  // Only these origins may send credentialed requests. Set CORS_ORIGINS as a
  // comma separated list to change it without a redeploy of the code.
  const allowedOrigins = (
    process.env.CORS_ORIGINS ||
    'https://shahedapp.com,https://www.shahedapp.com,https://admin.shahedapp.com,https://vendor.shahedapp.com'
  )
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);

  app.enableCors({
    origin: (origin, callback) => {
      // Mobile apps and server to server calls send no Origin header.
      if (!origin || allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      return callback(null, false);
    },
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  const config = new DocumentBuilder()
    .setTitle('BNPL API')
    .setDescription('Buy Now Pay Later - Backend API Documentation')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  SwaggerModule.setup('api/docs', app, SwaggerModule.createDocument(app, config));

  const httpAdapter = app.getHttpAdapter();
  httpAdapter.get('/', (req, res) => {
    res.json({
      message: 'Welcome to BNPL API',
      version: '2.0.0 (Vercel)',
      documentation: '/api/docs',
      apiPrefix: `/${apiPrefix}`,
    });
  });

  return app;
}
