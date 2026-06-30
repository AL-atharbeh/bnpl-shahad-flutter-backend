import { NestFactory } from '@nestjs/core';
import { AppModule } from './src/app.module';
import { DataSource } from 'typeorm';

async function bootstrap() {
    console.log('🔍 Booting project context...');
    const app = await NestFactory.createApplicationContext(AppModule);
    const dataSource = app.get(DataSource);
    
    // Get all completed payments
    const payments = await dataSource.query(`
        SELECT p.id, p.amount, p.storeId, p.status, p.orderId, s.name as storeName
        FROM payments p
        LEFT JOIN stores s ON p.storeId = s.id
        WHERE p.status = 'completed'
    `);
    
    console.log(`📊 Completed payments count: ${payments.length}`);
    for (const p of payments) {
        // Check if in settlement_payments
        const inSettlement = await dataSource.query(`
            SELECT * FROM settlement_payments WHERE payment_id = ${p.id}
        `);
        console.log(`💳 Payment #${p.id} | Store: ${p.storeName} (ID: ${p.storeId}) | Amount: ${p.amount} | In Settlement: ${inSettlement.length > 0 ? 'YES' : 'NO'}`);
    }
    
    await app.close();
}
bootstrap();
