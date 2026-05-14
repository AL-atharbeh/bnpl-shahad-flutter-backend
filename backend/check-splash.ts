import { NestFactory } from '@nestjs/core';
import { AppModule } from './src/app.module';
import { AppConfigService } from './src/app-config/app-config.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const appConfigService = app.get(AppConfigService);
  
  // الرابط الجديد الذي سنضعه (سأستخدم رابط صورة بانر رفعتها أنت مسبقاً للتجربة)
  const newUrl = "https://api.shahedapp.com/api/v1/banners/uploads/1778713172154-bannar.png";
  
  console.log('--- Updating Splash Config in Database ---');
  const result = await appConfigService.updateSplashImage(newUrl);
  console.log(JSON.stringify(result, null, 2));
  
  await app.close();
}

bootstrap();
