import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { StoresService } from '../stores/stores.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Store } from '../stores/entities/store.entity';
import { Repository } from 'typeorm';

async function generateKeys() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const storeRepository = app.get<Repository<Store>>(getRepositoryToken(Store));
  const storesService = app.get(StoresService);

  const stores = await storeRepository.find();
  console.log(`Found ${stores.length} stores. Generating keys...`);

  for (const store of stores) {
    if (!store.apiKey || !store.apiSecret) {
      // @ts-ignore - access private method for seeding
      const { apiKey, apiSecret } = storesService.generateApiCredentials();
      store.apiKey = apiKey;
      store.apiSecret = apiSecret;
      await storeRepository.save(store);
      console.log(`✅ Generated keys for ${store.name} (ID: ${store.id})`);
      console.log(`   Key: ${apiKey}`);
    } else {
      console.log(`ℹ️ Store ${store.name} already has keys.`);
      console.log(`   Key: ${store.apiKey}`);
    }
  }

  await app.close();
}

generateKeys();
