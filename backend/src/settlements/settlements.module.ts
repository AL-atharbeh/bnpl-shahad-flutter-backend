import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SettlementsController } from './settlements.controller';
import { SettlementsService } from './settlements.service';
import { Settlement } from './entities/settlement.entity';
import { Payment } from '../payments/entities/payment.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Settlement, Payment])],
    controllers: [SettlementsController],
    providers: [SettlementsService],
    exports: [SettlementsService],
})
export class SettlementsModule { }
