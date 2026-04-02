import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import * as express from 'express';
import * as path from 'path';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Increase body size limit for image uploads
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ limit: '10mb', extended: true }));
  
  // Serve test store static files
  app.use('/store-test', express.static(path.join(process.cwd(), 'store-test')));

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

  // Listen on the port (Railway sets PORT automatically)
  const port = process.env.PORT || configService.get<number>('PORT') || 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 BNPL Backend is running on: http://0.0.0.0:${port}`);

  return app;
}

bootstrap();

