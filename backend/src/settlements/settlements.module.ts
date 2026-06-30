import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SettlementsController } from './settlements.controller';
import { SettlementsService } from './settlements.service';
import { Settlement } from './entities/settlement.entity';
import { Payment } from '../payments/entities/payment.entity';
import { Store } from '../stores/entities/store.entity';
import { BnplSession } from '../bnpl-sessions/entities/bnpl-session.entity';
import { UsersModule } from '../users/users.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { CommissionSettingsModule } from '../commission-settings/commission-settings.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Settlement, Payment, Store, BnplSession]),
        UsersModule,
        NotificationsModule,
        CommissionSettingsModule,
    ],
    controllers: [SettlementsController],
    providers: [SettlementsService],
    exports: [SettlementsService],
})
export class SettlementsModule { }
