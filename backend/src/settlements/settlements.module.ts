import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SettlementsController } from './settlements.controller';
import { SettlementsService } from './settlements.service';
import { Settlement } from './entities/settlement.entity';
import { Payment } from '../payments/entities/payment.entity';
import { UsersModule } from '../users/users.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Settlement, Payment]),
        UsersModule,
        NotificationsModule,
    ],
    controllers: [SettlementsController],
    providers: [SettlementsService],
    exports: [SettlementsService],
})
export class SettlementsModule { }
