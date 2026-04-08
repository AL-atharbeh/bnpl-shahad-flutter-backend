import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { StoresService } from '../stores/stores.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Store } from '../stores/entities/store.entity';
import { Repository } from 'typeorm';

async function registerModernStore() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const storeRepository = app.get<Repository<Store>>(getRepositoryToken(Store));
  const storesService = app.get(StoresService);

  console.log('🚀 البدء في تسجيل "متجر مودرن" من الصفر...');

  // 1. Create a fresh store
  const storeData = {
    name: 'Modern Store',
    nameAr: 'متجر مودرن',
    description: 'متجر تجريبي للملابس والموضة',
    descriptionAr: 'متجر تجريبي للملابس والموضة',
    rating: 4.8,
    categoryId: 1, // Assume electronics/fashion category exists
    isActive: true, // Auto-approve for demo
    status: 'approved',
  };

  const newStore = await storesService.createStore(storeData);
  
  // Update status to approved to ensure keys are generated if they weren't in createStore
  const approvedStore = await storesService.updateStoreStatus(newStore.id, 'approved');

  console.log('\n✅ تمت العملية بنجاح! إليك بيانات المتجر الجديد للربط:');
  console.log('--------------------------------------------------');
  console.log(`🆔 معرف المتجر (Store ID): ${approvedStore.id}`);
  console.log(`🔑 المفتاح العام (API Key): ${approvedStore.apiKey}`);
  console.log(`🔒 المفتاح السري (API Secret): ${approvedStore.apiSecret}`);
  console.log('--------------------------------------------------');
  console.log('\nالآن يمكنك وضع هذه المفتيح في ملف store-test/script.js أو استخدام لوحة تحكم التاجر للتجربة.');

  await app.close();
}

registerModernStore().catch(err => {
  console.error('❌ خطأ أثناء التسجيل:', err.message);
  process.exit(1);
});
