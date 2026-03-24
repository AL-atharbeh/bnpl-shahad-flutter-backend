import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PromoNotificationsService } from './promo-notifications.service';
import { PromoNotificationsController } from './promo-notifications.controller';
import { PromoNotification } from './entities/promo-notification.entity';

@Module({
  imports: [TypeOrmModule.forFeature([PromoNotification])],
  controllers: [PromoNotificationsController],
  providers: [PromoNotificationsService],
  exports: [PromoNotificationsService],
})
export class PromoNotificationsModule {}

