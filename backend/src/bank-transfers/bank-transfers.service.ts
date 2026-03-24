import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { BankTransfer } from './entities/bank-transfer.entity';
import { Payment } from '../payments/entities/payment.entity';

@Injectable()
export class BankTransfersService {
    constructor(
        @InjectRepository(BankTransfer)
        private bankTransferRepository: Repository<BankTransfer>,
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
    ) { }

    async getAllTransfers(filters: { page: number; limit: number }) {
        const { page, limit } = filters;
        const skip = (page - 1) * limit;

        const [transfers, total] = await this.bankTransferRepository.findAndCount({
            relations: ['payments', 'payments.user', 'payments.store'],
            order: { transferDate: 'DESC' },
            skip,
            take: limit,
        });

        return {
            success: true,
            data: {
                transfers,
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async createTransfer(data: {
        transferDate: Date;
        amount: number;
        transferredBy?: string;
        notes?: string;
        paymentIds?: number[];
    }) {
        const transfer = this.bankTransferRepository.create({
            transferDate: data.transferDate,
            amount: data.amount,
            transferredBy: data.transferredBy,
            notes: data.notes,
            status: 'completed',
        });

        // If payment IDs are provided, link them to this transfer
        if (data.paymentIds && data.paymentIds.length > 0) {
            const payments = await this.paymentRepository.findBy({
                id: In(data.paymentIds),
            });
            transfer.payments = payments;
        }

        await this.bankTransferRepository.save(transfer);

        return {
            success: true,
            message: 'Transfer recorded successfully',
            data: transfer,
        };
    }
}
