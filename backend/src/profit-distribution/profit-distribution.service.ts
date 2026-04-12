import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Payment } from '../payments/entities/payment.entity';
import { CommissionSetting } from '../commission-settings/entities/commission-setting.entity';
import dayjs from 'dayjs';

@Injectable()
export class ProfitDistributionService {
    constructor(
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
        @InjectRepository(CommissionSetting)
        private commissionSettingRepository: Repository<CommissionSetting>,
    ) { }

    private async getCurrentRatios() {
        const settings = await this.commissionSettingRepository.findOne({
            order: { effectiveFrom: 'DESC' },
        });
        return {
            bankCommission: settings?.bankCommission || 0.03,
            platformCommission: settings?.platformCommission || 0.02,
        };
    }

    async getDistributionStats() {
        const allPayments = await this.paymentRepository.find({
            relations: ['store', 'user'],
        });

        // Calculate total financed (all completed orders)
        const uniqueOrders = new Map();
        allPayments.forEach(p => {
            if (p && p.orderId && !uniqueOrders.has(p.orderId)) {
                const amount = Number(p.amount) || 0;
                const installments = Number(p.installmentsCount) || 1;
                const orderTotal = amount * installments;
                uniqueOrders.set(p.orderId, orderTotal);
            }
        });
        const totalFinanced = Array.from(uniqueOrders.values()).reduce((sum, val: number) => sum + (val || 0), 0);

        // Get all completed payments
        const completedPayments = allPayments.filter(p => p && p.status === 'completed');
        const totalCollected = completedPayments.reduce((sum, p) => sum + (Number(p.amount) || 0), 0);

        // Calculate dynamic shares
        const ratios = await this.getCurrentRatios();
        const bankTotalShare = totalFinanced * ratios.bankCommission;
        const platformTotalShare = totalFinanced * ratios.platformCommission;

        // Pending profits represent the full platform share of all volume
        const pendingProfits = platformTotalShare;

        return {
            success: true,
            data: {
                totalFinanced,
                bankTotalShare,
                platformTotalShare,
                pendingProfits,
                totalCollected,
            },
        };
    }

    async getWeeklyChart(days: number = 7) {
        const allPayments = await this.paymentRepository.find({
            where: { status: 'completed' },
        });

        const ratios = await this.getCurrentRatios();
        const chartData = [];
        const dayNames = ['أحد', 'اثن', 'ثلاث', 'أربع', 'خميس', 'جمعة', 'سبت'];

        for (let i = days - 1; i >= 0; i--) {
            const date = dayjs().subtract(i, 'day');
            const startOfDay = date.startOf('day').toDate().getTime();
            const endOfDay = date.endOf('day').toDate().getTime();

            const dayPayments = allPayments.filter(p => {
                if (!p || !p.paidAt) return false;
                const paidAtTime = new Date(p.paidAt).getTime();
                return paidAtTime >= startOfDay && paidAtTime <= endOfDay;
            });

            const totalColl = dayPayments.reduce((sum, p) => sum + (Number(p.amount) || 0), 0);
            const bShare = totalColl * (ratios.bankCommission || 0.03);
            const pShare = totalColl * (ratios.platformCommission || 0.02);

            chartData.push({
                day: dayNames[date.day()],
                totalCollected: totalColl,
                bankShare: bShare,
                platformShare: pShare,
            });
        }

        return {
            success: true,
            data: chartData,
        };
    }
}
