import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { SavedCard } from './entities/saved-card.entity';
import { AutoPaymentLog } from './entities/auto-payment-log.entity';
import { SavedCardsService } from './saved-cards.service';
import { SavedCardsController } from './saved-cards.controller';
import { AutoPaymentScheduler } from './auto-payment.scheduler';
import { PaymentsModule } from '../payments/payments.module';
import { UsersModule } from '../users/users.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { Payment } from '../payments/entities/payment.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([SavedCard, AutoPaymentLog, Payment]),
    ScheduleModule.forRoot(),
    PaymentsModule,
    UsersModule,
    NotificationsModule,
  ],
  controllers: [SavedCardsController],
  providers: [SavedCardsService, AutoPaymentScheduler],
  exports: [SavedCardsService],
})
export class SavedCardsModule {}
