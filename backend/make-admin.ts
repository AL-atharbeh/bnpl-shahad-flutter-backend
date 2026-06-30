import { NestFactory } from '@nestjs/core';
import { AppModule } from './src/app.module';
import { DataSource } from 'typeorm';

async function bootstrap() {
    console.log('🔍 Booting project context...');
    const app = await NestFactory.createApplicationContext(AppModule);
    const dataSource = app.get(DataSource);
    
    try {
        await dataSource.query("UPDATE users SET role = 'admin' WHERE id = 1");
        console.log('✅ Successfully promoted User ID 1 (+962792380440) to Admin!');
    } catch (e) {
        console.error('❌ Failed to promote user:', e.message);
    }
    
    await app.close();
}
bootstrap().catch(err => {
    console.error('❌ Bootstrap failed:', err);
});
