import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import * as express from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Increase body size limit for image uploads (base64 encoded images can be large)
  // Default is 100kb, we increase to 10MB for Civil ID images
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
    .addTag('auth', 'Authentication endpoints')
    .addTag('users', 'User management endpoints')
    .addTag('payments', 'Payment endpoints')
    .addTag('stores', 'Store endpoints')
    .addTag('products', 'Product endpoints')
    .addTag('rewards', 'Rewards points endpoints')
    .addTag('postponements', 'Payment postponement endpoints')
    .addTag('notifications', 'Notification endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  // Handle root path (before global prefix)
  const httpAdapter = app.getHttpAdapter();
  httpAdapter.get('/', (req, res) => {
    res.json({
      message: 'Welcome to BNPL API',
      version: '1.0',
      documentation: '/api/docs',
      apiPrefix: `/${apiPrefix}`,
    });
  });

  const port = configService.get('PORT', 3000);
  // Listen on 0.0.0.0 to accept connections from all network interfaces
  // This allows access from physical devices on the same network
  await app.listen(port, '0.0.0.0');

  console.log(`🚀 BNPL Backend is running on: http://0.0.0.0:${port}`);
  console.log(`📚 API Documentation: http://localhost:${port}/api/docs`);
  console.log(`🔧 API Prefix: /${apiPrefix}`);
  console.log(`🌐 Accessible from network devices on: http://YOUR_IP:${port}`);
}

bootstrap();

