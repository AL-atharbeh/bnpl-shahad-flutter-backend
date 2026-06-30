import { NestFactory } from '@nestjs/core';
import { AppModule } from './src/app.module';
import { DataSource } from 'typeorm';

async function bootstrap() {
    console.log('🔍 Booting diagnostic context...');
    const app = await NestFactory.createApplicationContext(AppModule);
    const dataSource = app.get(DataSource);
    
    console.log('✅ Database connected successfully!');
    
    const tables = ['users', 'stores', 'payments', 'bnpl_sessions', 'in_app_notifications', 'notifications'];
    
    for (const table of tables) {
        try {
            const result = await dataSource.query(`SELECT COUNT(*) as count FROM \`${table}\``);
            console.log(`📊 Table "${table}": ${result[0].count} records`);
        } catch (e) {
            console.error(`❌ Failed to query table "${table}":`, e.message);
        }
    }
    
    await app.close();
}
bootstrap().catch(err => {
    console.error('❌ Diagnostic bootstrap failed:', err);
});
