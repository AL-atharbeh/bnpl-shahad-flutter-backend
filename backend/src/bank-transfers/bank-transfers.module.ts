import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BankTransfersController } from './bank-transfers.controller';
import { BankTransfersService } from './bank-transfers.service';
import { BankTransfer } from './entities/bank-transfer.entity';
import { Payment } from '../payments/entities/payment.entity';

@Module({
    imports: [TypeOrmModule.forFeature([BankTransfer, Payment])],
    controllers: [BankTransfersController],
    providers: [BankTransfersService],
    exports: [BankTransfersService],
})
export class BankTransfersModule { }
