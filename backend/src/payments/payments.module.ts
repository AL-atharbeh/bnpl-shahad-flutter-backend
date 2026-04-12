import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HttpModule } from '@nestjs/axios';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { MyFatoorahService } from './myfatoorah.service';
import { MockPaymentService } from './mock-payment.service';
import { StripeService } from './stripe.service';
import { Payment } from './entities/payment.entity';
import { Store } from '../stores/entities/store.entity';
import { RewardsModule } from '../rewards/rewards.module';
import { PostponementsModule } from '../postponements/postponements.module';
import { UsersModule } from '../users/users.module';
import { BnplSessionsModule } from '../bnpl-sessions/bnpl-sessions.module';
import { CommissionSettingsModule } from '../commission-settings/commission-settings.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Payment, Store]),
    RewardsModule,
    HttpModule,
    forwardRef(() => PostponementsModule), // Use forwardRef to avoid circular dependency
    UsersModule,
    forwardRef(() => BnplSessionsModule),
    CommissionSettingsModule,
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService, MyFatoorahService, StripeService, MockPaymentService],
  exports: [PaymentsService, MyFatoorahService, StripeService, MockPaymentService],
})
export class PaymentsModule { }
