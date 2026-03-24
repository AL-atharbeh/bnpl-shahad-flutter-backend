import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfitDistributionController } from './profit-distribution.controller';
import { ProfitDistributionService } from './profit-distribution.service';
import { Payment } from '../payments/entities/payment.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Payment])],
    controllers: [ProfitDistributionController],
    providers: [ProfitDistributionService],
    exports: [ProfitDistributionService],
})
export class ProfitDistributionModule { }
