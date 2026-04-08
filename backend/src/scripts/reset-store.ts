import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { StoresService } from '../stores/stores.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const storesService = app.get(StoresService);

  const storeId = 3; // Modern Store
  console.log(`Resetting store ID ${storeId} to pending...`);
  
  try {
    await storesService.updateStoreStatus(storeId, 'pending');
    console.log('Successfully reset store to pending.');
  } catch (error) {
    console.error('Failed to reset store:', error.message);
  }

  await app.close();
}

bootstrap();
