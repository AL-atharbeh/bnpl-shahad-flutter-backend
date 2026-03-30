import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import * as express from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Increase body size limit for image uploads
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ limit: '10mb', extended: true }));

  // Global prefix
  const apiPrefix = configService.get('API_PREFIX', 'api/v1');
  app.setGlobalPrefix(apiPrefix);

  // Enable CORS
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('BNPL API')
    .setDescription('Buy Now Pay Later - Backend API Documentation')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  // Handle root path
  const httpAdapter = app.getHttpAdapter();
  httpAdapter.get('/', (req, res) => {
    res.json({
      message: 'Welcome to BNPL API',
      version: '1.0.2 (Vercel Fix)',
      documentation: '/api/docs',
      apiPrefix: `/${apiPrefix}`,
    });
  });

  // For Vercel: We don't call app.listen() if we're exporting the handler
  if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
    const port = configService.get('PORT', 3000);
    await app.listen(port, '0.0.0.0');
    console.log(`🚀 BNPL Backend is running on: http://0.0.0.0:${port}`);
  }

  return app;
}

// Export for Vercel
let server;
export default async (req: any, res: any) => {
  if (!server) {
    const app = await bootstrap();
    await app.init();
    server = app.getHttpAdapter().getInstance();
  }
  return server(req, res);
};

// Also keep the bootstrap call for local development
if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
  bootstrap();
}

