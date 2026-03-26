import { NestFactory } from '@nestjs/core';
import { AppModule } from './src/app.module';
import { UsersService } from './src/users/users.service';

async function bootstrap() {
    const app = await NestFactory.createApplicationContext(AppModule);
    const usersService = app.get(UsersService);
    
    const user = await usersService.findById(1);
    console.log('USER ID 1:', {
        id: user.id,
        name: user.name,
        phone: user.phone,
        fcmToken: user.fcmToken ? user.fcmToken.substring(0, 20) + '...' : 'NULL'
    });
    
    await app.close();
}
bootstrap();
