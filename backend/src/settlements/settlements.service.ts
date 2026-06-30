import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Settlement } from './entities/settlement.entity';
import { Payment } from '../payments/entities/payment.entity';
import { UsersService } from '../users/users.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class SettlementsService {
    constructor(
        @InjectRepository(Settlement)
        private settlementRepository: Repository<Settlement>,
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
        private usersService: UsersService,
        private notificationsService: NotificationsService,
    ) { }

    async getSettlementStats(storeId: number) {
        // 1. Calculate Pending Balance (Completed payments not yet settled)
        // We need to find payments for this store that are 'completed' but NOT in any settlement
        // Since the relation is ManyToMany from Settlement side, we can use a subquery approach

        const qb = this.paymentRepository.createQueryBuilder('payment');

        const pendingBalanceResult = await qb
            .select('SUM(payment.storeAmount)', 'total')
            .where('payment.storeId = :storeId', { storeId })
            .andWhere('payment.status = :status', { status: 'completed' })
            .andWhere(qb => {
                const subQuery = qb.subQuery()
                    .select('sp.payment_id')
                    .from('settlement_payments', 'sp') // Accessing the join table directly if possible, or via relation
                    .getQuery();
                return 'payment.id NOT IN ' + subQuery;
            })
            .getRawOne();

        // 2. Get Last Transfer (Most recent settlement for this store)
        const lastSettlement = await this.settlementRepository.createQueryBuilder('settlement')
            .innerJoin('settlement.payments', 'payment')
            .where('payment.storeId = :storeId', { storeId })
            .orderBy('settlement.settlementDate', 'DESC')
            .take(1)
            .getOne();

        return {
            success: true,
            data: {
                pendingBalance: Number(pendingBalanceResult?.total || 0),
                lastTransfer: lastSettlement ? {
                    amount: Number(lastSettlement.totalCollected),
                    date: lastSettlement.settlementDate
                } : null
            }
        };
    }


    async getAllSettlements(filters: { page: number; limit: number; storeId?: number }) {
        const { page, limit, storeId } = filters;
        const skip = (page - 1) * limit;

        const where: any = {};
        const hasStoreId = storeId !== undefined && storeId !== null && !isNaN(storeId);
        if (hasStoreId) {
            where.payments = { storeId: storeId };
        }

        const [settlements, total] = await this.settlementRepository.findAndCount({
            where,
            relations: ['payments'],
            order: { settlementDate: 'DESC' },
            skip,
            take: limit,
        });

        return {
            success: true,
            data: {
                settlements,
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async createSettlement(data: {
        settlementDate: Date;
        totalCollected: number;
        bankShare: number;
        platformShare: number;
        notes?: string;
        paymentIds?: number[];
    }) {
        const settlement = this.settlementRepository.create({
            settlementDate: data.settlementDate,
            totalCollected: data.totalCollected,
            bankShare: data.bankShare,
            platformShare: data.platformShare,
            notes: data.notes,
            status: 'completed',
        });

        if (data.paymentIds && data.paymentIds.length > 0) {
            const payments = await this.paymentRepository.findBy({
                id: In(data.paymentIds),
            });
            settlement.payments = payments;
        }

        await this.settlementRepository.save(settlement);

        return {
            success: true,
            message: 'Settlement created successfully',
            data: settlement,
        };
    }

    async getSettlementById(id: number) {
        const settlement = await this.settlementRepository.findOne({
            where: { id },
            relations: ['payments', 'payments.user', 'payments.store'],
        });

        return {
            success: true,
            data: settlement,
        };
    }

    async requestSettlement(storeId: number, vendorName: string) {
        // 1. Find all completed payments for this store that are NOT yet settled
        const qb = this.paymentRepository.createQueryBuilder('payment');
        const pendingPayments = await this.paymentRepository.createQueryBuilder('payment')
            .where('payment.storeId = :storeId', { storeId })
            .andWhere('payment.status = :status', { status: 'completed' })
            .andWhere(qb => {
                const subQuery = qb.subQuery()
                    .select('sp.payment_id')
                    .from('settlement_payments', 'sp')
                    .getQuery();
                return 'payment.id NOT IN ' + subQuery;
            })
            .getMany();

        if (pendingPayments.length === 0) {
            throw new BadRequestException('لا توجد مستحقات مالية مكتملة وجاهزة للتسوية حالياً لهذا المتجر.');
        }

        // 2. Calculate values
        let totalCollected = 0;
        let bankShare = 0;
        let platformShare = 0;

        for (const payment of pendingPayments) {
            const amount = Number(payment.amount || 0);
            const bRate = Number(payment.bankCommissionRate || 3) / 100;
            const pRate = Number(payment.platformCommissionRate || 2) / 100;

            bankShare += amount * bRate;
            platformShare += amount * pRate;
            totalCollected += amount;
        }

        // 3. Create the pending settlement record
        const settlement = this.settlementRepository.create({
            settlementDate: new Date(),
            totalCollected,
            bankShare,
            platformShare,
            status: 'pending',
            notes: `طلب تسوية فورية مقدم من المورد ${vendorName}`,
            payments: pendingPayments,
        });

        await this.settlementRepository.save(settlement);

        // 4. Find all admins
        let admins = await this.usersService.findAllAdmins();

        // Fallback for testing: if no admins exist, notify User ID 1 (so you receive it)
        if (admins.length === 0) {
            const user1 = await this.usersService.findById(1).catch(() => null);
            if (user1) {
                admins = [user1];
            }
        }

        // Send notification to each admin
        const title = 'طلب تسوية جديد 🏦';
        const body = `قام المورد ${vendorName} بطلب تسوية بقيمة ${totalCollected.toFixed(2)} JOD`;
        const data = {
            type: 'settlement_request',
            storeId: storeId.toString(),
            vendorName: vendorName,
            settlementId: settlement.id.toString(),
        };

        for (const admin of admins) {
            await this.notificationsService.sendToUser(admin.id, title, body, data, 'urgent');
        }

        return {
            success: true,
            message: 'تم إرسال طلب التسوية بنجاح وتسجيله في النظام كمعلق',
            data: settlement,
        };
    }
}
