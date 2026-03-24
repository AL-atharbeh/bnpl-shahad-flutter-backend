import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HomeController } from './home.controller';
import { HomeService } from './home.service';
import { Store } from '../stores/entities/store.entity';
import { Product } from '../products/entities/product.entity';
import { Payment } from '../payments/entities/payment.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { Deal } from '../deals/entities/deal.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Store, Product, Payment, Notification, Deal]),
  ],
  controllers: [HomeController],
  providers: [HomeService],
  exports: [HomeService],
})
export class HomeModule {}

