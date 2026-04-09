import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThan, In } from 'typeorm';
import { Payment } from '../payments/entities/payment.entity';
import { Store } from '../stores/entities/store.entity';
import { User } from '../users/entities/user.entity';
import dayjs from 'dayjs';
import quarterOfYear from 'dayjs/plugin/quarterOfYear';

dayjs.extend(quarterOfYear);

@Injectable()
export class ReportsService {
    constructor(
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
        @InjectRepository(Store)
        private storeRepository: Repository<Store>,
        @InjectRepository(User)
        private userRepository: Repository<User>,
    ) { }

    async getDashboardStats(storeId?: number) {
        console.log(`[ReportsService] getDashboardStats called with storeId: ${storeId} (type: ${typeof storeId})`);

        const now = dayjs();
        const startOfQuarter = now.startOf('quarter').toDate();
        const endOfQuarter = now.endOf('quarter').toDate();

        // Security check: If storeId is missing and we don't have an admin flag, return zeros
        if (storeId === undefined || storeId === null || isNaN(storeId)) {
            console.log('[ReportsService] No valid storeId provided for stats. Returning zeros.');
            return {
                success: true,
                data: {
                    totalFinancedQuarter: 0,
                    totalCollected: 0,
                    riskIndicator: 0,
                    totalCommission: 0,
                }
            };
        }

        // 1. Transaction Volume (Current Quarter) - Sum of totalAmount for unique orderIds
        const whereClause: any = {
            createdAt: Between(startOfQuarter, endOfQuarter),
            storeId: storeId
        };

        const quarterPayments = await this.paymentRepository.find({
            where: whereClause,
            select: ['orderId', 'totalAmount'],
        });

        const uniqueOrders = new Map();
        quarterPayments.forEach(p => {
            if (p.orderId && !uniqueOrders.has(p.orderId)) {
                uniqueOrders.set(p.orderId, Number(p.totalAmount) || 0);
            }
        });
        const totalFinancedQuarter = Array.from(uniqueOrders.values()).reduce((sum, val) => sum + val, 0);

        // 2. Collected Installments (All time)
        const collectedWhere: any = { status: 'completed' };
        if (storeId) collectedWhere.storeId = storeId;

        const completedPayments = await this.paymentRepository.find({
            where: collectedWhere,
            select: ['amount'],
        });
        const totalCollected = completedPayments.reduce((sum, p) => sum + Number(p.amount), 0);

        // 3. Risk Indicator (Overdue vs Total active)
        const overdueWhere: any = { status: 'pending', dueDate: LessThan(new Date()) };
        if (storeId) overdueWhere.storeId = storeId;
        const overdueCount = await this.paymentRepository.count({ where: overdueWhere });

        const activeWhere: any = { status: In(['pending', 'completed']) };
        if (storeId) activeWhere.storeId = storeId;
        const totalActiveCount = await this.paymentRepository.count({ where: activeWhere });
        const riskIndicator = totalActiveCount > 0 ? (overdueCount / totalActiveCount) * 100 : 0;

        // 4. Platform Net Commission (Completed payments)
        const commissionWhere: any = { status: 'completed' };
        if (storeId) commissionWhere.storeId = storeId;

        const platformCommission = await this.paymentRepository.find({
            where: commissionWhere,
            select: ['commission'],
        });
        const totalCommission = platformCommission.reduce((sum, p) => sum + Number(p.commission), 0);

        return {
            success: true,
            data: {
                totalFinancedQuarter,
                totalCollected,
                riskIndicator,
                totalCommission,
            }
        };
    }

    async getPerformanceData(storeId?: number) {
        console.log(`[ReportsService] getPerformanceData called with storeId: ${storeId}`);

        if (storeId === undefined || storeId === null || isNaN(storeId)) {
            console.log('[ReportsService] No valid storeId provided for performance. Returning empty list.');
            return { success: true, data: [] };
        }

        const sixMonthsAgo = dayjs().subtract(5, 'month').startOf('month').toDate();

        const query = this.paymentRepository.createQueryBuilder('p')
            .select("DATE_FORMAT(p.createdAt, '%Y-%m')", 'month')
            .addSelect('SUM(p.amount)', 'installments')
            // Calculate total financed amount (sum of totalAmount for only one installment per order to avoid double counting)
            .addSelect('SUM(CASE WHEN p.installmentNumber = 1 THEN p.totalAmount ELSE 0 END)', 'purchases')
            .addSelect("SUM(CASE WHEN p.status = 'pending' AND p.dueDate < NOW() THEN p.amount ELSE 0 END)", 'overdue')
            .where('p.createdAt >= :sixMonthsAgo', { sixMonthsAgo })
            .andWhere('p.storeId = :storeId', { storeId });

        const stats = await query
            .groupBy("DATE_FORMAT(p.createdAt, '%Y-%m')")
            .orderBy('month', 'ASC')
            .getRawMany();

        const performanceData = [];
        for (let i = 5; i >= 0; i--) {
            const date = dayjs().subtract(i, 'month');
            const monthKey = date.format('YYYY-MM');
            const monthLabel = date.format('MMM');

            const monthStat = stats.find(s => s.month === monthKey);

            performanceData.push({
                month: monthLabel,
                purchases: Number(monthStat?.purchases || 0),
                installments: Number(monthStat?.installments || 0),
                overdue: Number(monthStat?.overdue || 0),
            });
        }

        return {
            success: true,
            data: performanceData
        };
    }

    async getRiskDistribution(storeId?: number) {
        console.log(`[ReportsService] getRiskDistribution called with storeId: ${storeId}`);

        if (storeId === undefined || storeId === null || isNaN(storeId)) {
            console.log('[ReportsService] No valid storeId provided for risk. Returning empty distribution.');
            return {
                success: true,
                data: [
                    { label: 'منخفض', value: 0, color: 'text-emerald-300' },
                    { label: 'متوسط', value: 0, color: 'text-amber-300' },
                    { label: 'مرتفع', value: 0, color: 'text-red-300' },
                    { label: 'قيد المراجعة', value: 0, color: 'text-sky-300' },
                ]
            };
        }

        let userIds = [];
        const storePayments = await this.paymentRepository.find({
            where: { storeId },
            select: ['userId'],
        });
        userIds = [...new Set(storePayments.map(p => p.userId))];

        const userWhere: any = {};
        if (userIds.length === 0) {
            return {
                success: true,
                data: [
                    { label: 'منخفض', value: 0, color: 'text-emerald-300' },
                    { label: 'متوسط', value: 0, color: 'text-amber-300' },
                    { label: 'مرتفع', value: 0, color: 'text-red-300' },
                    { label: 'قيد المراجعة', value: 0, color: 'text-sky-300' },
                ]
            };
        }
        userWhere.id = In(userIds);

        const users = await this.userRepository.find({
            where: userWhere,
            relations: ['payments']
        });

        let low = 0, medium = 0, high = 0, review = 0;

        users.forEach(user => {
            // CRITICAL: Filter payments to only include those belonging to the specific store
            const storePayments = storeId
                ? user.payments?.filter(p => Number(p.storeId) === Number(storeId))
                : user.payments;

            const hasOverdue = storePayments?.some(p => p.status === 'pending' && dayjs(p.dueDate).isBefore(dayjs()));
            const hasPostponed = storePayments?.some(p => p.isPostponed);

            if (hasOverdue) high++;
            else if (hasPostponed) medium++;
            else if (storePayments && storePayments.length > 0) low++;
            else review++;
        });

        const total = users.length || 1;
        return {
            success: true,
            data: [
                { label: 'منخفض', value: Math.round((low / total) * 100), color: 'text-emerald-300' },
                { label: 'متوسط', value: Math.round((medium / total) * 100), color: 'text-amber-300' },
                { label: 'مرتفع', value: Math.round((high / total) * 100), color: 'text-red-300' },
                { label: 'قيد المراجعة', value: Math.round((review / total) * 100), color: 'text-sky-300' },
            ]
        };
    }

    async getTopStores() {
        const thirtyDaysAgo = dayjs().subtract(30, 'days').toDate();

        const payments = await this.paymentRepository.find({
            where: { createdAt: Between(thirtyDaysAgo, new Date()) },
            relations: ['store']
        });

        const storeStats = new Map();
        payments.forEach(p => {
            if (!p.store) return;
            const current = storeStats.get(p.store.name) || { store: p.store.name, sales: 0, growth: '+12%' };
            current.sales += Number(p.amount);
            storeStats.set(p.store.name, current);
        });

        return {
            success: true,
            data: Array.from(storeStats.values()).sort((a, b) => b.sales - a.sales).slice(0, 5)
        };
    }

    async getSalesDetailed(storeId: number) {
        console.log(`[ReportsService] getSalesDetailed called for storeId: ${storeId}`);

        // 1. Fetch all approved/completed sessions for this store to get "pieces sold"
        // CRITICAL: Added 'sessionItems' relation to get names and quantities
        const sessions = await this.paymentRepository.manager.getRepository('BnplSession').find({
            where: { storeId, status: In(['approved', 'completed', 'payment_pending']) },
            relations: ['user', 'sessionItems'],
            order: { createdAt: 'DESC' }
        }) as any[];

        // 2. Fetch all payments for this store to calculate collected vs total
        const payments = await this.paymentRepository.find({
            where: { storeId }
        });

        const sales = sessions.map(session => {
            const orderId = `order_${session.sessionId}`;
            const orderPayments = payments.filter(p => p.orderId === orderId);

            const totalAmount = Number(session.totalAmount || 0);
            
            // Gross amount received so far
            const grossCollected = orderPayments
                .filter(p => p.status === 'completed')
                .reduce((sum, p) => sum + Number(p.amount || 0), 0);
            
            // Net amount received so far (Paid minus Commission)
            const collectedAmount = orderPayments
                .filter(p => p.status === 'completed')
                .reduce((sum, p) => sum + Number(p.storeAmount || 0), 0);

            // Total commission for the whole order (from all payments)
            const totalCommission = orderPayments.reduce((sum, p) => sum + Number(p.commission || 0), 0);
            
            // Final net amount the vendor will get when all installments are paid
            const netAmount = totalAmount - totalCommission;

            // Sum up quantities from sessionItems (which we now have via relations)
            const piecesSold = (session.sessionItems || []).reduce((sum, item) => sum + (Number(item.quantity || 1)), 0);

            return {
                id: session.id,
                orderId: session.storeOrderId || session.sessionId,
                customerName: session.customerName || (session.user ? session.user.name : 'Unknown'),
                customerPhone: session.customerPhone || (session.user ? session.user.phone : ''),
                totalAmount,           // Gross total
                netAmount,             // Target net total
                collectedAmount,        // Net collected so far (the one Vender UI uses for collections)
                grossCollected,        // Gross collected so far
                totalCommission,        // Total deducted commission
                piecesSold,
                status: session.status,
                createdAt: session.createdAt,
                // Map sessionItems to items for the frontend
                items: (session.sessionItems || []).map(item => ({
                    name: item.name,
                    quantity: item.quantity,
                    price: item.price
                }))
            };
        });

        const totalPiecesSold = sales.reduce((sum, s) => sum + s.piecesSold, 0);
        const totalVolume = sales.reduce((sum, s) => sum + s.totalAmount, 0);
        
        // metrics.totalCollected should represent the NET amount the vendor actually received
        const totalCollected = sales.reduce((sum, s) => sum + s.collectedAmount, 0);

        return {
            success: true,
            data: {
                metrics: {
                    totalPiecesSold,
                    totalVolume,
                    totalCollected,
                    totalOrders: sales.length,
                    totalCustomers: new Set(sales.map(s => s.customerPhone)).size
                },
                sales
            }
        };
    }
}
