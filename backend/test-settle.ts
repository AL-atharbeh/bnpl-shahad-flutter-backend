import { NestFactory } from '@nestjs/core';
import { AppModule } from './src/app.module';
import { SettlementsService } from './src/settlements/settlements.service';

async function bootstrap() {
    console.log('🔍 Booting project context...');
    const app = await NestFactory.createApplicationContext(AppModule);
    const service = app.get(SettlementsService);
    try {
        console.log('🔄 Querying outstanding orders for store 5 (LUXE COUTURE)...');
        const orders = await service.getStoreOutstandingOrders(5);
        console.log('📊 Outstanding orders:', orders.data);
        
        if (orders.data.length > 0) {
            const ids = orders.data.map((o: any) => o.id);
            console.log(`⚡ Settle Attempt - Store ID: 5 | Session IDs: ${ids}`);
            const res = await service.createSettlement({
                storeId: 5,
                sessionIds: ids,
                notes: 'Test manual settlement from script'
            });
            console.log('✅ Settlement created successfully!', res);
        } else {
            console.log('ℹ️ No outstanding orders found.');
        }
    } catch (err: any) {
        console.error('❌ Error during testing:', err.message, err.stack);
    }
    await app.close();
}
bootstrap();
