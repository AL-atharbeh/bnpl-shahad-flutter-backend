import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BnplSession, SessionStatus } from './entities/bnpl-session.entity';
import { CreateSessionDto } from './dto/create-session.dto';
import { SessionResponseDto, SessionDetailsDto } from './dto/session-response.dto';
import { Store } from '../stores/entities/store.entity';
import { PaymentsService } from '../payments/payments.service';
import { MockPaymentService } from '../payments/mock-payment.service';
import { UsersService } from '../users/users.service';
import { v4 as uuidv4 } from 'uuid';
import * as dayjs from 'dayjs';

@Injectable()
export class BnplSessionsService {
    constructor(
        @InjectRepository(BnplSession)
        private sessionRepository: Repository<BnplSession>,
        @InjectRepository(Store)
        private storeRepository: Repository<Store>,
        private paymentsService: PaymentsService,
        private usersService: UsersService,
        private mockPaymentService: MockPaymentService,
    ) { }

    async createSession(
        storeId: number,
        createSessionDto: CreateSessionDto,
    ): Promise<SessionResponseDto> {
        const store = await this.storeRepository.findOne({ where: { id: storeId } });
        if (!store) {
            throw new NotFoundException('المتجر غير موجود');
        }

        const sessionId = `sess_${uuidv4().replace(/-/g, '')}`;
        const expiresAt = dayjs().add(30, 'minutes').toDate();

        const session = this.sessionRepository.create({
            sessionId,
            storeId,
            storeOrderId: createSessionDto.store_order_id,
            totalAmount: createSessionDto.total_amount,
            currency: createSessionDto.currency || 'JOD',
            installmentsCount: createSessionDto.installments_count || 4,
            customerPhone: createSessionDto.customer_phone,
            customerEmail: createSessionDto.customer_email,
            customerName: createSessionDto.customer_name,
            items: createSessionDto.items || [],
            successUrl: createSessionDto.success_url,
            cancelUrl: createSessionDto.cancel_url,
            webhookUrl: createSessionDto.webhook_url,
            metadata: createSessionDto.metadata,
            status: SessionStatus.PENDING,
            expiresAt,
        });

        await this.sessionRepository.save(session);

        return {
            success: true,
            session_id: sessionId,
            redirect_url: `bnpl://session?id=${sessionId}`,
            web_redirect_url: `${process.env.APP_URL || 'https://yourapp.com'}/session/${sessionId}`,
            expires_at: expiresAt,
        };
    }

    async getSession(sessionId: string): Promise<SessionDetailsDto> {
        const session = await this.sessionRepository.findOne({
            where: { sessionId },
            relations: ['store'],
        });

        if (!session) {
            throw new NotFoundException('الجلسة غير موجودة');
        }

        if (session.status === SessionStatus.PENDING && dayjs().isAfter(session.expiresAt)) {
            session.status = SessionStatus.EXPIRED;
            await this.sessionRepository.save(session);
            throw new BadRequestException('انتهت صلاحية الجلسة');
        }

        return {
            session_id: session.sessionId,
            store: {
                id: session.store.id,
                name: session.store.name,
                nameAr: session.store.nameAr,
                logoUrl: session.store.logoUrl,
            },
            total_amount: Number(session.totalAmount),
            currency: session.currency,
            installments_count: session.installmentsCount,
            items: session.items || [],
            status: session.status,
            created_at: session.createdAt,
            expires_at: session.expiresAt,
        };
    }

    async approveSession(sessionId: string, userId: number): Promise<any> {
        console.log('Approve session - User from JWT:', { id: userId });
        console.log('Approve session - Extracted userId:', userId);

        const session = await this.sessionRepository.findOne({
            where: { sessionId },
        });

        if (!session) {
            throw new NotFoundException('الجلسة غير موجودة');
        }

        // If session is PENDING, just set userId and keep it PENDING
        if (session.status === SessionStatus.PENDING) {
            session.userId = userId;
            session.customerPhone = session.customerPhone || '+962000000000';
            session.customerEmail = session.customerEmail || 'customer@example.com';
            session.customerName = session.customerName || 'Customer';
            session.approvedAt = new Date();

            await this.sessionRepository.save(session);
            console.log('✅ Session approved (PENDING → userId set):', sessionId);

            return {
                success: true,
                message: 'تمت الموافقة على الطلب',
                session_id: sessionId,
            };
        }

        // If session is PAYMENT_PENDING, approve it and mark first installment as completed
        if (session.status === SessionStatus.PAYMENT_PENDING) {
            session.status = SessionStatus.APPROVED;
            session.approvedAt = new Date();

            await this.sessionRepository.save(session);
            console.log('✅ Session approved (PAYMENT_PENDING → APPROVED):', sessionId);

            // Auto-complete first installment
            const orderId = `order_${sessionId}`;
            try {
                await this.paymentsService.markFirstInstallmentCompleted(orderId);
                console.log('✅ First installment auto-completed for:', orderId);
            } catch (error) {
                console.error('⚠️ Failed to auto-complete first installment:', error.message);
            }

            return {
                success: true,
                message: 'تمت الموافقة على الطلب',
                session_id: sessionId,
            };
        }

        // Already approved
        return {
            success: true,
            message: 'تمت الموافقة على الطلب',
            session_id: sessionId,
        };
    }

    async completeSession(sessionId: string): Promise<any> {
        const session = await this.sessionRepository.findOne({
            where: { sessionId },
        });

        if (!session) {
            throw new NotFoundException('الجلسة غير موجودة');
        }

        // Allow PENDING sessions (user verified but not yet approved)
        // Session will be approved AFTER successful payment
        if (session.status !== SessionStatus.PENDING && session.status !== SessionStatus.APPROVED) {
            throw new BadRequestException('حالة الجلسة غير صالحة');
        }

        // Validate userId exists
        if (!session.userId) {
            throw new BadRequestException('لا يوجد مستخدم مرتبط بهذه الجلسة. يجب الموافقة على الجلسة أولاً.');
        }

        const installmentAmount = Number(session.totalAmount) / session.installmentsCount;
        const orderId = `order_${session.sessionId}`;

        const installments = [];

        try {
            // Create ALL installments as 'pending' (including first one)
            for (let i = 1; i <= session.installmentsCount; i++) {
                const dueDate = dayjs().add(i - 1, 'month').toDate();

                const payment = await this.paymentsService.createPayment({
                    userId: session.userId,
                    storeId: session.storeId,
                    orderId: orderId,
                    amount: installmentAmount,
                    currency: session.currency,
                    installmentsCount: session.installmentsCount,
                    installmentNumber: i,
                    totalAmount: Number(session.totalAmount),
                    paymentMethod: 'bnpl',
                    status: 'pending', // ALL pending initially
                    dueDate: dueDate,
                    paidAt: null,
                });

                installments.push(payment);
            }

            // Generate payment URL for first installment (MOCK)
            console.log('💳 Generating MOCK payment URL for testing...');

            const paymentResponse = await this.mockPaymentService.executePayment({
                amount: installmentAmount,
                currency: session.currency,
                customerName: session.customerName || 'Customer',
                customerEmail: session.customerEmail || 'customer@example.com',
                customerPhone: session.customerPhone || '+962790000000',
                customerReference: sessionId,
            });

            console.log('✅ Mock Payment URL generated:', paymentResponse.Data.PaymentURL);

            // Update session status to PAYMENT_PENDING
            session.status = SessionStatus.PAYMENT_PENDING;
            await this.sessionRepository.save(session);

            return {
                success: true,
                payment_required: true,
                payment_url: paymentResponse.Data.PaymentURL,
                message: 'يرجى إكمال دفع القسط الأول',
                order_id: orderId,
                first_installment: {
                    amount: installmentAmount,
                    currency: session.currency,
                },
                installments: installments.map(p => ({
                    installment_number: p.installmentNumber,
                    amount: p.amount,
                    due_date: p.dueDate,
                    status: p.status,
                })),
            };
        } catch (error) {
            console.error('❌ Error in completeSession:', error);
            throw new BadRequestException(`فشل في إنشاء الأقساط: ${error.message}`);
        }
    }

    async rejectSession(sessionId: string): Promise<any> {
        const session = await this.sessionRepository.findOne({
            where: { sessionId },
        });

        if (!session) {
            throw new NotFoundException('الجلسة غير موجودة');
        }

        session.status = SessionStatus.REJECTED;
        await this.sessionRepository.save(session);

        return {
            success: true,
            message: 'تم رفض الطلب',
        };
    }

    // Admin methods
    async getAdminStats() {
        const totalSessions = await this.sessionRepository.count();

        // Sessions in last 7 days
        const sevenDaysAgo = dayjs().subtract(7, 'days').toDate();
        const newSessions = await this.sessionRepository.count({
            where: {
                createdAt: dayjs(sevenDaysAgo).toDate() as any,
            },
        });

        // Count by status
        const approvedCount = await this.sessionRepository.count({ where: { status: SessionStatus.APPROVED } });
        const pendingCount = await this.sessionRepository.count({ where: { status: SessionStatus.PENDING } });
        const rejectedCount = await this.sessionRepository.count({ where: { status: SessionStatus.REJECTED } });
        const paymentPendingCount = await this.sessionRepository.count({ where: { status: SessionStatus.PAYMENT_PENDING } });

        // Total transaction value (approved sessions only)
        const approvedSessions = await this.sessionRepository.find({
            where: { status: SessionStatus.APPROVED },
        });
        const totalValue = approvedSessions.reduce((sum, s) => sum + Number(s.totalAmount), 0);

        return {
            success: true,
            data: {
                totalSessions,
                newSessions,
                approvedSessions: approvedCount,
                pendingSessions: pendingCount,
                rejectedSessions: rejectedCount,
                paymentPendingSessions: paymentPendingCount,
                totalTransactionValue: totalValue,
            },
        };
    }

    async getAllSessionsForAdmin(filters: {
        page: number;
        limit: number;
        status?: string;
        storeId?: number;
        userId?: number;
        startDate?: string;
        endDate?: string;
    }) {
        const { page, limit, status, storeId, userId, startDate, endDate } = filters;
        const skip = (page - 1) * limit;

        const queryBuilder = this.sessionRepository
            .createQueryBuilder('session')
            .leftJoinAndSelect('session.store', 'store')
            .leftJoinAndSelect('session.user', 'user');

        if (status) {
            queryBuilder.andWhere('session.status = :status', { status });
        }

        if (storeId) {
            queryBuilder.andWhere('session.storeId = :storeId', { storeId });
        }

        if (userId) {
            queryBuilder.andWhere('session.userId = :userId', { userId });
        }

        if (startDate) {
            queryBuilder.andWhere('session.createdAt >= :startDate', { startDate });
        }

        if (endDate) {
            queryBuilder.andWhere('session.createdAt <= :endDate', { endDate });
        }

        const [sessions, total] = await queryBuilder
            .orderBy('session.createdAt', 'DESC')
            .skip(skip)
            .take(limit)
            .getManyAndCount();

        return {
            success: true,
            data: sessions,
            pagination: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getChartData() {
        // Get last 7 days including today
        const sevenDaysAgo = dayjs().subtract(6, 'days').startOf('day');
        const sessions = await this.sessionRepository
            .createQueryBuilder('session')
            .where('session.createdAt >= :startDate', { startDate: sevenDaysAgo.toDate() })
            .getMany();

        // Group by day
        const chartData = [];
        for (let i = 0; i < 7; i++) {
            const date = sevenDaysAgo.add(i, 'day');
            const dayStart = date.startOf('day').toDate();
            const dayEnd = date.endOf('day').toDate();

            const daySessions = sessions.filter(s => {
                const createdAt = new Date(s.createdAt).getTime();
                const start = dayStart.getTime();
                const end = dayEnd.getTime();
                return createdAt >= start && createdAt <= end;
            });

            chartData.push({
                date: date.format('YYYY-MM-DD'),
                day: date.format('ddd'),
                count: daySessions.length,
                approved: daySessions.filter(s => s.status === SessionStatus.APPROVED).length,
                pending: daySessions.filter(s => s.status === SessionStatus.PENDING).length,
                rejected: daySessions.filter(s => s.status === SessionStatus.REJECTED).length,
            });
        }

        return {
            success: true,
            data: chartData,
        };
    }
}
