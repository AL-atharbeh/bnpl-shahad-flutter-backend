import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StoresController } from './stores.controller';
import { ReviewsController } from './reviews.controller';
import { StoresService } from './stores.service';
import { ReviewsService } from './reviews.service';
import { Store } from './entities/store.entity';
import { Review } from './entities/review.entity';
import { ProductsModule } from '../products/products.module';
import { Deal } from '../deals/entities/deal.entity';
import { Vendor } from '../vendors/entities/vendor.entity';
import { NotificationsModule } from '../notifications/notifications.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Store, Deal, Vendor, Review]),
    ProductsModule,
    NotificationsModule,
    UsersModule,
  ],
  controllers: [StoresController, ReviewsController],
  providers: [StoresService, ReviewsService],
  exports: [StoresService, ReviewsService],
})
export class StoresModule {}

