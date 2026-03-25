import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HttpModule } from '@nestjs/axios';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { MyFatoorahService } from './myfatoorah.service';
import { MockPaymentService } from './mock-payment.service';
import { Payment } from './entities/payment.entity';
import { RewardsModule } from '../rewards/rewards.module';
import { PostponementsModule } from '../postponements/postponements.module';
import { UsersModule } from '../users/users.module';
import { BnplSessionsModule } from '../bnpl-sessions/bnpl-sessions.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Payment]),
    RewardsModule,
    HttpModule,
    forwardRef(() => PostponementsModule), // Use forwardRef to avoid circular dependency
    UsersModule,
    forwardRef(() => BnplSessionsModule),
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService, MyFatoorahService, MockPaymentService],
  exports: [PaymentsService, MyFatoorahService, MockPaymentService],
})
export class PaymentsModule { }
