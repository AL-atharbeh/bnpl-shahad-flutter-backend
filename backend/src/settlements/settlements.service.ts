import { VendorNotificationsService } from '../vendors/vendor-notifications.service';
import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, IsNull } from 'typeorm';
import { Settlement } from './entities/settlement.entity';
import { Payment } from '../payments/entities/payment.entity';
import { Store } from '../stores/entities/store.entity';
import { BnplSession } from '../bnpl-sessions/entities/bnpl-session.entity';
import { UsersService } from '../users/users.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CommissionSettingsService } from '../commission-settings/commission-settings.service';

@Injectable()
export class SettlementsService {
    constructor(
        @InjectRepository(Settlement)
        private settlementRepository: Repository<Settlement>,
        @InjectRepository(Payment)
        private paymentRepository: Repository<Payment>,
        @InjectRepository(Store)
        private storeRepository: Repository<Store>,
        @InjectRepository(BnplSession)
        private sessionRepository: Repository<BnplSession>,
        private usersService: UsersService,
        private notificationsService: NotificationsService,
        private commissionSettingsService: CommissionSettingsService,
        private readonly vendorNotifications: VendorNotificationsService,
    ) { }

    private normalizeRate(val: any, fallback: number) {
        if (val === null || val === undefined) return fallback;
        const num = Number(val);
        return num >= 1 ? num / 100 : num;
    }

    async getSettlementStats(storeId: number) {
        // 1. Get all approved/completed sessions for this store that are NOT yet settled
        const pendingSessions = await this.sessionRepository.find({
            where: {
                storeId,
                status: In(['approved', 'completed', 'payment_pending']),
                settlementId: IsNull(),
            },
        });

        // Load settings and payments to calculate net amounts accurately
        const settingsRes = await this.commissionSettingsService.getCurrentSettings();
        const globalBankRate = settingsRes?.data?.bankCommission ? Number(settingsRes.data.bankCommission) : 0.03;
        const globalPlatformRate = settingsRes?.data?.platformCommission ? Number(settingsRes.data.platformCommission) : 0.02;

        const payments = await this.paymentRepository.find({
            where: { storeId }
        });

        let pendingBalance = 0;
        for (const session of pendingSessions) {
            const totalAmount = Number(session.totalAmount || 0);
            const orderId = `order_${session.sessionId}`;
            const orderPayments = payments.filter(p => p.orderId === orderId);

            const sessionCommission = orderPayments.reduce((sum, p) => {
                const amount = Number(p.amount || 0);
                const bRate = this.normalizeRate(p.store?.bankCommissionRate ?? p.bankCommissionRate, globalBankRate);
                const pRate = this.normalizeRate(p.store?.platformCommissionRate ?? p.platformCommissionRate, globalPlatformRate);
                return sum + amount * (bRate + pRate);
            }, 0);

            const netAmount = totalAmount - sessionCommission;
            pendingBalance += netAmount;
        }

        // 2. Get Last Transfer (Most recent completed settlement for this store)
        const lastSettlement = await this.settlementRepository.findOne({
            where: { storeId, status: 'completed' },
            order: { settlementDate: 'DESC' },
        });

        return {
            success: true,
            data: {
                pendingBalance: Number(pendingBalance.toFixed(2)),
                lastTransfer: lastSettlement ? {
                    amount: Number(lastSettlement.totalCollected) - Number(lastSettlement.bankShare) - Number(lastSettlement.platformShare),
                    date: lastSettlement.settlementDate
                } : null
            }
        };
    }

    /** A store's own settlements, newest first, with what it received from each. */
    async getStoreSettlementHistory(storeId: number, page = 1, limit = 20) {
        page = Math.max(1, page || 1);
        limit = Math.min(Math.max(1, limit || 20), 100);
        const [settlements, total] = await this.settlementRepository.findAndCount({
            where: { storeId },
            relations: ['sessions'],
            order: { createdAt: 'DESC' },
            skip: (page - 1) * limit,
            take: limit,
        });
        return {
            success: true,
            data: {
                settlements: settlements.map((s) => ({
                    id: s.id,
                    status: s.status,
                    requestedAt: s.createdAt,
                    settlementDate: s.settlementDate,
                    totalCollected: Number(s.totalCollected),
                    bankShare: Number(s.bankShare),
                    platformShare: Number(s.platformShare),
                    netAmount: Number((Number(s.totalCollected) - Number(s.bankShare) - Number(s.platformShare)).toFixed(2)),
                    ordersCount: s.sessions?.length || 0,
                    notes: s.notes,
                })),
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getAllSettlements(filters: { page: number; limit: number; storeId?: number; status?: string }) {
        const { page, limit, storeId, status } = filters;
        const skip = (page - 1) * limit;

        const where: any = {};
        const hasStoreId = storeId !== undefined && storeId !== null && !isNaN(storeId);
        if (hasStoreId) {
            where.storeId = storeId;
        }
        if (status) {
            where.status = status;
        }

        const [settlements, total] = await this.settlementRepository.findAndCount({
            where,
            relations: ['store', 'sessions'],
            order: { createdAt: 'DESC' },
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
        storeId: number;
        sessionIds: number[];
        notes?: string;
    }) {
        const { storeId, sessionIds, notes } = data;

        if (!sessionIds || sessionIds.length === 0) {
            throw new BadRequestException('يجب تحديد عملية واحدة على الأقل لإجراء التسوية.');
        }

        // Find the sessions to settle
        const sessions = await this.sessionRepository.find({
            where: {
                id: In(sessionIds),
                storeId,
                status: In(['approved', 'completed', 'payment_pending']),
                settlementId: IsNull(),
            }
        });

        if (sessions.length === 0) {
            throw new BadRequestException('العمليات المحددة غير موجودة أو تم تسويتها مسبقاً.');
        }

        const settingsRes = await this.commissionSettingsService.getCurrentSettings();
        const globalBankRate = settingsRes?.data?.bankCommission ? Number(settingsRes.data.bankCommission) : 0.03;
        const globalPlatformRate = settingsRes?.data?.platformCommission ? Number(settingsRes.data.platformCommission) : 0.02;

        const payments = await this.paymentRepository.find({
            where: { storeId }
        });

        let totalCollected = 0; // Gross total
        let bankShare = 0;
        let platformShare = 0;

        for (const session of sessions) {
            const totalAmount = Number(session.totalAmount || 0);
            totalCollected += totalAmount;

            const orderId = `order_${session.sessionId}`;
            const orderPayments = payments.filter(p => p.orderId === orderId);

            const sessionBankCommission = orderPayments.reduce((sum, p) => {
                const amount = Number(p.amount || 0);
                const bRate = this.normalizeRate(p.store?.bankCommissionRate ?? p.bankCommissionRate, globalBankRate);
                return sum + amount * bRate;
            }, 0);

            const sessionPlatformCommission = orderPayments.reduce((sum, p) => {
                const amount = Number(p.amount || 0);
                const pRate = this.normalizeRate(p.store?.platformCommissionRate ?? p.platformCommissionRate, globalPlatformRate);
                return sum + amount * pRate;
            }, 0);

            bankShare += sessionBankCommission;
            platformShare += sessionPlatformCommission;
        }

        const settlement = this.settlementRepository.create({
            settlementDate: new Date(),
            totalCollected,
            bankShare,
            platformShare,
            status: 'completed',
            storeId,
            notes: notes || 'تسوية يدوية للعمليات المحددة',
        });

        const savedSettlement = await this.settlementRepository.save(settlement);

        // Link sessions to this settlement
        for (const session of sessions) {
            session.settlementId = savedSettlement.id;
            await this.sessionRepository.save(session);
        }

        return {
            success: true,
            message: 'تمت التسوية للعمليات المحددة بنجاح',
            data: savedSettlement,
        };
    }

    async getStoreOutstandingOrders(storeId: number) {
        const sessions = await this.sessionRepository.find({
            where: {
                storeId,
                status: In(['approved', 'completed', 'payment_pending']),
                settlementId: IsNull(),
            },
            relations: ['user', 'store']
        });

        const settingsRes = await this.commissionSettingsService.getCurrentSettings();
        const globalBankRate = settingsRes?.data?.bankCommission ? Number(settingsRes.data.bankCommission) : 0.03;
        const globalPlatformRate = settingsRes?.data?.platformCommission ? Number(settingsRes.data.platformCommission) : 0.02;

        const payments = await this.paymentRepository.find({
            where: { storeId }
        });

        const results = [];
        for (const session of sessions) {
            const totalAmount = Number(session.totalAmount || 0);
            const orderId = `order_${session.sessionId}`;
            const orderPayments = payments.filter(p => p.orderId === orderId);

            const bankShare = orderPayments.reduce((sum, p) => {
                const amount = Number(p.amount || 0);
                const bRate = this.normalizeRate(p.store?.bankCommissionRate ?? p.bankCommissionRate, globalBankRate);
                return sum + amount * bRate;
            }, 0);

            const platformShare = orderPayments.reduce((sum, p) => {
                const amount = Number(p.amount || 0);
                const pRate = this.normalizeRate(p.store?.platformCommissionRate ?? p.platformCommissionRate, globalPlatformRate);
                return sum + amount * pRate;
            }, 0);

            const totalCommission = bankShare + platformShare;
            const netAmount = totalAmount - totalCommission;

            results.push({
                id: session.id,
                sessionId: session.sessionId,
                storeOrderId: session.storeOrderId,
                customerName: session.customerName || (session.user ? session.user.name : 'عميل غير معروف'),
                totalAmount: Number(totalAmount.toFixed(2)),
                bankShare: Number(bankShare.toFixed(2)),
                platformShare: Number(platformShare.toFixed(2)),
                totalCommission: Number(totalCommission.toFixed(2)),
                netAmount: Number(netAmount.toFixed(2)),
                createdAt: session.createdAt,
            });
        }

        return {
            success: true,
            data: results,
        };
    }

    async getSettlementById(id: number) {
        const settlement = await this.settlementRepository.findOne({
            where: { id },
            relations: ['store', 'sessions'],
        });

        return {
            success: true,
            data: settlement,
        };
    }

    async requestSettlement(storeId: number, vendorName: string) {
        // 1. Find all approved sessions for this store that are NOT yet settled
        const pendingSessions = await this.sessionRepository.find({
            where: {
                storeId,
                status: In(['approved', 'completed', 'payment_pending']),
                settlementId: IsNull(),
            },
        });

        if (pendingSessions.length === 0) {
            throw new BadRequestException('لا توجد مبيعات نشطة غير مسواة وجاهزة للتسوية حالياً لهذا المتجر.');
        }

        // 2. Load settings and payments to calculate commission splits upfront
        const settingsRes = await this.commissionSettingsService.getCurrentSettings();
        const globalBankRate = settingsRes?.data?.bankCommission ? Number(settingsRes.data.bankCommission) : 0.03;
        const globalPlatformRate = settingsRes?.data?.platformCommission ? Number(settingsRes.data.platformCommission) : 0.02;

        const payments = await this.paymentRepository.find({
            where: { storeId }
        });

        let totalCollected = 0; // Gross volume
        let bankShare = 0;
        let platformShare = 0;

        for (const session of pendingSessions) {
            const totalAmount = Number(session.totalAmount || 0);
            totalCollected += totalAmount;

            const orderId = `order_${session.sessionId}`;
            const orderPayments = payments.filter(p => p.orderId === orderId);

            const sessionBankCommission = orderPayments.reduce((sum, p) => {
                const amount = Number(p.amount || 0);
                const bRate = this.normalizeRate(p.store?.bankCommissionRate ?? p.bankCommissionRate, globalBankRate);
                return sum + amount * bRate;
            }, 0);

            const sessionPlatformCommission = orderPayments.reduce((sum, p) => {
                const amount = Number(p.amount || 0);
                const pRate = this.normalizeRate(p.store?.platformCommissionRate ?? p.platformCommissionRate, globalPlatformRate);
                return sum + amount * pRate;
            }, 0);

            bankShare += sessionBankCommission;
            platformShare += sessionPlatformCommission;
        }

        // 3. Create the pending settlement record
        const settlement = this.settlementRepository.create({
            settlementDate: new Date(),
            totalCollected,
            bankShare,
            platformShare,
            status: 'pending',
            storeId,
            notes: `طلب تسوية فورية مقدم من المورد ${vendorName}`,
        });

        const savedSettlement = await this.settlementRepository.save(settlement);

        // 4. Link sessions to this settlement
        for (const session of pendingSessions) {
            session.settlementId = savedSettlement.id;
            await this.sessionRepository.save(session);
        }

        // 5. Find all admins
        let admins = await this.usersService.findAllAdmins();
        if (admins.length === 0) {
            const user1 = await this.usersService.findById(1).catch(() => null);
            if (user1) {
                admins = [user1];
            }
        }

        // Send notification to admins
        const title = 'طلب تسوية جديد 🏦';
        const body = `قام المورد ${vendorName} بطلب تسوية بقيمة ${totalCollected.toFixed(2)} JOD`;
        const data = {
            type: 'settlement_request',
            storeId: storeId.toString(),
            vendorName: vendorName,
            settlementId: savedSettlement.id.toString(),
        };

        for (const admin of admins) {
            await this.notificationsService.sendToUser(admin.id, title, body, data, 'urgent');
        }

        return {
            success: true,
            message: 'تم إرسال طلب التسوية بنجاح وتسجيله في النظام كمعلق',
            data: savedSettlement,
        };
    }

    async updateSettlementStatus(id: number, status: string, notes?: string) {
        const settlement = await this.settlementRepository.findOne({
            where: { id },
        });

        if (!settlement) {
            throw new BadRequestException('التسوية غير موجودة');
        }

        const previousStatus = settlement.status;
        settlement.status = status;
        if (notes) {
            settlement.notes = notes;
        }

        if (status === 'completed') {
            settlement.settlementDate = new Date();
        }

        await this.settlementRepository.save(settlement);

        if (settlement.storeId && previousStatus !== status && (status === 'completed' || status === 'failed')) {
            const net = (Number(settlement.totalCollected) - Number(settlement.bankShare) - Number(settlement.platformShare)).toFixed(2);
            await this.vendorNotifications.notifyStore(settlement.storeId, status === 'completed'
                ? {
                    type: 'settlement_completed',
                    title: 'تم تحويل مستحقاتك 💰',
                    body: `حُوّل ${net} دينار إلى حسابك البنكي (تسوية رقم ${settlement.id}).`,
                    titleEn: 'Your payout was sent 💰',
                    bodyEn: `JOD ${net} was transferred to your bank account (settlement #${settlement.id}).`,
                    data: { settlementId: settlement.id, amount: Number(net) },
                }
                : {
                    type: 'settlement_failed',
                    title: 'تعذّر تحويل التسوية',
                    body: `لم يكتمل تحويل التسوية رقم ${settlement.id}${notes ? `: ${notes}` : ''}. ستعود الطلبات لرصيدك المعلّق.`,
                    titleEn: 'A payout could not be sent',
                    bodyEn: `Settlement #${settlement.id} was not transferred${notes ? `: ${notes}` : ''}. Its orders return to your pending balance.`,
                    data: { settlementId: settlement.id },
                });
        }

        // If settlement failed or was rejected, release the sessions back into the pool
        if (status === 'failed' || status === 'rejected') {
            const sessions = await this.sessionRepository.find({
                where: { settlementId: id }
            });
            for (const session of sessions) {
                session.settlementId = null;
                await this.sessionRepository.save(session);
            }
        }

        return {
            success: true,
            message: 'تم تحديث حالة التسوية بنجاح',
            data: settlement,
        };
    }

    async getStoresBalances() {
        const stores = await this.storeRepository.find();
        const settingsRes = await this.commissionSettingsService.getCurrentSettings();
        const globalBankRate = settingsRes?.data?.bankCommission ? Number(settingsRes.data.bankCommission) : 0.03;
        const globalPlatformRate = settingsRes?.data?.platformCommission ? Number(settingsRes.data.platformCommission) : 0.02;

        const results = [];
        for (const store of stores) {
            // Find all approved sessions
            const sessions = await this.sessionRepository.find({
                where: {
                    storeId: store.id,
                    status: In(['approved', 'completed', 'payment_pending'])
                }
            });

            const payments = await this.paymentRepository.find({
                where: { storeId: store.id }
            });

            let totalGross = 0;
            let totalCommission = 0;

            for (const session of sessions) {
                const totalAmount = Number(session.totalAmount || 0);
                totalGross += totalAmount;

                const orderId = `order_${session.sessionId}`;
                const orderPayments = payments.filter(p => p.orderId === orderId);

                const sessionCommission = orderPayments.reduce((sum, p) => {
                    const amount = Number(p.amount || 0);
                    const bRate = this.normalizeRate(p.store?.bankCommissionRate ?? p.bankCommissionRate, globalBankRate);
                    const pRate = this.normalizeRate(p.store?.platformCommissionRate ?? p.platformCommissionRate, globalPlatformRate);
                    return sum + amount * (bRate + pRate);
                }, 0);

                totalCommission += sessionCommission;
            }

            const totalNetOwed = totalGross - totalCommission;

            // Total Paid (completed settlements)
            const completedSettlements = await this.settlementRepository.find({
                where: { storeId: store.id, status: 'completed' }
            });
            const totalPaid = completedSettlements.reduce((sum, s) => {
                return sum + (Number(s.totalCollected || 0) - Number(s.bankShare || 0) - Number(s.platformShare || 0));
            }, 0);

            const outstandingBalance = totalNetOwed - totalPaid;

            results.push({
                storeId: store.id,
                storeName: store.nameAr || store.name,
                totalGross: Number(totalGross.toFixed(2)),
                totalCommission: Number(totalCommission.toFixed(2)),
                totalNetOwed: Number(totalNetOwed.toFixed(2)),
                totalPaid: Number(totalPaid.toFixed(2)),
                outstandingBalance: Number(Math.max(0, outstandingBalance).toFixed(2)),
            });
        }

        return {
            success: true,
            data: results,
        };
    }
}
