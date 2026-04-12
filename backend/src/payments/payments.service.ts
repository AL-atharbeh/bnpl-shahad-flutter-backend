import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Payment } from './entities/payment.entity';
import { Store } from '../stores/entities/store.entity';
import { RewardsService } from '../rewards/rewards.service';
import { CommissionSettingsService } from '../commission-settings/commission-settings.service';
import dayjs from 'dayjs';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
    private rewardsService: RewardsService,
    private commissionSettingsService: CommissionSettingsService,
  ) { }

  /**
   * Get all payments for a user (only from approved sessions)
   */
  async getUserPayments(userId: number): Promise<Payment[]> {
    return this.paymentRepository
      .createQueryBuilder('payment')
      .leftJoin('bnpl_sessions', 'session', 'payment.order_id = session.store_order_id')
      .where('payment.user_id = :userId', { userId })
      .andWhere('session.status = :status', { status: 'approved' })
      .leftJoinAndSelect('payment.store', 'store')
      .orderBy('payment.created_at', 'DESC')
      .getMany();
  }

  /**
   * Get pending payments for a user with optional installment filters
   * Only returns the next required installment for each order (first unpaid installment)
   * Example: If installment 1 is unpaid, show only installment 1. 
   *          If installment 1 is paid but 2 is unpaid, show only installment 2.
   */
  async getPendingPayments(
    userId: number,
    installmentNumber?: number,
    installmentsCount?: number,
    nextOnly: boolean = true,
  ): Promise<Payment[]> {
    // Get all payments for the user (both pending and completed) grouped by orderId
    const allPayments = await this.paymentRepository.find({
      where: { userId },
      relations: ['store', 'user'],
      order: {
        orderId: 'ASC',
        installmentNumber: 'ASC',
      },
    });

    // Group payments by orderId
    const paymentsByOrder = new Map<string, Payment[]>();
    for (const payment of allPayments) {
      const orderId = payment.orderId || 'no-order';
      if (!paymentsByOrder.has(orderId)) {
        paymentsByOrder.set(orderId, []);
      }
      paymentsByOrder.get(orderId)!.push(payment);
    }

    // For each order, find the first unpaid installment
    const nextRequiredPayments: Payment[] = [];

    for (const [orderId, payments] of paymentsByOrder.entries()) {
      if (orderId === 'no-order') {
        // Include all pending payments without orderId
        const pendingWithoutOrder = payments.filter(p => p.status === 'pending');
        nextRequiredPayments.push(...pendingWithoutOrder);
        continue;
      }

      // Find the first unpaid installment for this order
      // Check installments sequentially: 1, 2, 3, 4
      for (let i = 1; i <= 4; i++) {
        const installment = payments.find(p => p.installmentNumber === i);

        if (!installment) {
          // This installment doesn't exist, stop checking
          break;
        }

        // Check if this installment is paid or postponed
        if (installment.status === 'completed') {
          // This installment is paid, check the next one
          continue;
        } else if (installment.isPostponed) {
          // This installment is postponed, check the next one or include if nextOnly is false
          if (!nextOnly && installment.status === 'pending') {
             nextRequiredPayments.push(installment);
          }
          continue;
        } else {
          // This is an unpaid installment
          nextRequiredPayments.push(installment);
          
          if (nextOnly) {
            // Stop after finding the FIRST unpaid installment
            break;
          }
        }
      }
    }

    // Apply optional filters
    let filteredPayments = nextRequiredPayments;

    if (installmentNumber !== undefined) {
      filteredPayments = filteredPayments.filter(p => p.installmentNumber === installmentNumber);
    }

    if (installmentsCount !== undefined) {
      filteredPayments = filteredPayments.filter(p => p.installmentsCount === installmentsCount);
    }

    // Sort final result by effective due date (nearest first)
    // Use postponedDueDate if payment is postponed, otherwise use dueDate
    filteredPayments.sort((a, b) => {
      const aEffectiveDate = a.isPostponed && a.postponedDueDate ? a.postponedDueDate : a.dueDate;
      const bEffectiveDate = b.isPostponed && b.postponedDueDate ? b.postponedDueDate : b.dueDate;

      return new Date(aEffectiveDate).getTime() - new Date(bEffectiveDate).getTime();
    });

    console.log(`[PaymentsService] Found ${filteredPayments.length} next required payments for user ${userId} (from ${allPayments.length} total payments)`);
    filteredPayments.forEach((p, i) => {
      console.log(`  Payment ${i + 1}: ID=${p.id}, Order=${p.orderId}, Amount=${p.amount}, Store=${p.store?.name || 'No store'}`);
      console.log(`    Installment: ${p.installmentNumber} of ${p.installmentsCount}, Status: ${p.status}`);
    });

    return filteredPayments;
  }

  /**
   * Get payment history with filters including installments
   */
  async getPaymentHistory(
    userId: number,
    startDate?: string,
    endDate?: string,
    status?: string,
    installmentNumber?: number,
    installmentsCount?: number,
  ): Promise<Payment[]> {
    const query: any = { userId };

    if (status) {
      query.status = status;
    }

    if (installmentNumber !== undefined) {
      query.installmentNumber = installmentNumber;
    }

    if (installmentsCount !== undefined) {
      query.installmentsCount = installmentsCount;
    }

    if (startDate && endDate) {
      query.createdAt = Between(new Date(startDate), new Date(endDate));
    }

    return this.paymentRepository.find({
      where: query,
      relations: ['store'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Format payment response with installment info
   */
  formatPaymentResponse(payment: Payment): any {
    const storeName = payment.store?.nameAr || payment.store?.name || 'متجر غير معروف';
    const storeNameAr = payment.store?.nameAr || 'متجر غير معروف';
    const storeNameEn = payment.store?.name || 'Unknown Store';
    const installmentInfo = payment.installmentsCount > 1
      ? `دفعة ${payment.installmentNumber} من ${payment.installmentsCount}`
      : 'دفعة واحدة';

    return {
      ...payment,
      orderId: payment.orderId, // Important: Include orderId to link installments together
      installmentInfo,
      displayName: `${storeName} - ${installmentInfo}`,
      merchantName: storeName,
      storeName: storeNameEn,
      storeNameAr: storeNameAr,
      store: payment.store ? {
        id: payment.store.id,
        name: payment.store.name,
        nameAr: payment.store.nameAr,
        logoUrl: payment.store.logoUrl,
      } : null,
    };
  }

  /**
   * Get payment by ID
   */
  async getPaymentById(id: number): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { id },
      relations: ['store', 'user'],
    });

    if (!payment) {
      throw new NotFoundException('المعاملة غير موجودة');
    }

    return payment;
  }

  /**
   * Get all payments for an order (all installments) by orderId
   */
  async getPaymentsByOrderId(orderId: string, userId: number): Promise<Payment[]> {
    const payments = await this.paymentRepository.find({
      where: { orderId, userId },
      relations: ['store'],
      order: { installmentNumber: 'ASC' }, // Sort by installment number
    });

    console.log(`[PaymentsService] Found ${payments.length} payments for orderId ${orderId}`);
    return payments;
  }

  /**
   * Create a new payment
   */
  async createPayment(paymentData: Partial<Payment>): Promise<Payment> {
    const payment = this.paymentRepository.create(paymentData);
    return this.paymentRepository.save(payment);
  }

  /**
   * Create multiple installments for a session
   */
  async createInstallmentsForSession(data: {
    userId: number;
    storeId: number;
    sessionId: string;
    totalAmount: number;
    installmentsCount: number;
    currency: string;
  }): Promise<Payment[]> {
    const { userId, storeId, sessionId, totalAmount, installmentsCount, currency } = data;
    const orderId = `order_${sessionId}`;
    const installmentAmount = totalAmount / installmentsCount;
    const installments: Payment[] = [];

    // Fetch store and global commission settings
    const [store, globalSettings] = await Promise.all([
      this.storeRepository.findOne({ where: { id: storeId } }),
      this.commissionSettingsService.getCurrentSettings()
    ]);

    const settings = globalSettings?.data;
    const defaultBankRate = settings?.bankCommission ? Number(settings.bankCommission) * 100 : 3.0;
    const defaultPlatformRate = settings?.platformCommission ? Number(settings.platformCommission) * 100 : 2.0;

    const bankCommissionRate = (store?.bankCommissionRate !== null && store?.bankCommissionRate !== undefined)
      ? Number(store.bankCommissionRate)
      : defaultBankRate;

    const platformCommissionRate = (store?.platformCommissionRate !== null && store?.platformCommissionRate !== undefined)
      ? Number(store.platformCommissionRate)
      : defaultPlatformRate;

    const commissionRate = bankCommissionRate + platformCommissionRate;

    // Check if installments already exist to avoid duplicates
    const existing = await this.paymentRepository.find({
      where: { orderId, userId }
    });

    if (existing.length > 0) {
      console.log(`[PaymentsService] Installments already exist for ${orderId}, skipping creation`);
      return existing;
    }

    for (let i = 1; i <= installmentsCount; i++) {
        const dueDate = dayjs().add(i - 1, 'month').toDate();
        
        // Calculate commission and store amount
        const commission = installmentAmount * (Number(commissionRate) / 100);
        const storeAmount = installmentAmount - commission;

        const payment = this.paymentRepository.create({
            userId,
            storeId,
            orderId,
            amount: installmentAmount,
            currency,
            installmentsCount,
            installmentNumber: i,
            totalAmount,
            paymentMethod: 'bnpl',
            status: 'pending',
            commission,
            storeAmount,
            bankCommissionRate,
            platformCommissionRate,
            dueDate,
            paidAt: null,
        });
        installments.push(await this.paymentRepository.save(payment));
    }

    console.log(`[PaymentsService] Created ${installments.length} installments for session ${sessionId} with ${commissionRate}% commission`);
    return installments;
  }

  /**
   * Process payment (mark as completed)
   * Also checks if previous installments are paid (if installment_number > 1)
   */
  async processPayment(paymentId: number): Promise<Payment> {
    const payment = await this.getPaymentById(paymentId);

    if (payment.status === 'completed') {
      return payment;
    }

    // Check if previous installments are paid (if this is not the first installment)
    if (payment.installmentNumber > 1 && payment.orderId) {
      const previousInstallment = await this.paymentRepository.findOne({
        where: {
          userId: payment.userId,
          orderId: payment.orderId,
          installmentNumber: payment.installmentNumber - 1,
        },
      });

      if (!previousInstallment) {
        throw new BadRequestException(`القسط السابق (${payment.installmentNumber - 1}) غير موجود`);
      }

      if (previousInstallment.status !== 'completed') {
        throw new BadRequestException(`يجب دفع القسط السابق (${payment.installmentNumber - 1}) أولاً قبل دفع القسط الحالي (${payment.installmentNumber})`);
      }
    }

    payment.status = 'completed';
    payment.paidAt = new Date();

    const updatedPayment = await this.paymentRepository.save(payment);

    // Award points for successful payment (Commented out to follow the "1 point per session" rule)
    /*
    await this.rewardsService.awardPointsForPayment(
      payment.userId,
      payment.id,
      payment.amount,
    );
    */

    return updatedPayment;
  }

  /**
   * Extend payment due date
   * Note: due_date remains unchanged, only extension_requested and extension_days are updated
   */
  async extendDueDate(paymentId: number, extensionDays: number): Promise<Payment> {
    const payment = await this.getPaymentById(paymentId);

    if (payment.status !== 'pending') {
      throw new Error('لا يمكن تمديد موعد الدفع لهذه المعاملة');
    }

    // Don't change dueDate - keep original date
    // Only update extension flags
    payment.extensionRequested = true;
    payment.extensionDays = extensionDays;

    console.log(`[PaymentsService] Payment ${paymentId} extended: extensionDays=${extensionDays}, dueDate (unchanged)=${payment.dueDate}`);

    return this.paymentRepository.save(payment);
  }

  /**
   * Postpone payment (one-time postponement)
   * Note: due_date remains unchanged (original date), only postponed_due_date is updated
   * Updates is_postponed, postponed_days, and postponed_due_date fields
   */
  async postponePayment(
    paymentId: number,
    daysToPostpone: number,
  ): Promise<Payment> {
    const payment = await this.getPaymentById(paymentId);

    if (payment.status !== 'pending') {
      throw new Error('لا يمكن تأجيل هذه المعاملة');
    }

    // Calculate new due date from original due_date
    const originalDueDate = payment.dueDate;
    const newPostponedDueDate = dayjs(originalDueDate).add(daysToPostpone, 'day').toDate();

    // Update payment fields - DON'T change dueDate, only postponed fields
    payment.isPostponed = true;
    payment.postponedDays = daysToPostpone;
    payment.postponedDueDate = newPostponedDueDate;
    // Keep payment.dueDate unchanged (original date)

    console.log(`[PaymentsService] Payment ${paymentId} postponed: ${daysToPostpone} days`);
    console.log(`  Original dueDate (unchanged): ${originalDueDate}`);
    console.log(`  New postponedDueDate: ${newPostponedDueDate}`);

    return this.paymentRepository.save(payment);
  }

  /**
   * Mark free postponement as used for a payment
   */
  async markFreePostponeUsed(paymentId: number): Promise<void> {
    await this.paymentRepository.update(paymentId, {
      freePostponeUsed: true,
    });

    console.log(`[PaymentsService] Marked free postpone as used for payment ${paymentId}`);
  }

  /**
   * Mark first installment as completed for an order
   */
  async markFirstInstallmentCompleted(orderId: string): Promise<Payment | null> {
    const firstInstallment = await this.paymentRepository.findOne({
      where: { orderId, installmentNumber: 1 },
    });

    if (!firstInstallment) {
      console.warn(`⚠️ First installment not found for order: ${orderId}`);
      return null;
    }

    if (firstInstallment.status === 'completed') {
      console.log(`✅ First installment already completed for order: ${orderId}`);
      return firstInstallment;
    }

    firstInstallment.status = 'completed';
    firstInstallment.paidAt = new Date();

    const updated = await this.paymentRepository.save(firstInstallment);
    console.log(`✅ Marked first installment as completed for order: ${orderId}`);

    return updated;
  }

  /**
   * Get total pending amount for user
   */
  async getTotalPendingAmount(userId: number): Promise<number> {
    const result = await this.paymentRepository
      .createQueryBuilder('payment')
      .select('SUM(payment.amount)', 'total')
      .where('payment.userId = :userId', { userId })
      .andWhere('payment.status = :status', { status: 'pending' })
      .getRawOne();

    return parseFloat(result?.total || '0');
  }

  async getAdminStats() {
    const settingsRes = await this.commissionSettingsService.getCurrentSettings();
    const settings = settingsRes?.data;
    
    // Global fallback rates
    const BANK_COMMISSION_RATE = settings?.bankCommission ? Number(settings.bankCommission) : 0.03;
    const PLATFORM_COMMISSION_RATE = settings?.platformCommission ? Number(settings.platformCommission) : 0.02;

    const allPayments = await this.paymentRepository.find({
      relations: ['store', 'user'],
    });

    const now = new Date();
    const twoDaysAgo = dayjs().subtract(48, 'hours').toDate();
    const sevenDaysAgo = dayjs().subtract(7, 'days').toDate();

    // Cumulative stats
    const stats = allPayments.reduce((acc, p) => {
      const amount = Number(p.amount || 0);
      const isPaid = p.status === 'completed';
      const orderId = p.orderId;
      const n = (val: any) => Number(val) / 100;

      // Link logic (Priority: Store Rate > Payment Rate > Global Fallback)
      const bRate = (p.store?.bankCommissionRate !== null && p.store?.bankCommissionRate !== undefined)
        ? n(p.store.bankCommissionRate)
        : ((p.bankCommissionRate !== null && p.bankCommissionRate !== undefined)
          ? n(p.bankCommissionRate)
          : BANK_COMMISSION_RATE);

      const pRate = (p.store?.platformCommissionRate !== null && p.store?.platformCommissionRate !== undefined)
        ? n(p.store.platformCommissionRate)
        : ((p.platformCommissionRate !== null && p.platformCommissionRate !== undefined)
          ? n(p.platformCommissionRate)
          : PLATFORM_COMMISSION_RATE);

      const bankCommission = amount * bRate;
      const platformCommission = amount * pRate;
      const totalCommission = bankCommission + platformCommission;
      const storeNet = amount - totalCommission;

      // 1. Overall Metrics
      acc.totalSales += amount;
      acc.totalCommissions += totalCommission;
      acc.bankProfits += bankCommission;
      acc.platformProfits += platformCommission;
      acc.totalStoreNet += storeNet;

      // 2. Status based stats
      if (isPaid) {
        acc.totalCollected += amount;
        acc.collectedPlatformProfits += platformCommission;
        if (p.paidAt && new Date(p.paidAt) >= twoDaysAgo) {
          acc.recentCollected += amount;
          acc.recentCollectedCount += 1;
        }
      } else {
        acc.totalDue += amount;
        acc.pendingCount += 1;

        // Overdue check
        const dueDate = p.isPostponed && p.postponedDueDate ? p.postponedDueDate : p.dueDate;
        if (dueDate && new Date(dueDate) < now) {
          acc.totalOverdue += amount;
          acc.overdueCount += 1;
          if (new Date(dueDate) < sevenDaysAgo) {
            acc.overdueOver7DaysAmount += amount;
            acc.overdueOver7DaysCount += 1;
          }
        }
      }

      // 3. Bank Payout logic (95% to store - usually gross based on system design)
      if (orderId && !acc.orderProcessed.has(orderId)) {
        acc.orderProcessed.add(orderId);
        const orderFullAmount = amount * (p.installmentsCount || 1);
        acc.totalOrdersValue += orderFullAmount;
        acc.bankTotalPaidToStores += orderFullAmount * 0.95;
      }

      return acc;
    }, {
      totalSales: 0,
      totalCommissions: 0,
      bankProfits: 0,
      platformProfits: 0,
      totalStoreNet: 0,
      totalCollected: 0,
      collectedPlatformProfits: 0,
      recentCollected: 0,
      recentCollectedCount: 0,
      totalDue: 0,
      pendingCount: 0,
      totalOverdue: 0,
      overdueCount: 0,
      overdueOver7DaysAmount: 0,
      overdueOver7DaysCount: 0,
      totalOrdersValue: 0,
      bankTotalPaidToStores: 0,
      orderProcessed: new Set<string>()
    });

    const bankTotalCollectedFromUsers = stats.totalCollected * (1 - PLATFORM_COMMISSION_RATE);
    const bankTotalRemaining = (stats.totalOrdersValue * (1 - PLATFORM_COMMISSION_RATE)) - bankTotalCollectedFromUsers;
    const platformTotalRemaining = (stats.totalOrdersValue * PLATFORM_COMMISSION_RATE) - stats.collectedPlatformProfits;

    return {
      success: true,
      data: {
        totalDue: stats.totalDue,
        totalCollected: stats.totalCollected,
        totalOverdue: stats.totalOverdue,
        pendingCount: stats.pendingCount,
        collectedCount: stats.recentCollectedCount,
        overdueCount: stats.overdueCount,
        overdueOver7DaysCount: stats.overdueOver7DaysCount,
        overdueOver7DaysAmount: stats.overdueOver7DaysAmount,
        recentCollected: stats.recentCollected,
        // Detailed Financials (Linked to pages)
        bankTotalPaid: stats.bankTotalPaidToStores,
        bankTotalCollected: bankTotalCollectedFromUsers,
        bankTotalRemaining,
        platformTotalCollected: stats.collectedPlatformProfits,
        platformTotalRemaining,
        totalOrdersValue: stats.totalOrdersValue,
        bankProfitsOverall: stats.bankProfits,
        platformProfitsOverall: stats.platformProfits
      },
    };
  }

  async getAllPaymentsForAdmin(filters: {
    page: number;
    limit: number;
    status?: string;
    userId?: number;
    storeId?: number;
    startDate?: string;
    endDate?: string;
  }) {
    const { page, limit, status, userId, storeId, startDate, endDate } = filters;
    const skip = (page - 1) * limit;

    const queryBuilder = this.paymentRepository
      .createQueryBuilder('payment')
      .leftJoinAndSelect('payment.store', 'store')
      .leftJoinAndSelect('payment.user', 'user');

    if (status) {
      queryBuilder.andWhere('payment.status = :status', { status });
    }

    if (userId) {
      queryBuilder.andWhere('payment.userId = :userId', { userId });
    }

    if (storeId) {
      queryBuilder.andWhere('payment.storeId = :storeId', { storeId });
    }

    if (startDate) {
      queryBuilder.andWhere('payment.createdAt >= :startDate', { startDate });
    }

    if (endDate) {
      queryBuilder.andWhere('payment.createdAt <= :endDate', { endDate });
    }

    const [payments, total] = await queryBuilder
      .orderBy('payment.dueDate', 'ASC')
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return {
      success: true,
      data: payments,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getUpcomingPayments() {
    const today = dayjs().startOf('day');
    const tomorrow = today.add(1, 'day');
    const dayAfterTomorrow = today.add(2, 'days');

    const allPendingPayments = await this.paymentRepository.find({
      where: { status: 'pending' },
      relations: ['store', 'user'],
    });

    const getPaymentsForDay = (dayStart: dayjs.Dayjs) => {
      const dayEnd = dayStart.endOf('day');
      return allPendingPayments.filter(p => {
        const dueDate = p.isPostponed && p.postponedDueDate ? p.postponedDueDate : p.dueDate;
        if (!dueDate) return false;
        const dueTime = new Date(dueDate).getTime();
        const startTime = dayStart.toDate().getTime();
        const endTime = dayEnd.toDate().getTime();
        return dueTime >= startTime && dueTime <= endTime;
      });
    };

    const todayPayments = getPaymentsForDay(today);
    const tomorrowPayments = getPaymentsForDay(tomorrow);
    const dayAfterPayments = getPaymentsForDay(dayAfterTomorrow);

    // Get next 5 upcoming payments regardless of date
    const upcomingPayments = allPendingPayments
      .sort((a, b) => {
        const dateA = a.isPostponed && a.postponedDueDate ? a.postponedDueDate : a.dueDate;
        const dateB = b.isPostponed && b.postponedDueDate ? b.postponedDueDate : b.dueDate;
        return new Date(dateA).getTime() - new Date(dateB).getTime();
      })
      .slice(0, 5)
      .map(p => ({
        id: p.id,
        amount: Number(p.amount),
        dueDate: p.isPostponed && p.postponedDueDate ? p.postponedDueDate : p.dueDate,
        customer: p.user?.name || 'Unknown',
        store: p.store?.nameAr || p.store?.name || 'Unknown',
        installmentNumber: p.installmentNumber,
        installmentsCount: p.installmentsCount,
      }));

    return {
      success: true,
      data: {
        today: {
          count: todayPayments.length,
          paid: todayPayments.filter(p => p.status === 'completed').length,
          amount: todayPayments.reduce((sum, p) => sum + Number(p.amount), 0),
        },
        tomorrow: {
          count: tomorrowPayments.length,
          paid: tomorrowPayments.filter(p => p.status === 'completed').length,
          amount: tomorrowPayments.reduce((sum, p) => sum + Number(p.amount), 0),
        },
        dayAfter: {
          count: dayAfterPayments.length,
          paid: dayAfterPayments.filter(p => p.status === 'completed').length,
          amount: dayAfterPayments.reduce((sum, p) => sum + Number(p.amount), 0),
        },
        upcomingPayments,
      },
    };
  }

  async manualCollect(id: number) {
    const payment = await this.paymentRepository.findOne({
      where: { id },
      relations: ['user', 'store'],
    });

    if (!payment) {
      throw new NotFoundException(`Payment #${id} not found`);
    }

    if (payment.status === 'completed') {
      return {
        success: false,
        message: 'Payment already collected',
      };
    }

    payment.status = 'completed';
    payment.paidAt = new Date();
    await this.paymentRepository.save(payment);

    return {
      success: true,
      message: 'Payment marked as collected successfully',
      data: payment,
    };
  }

  async sendReminder(id: number) {
    const payment = await this.paymentRepository.findOne({
      where: { id },
      relations: ['user', 'store'],
    });

    if (!payment) {
      throw new NotFoundException(`Payment #${id} not found`);
    }

    if (payment.status !== 'pending') {
      return {
        success: false,
        message: 'Can only send reminders for pending payments',
      };
    }

    // TODO: Integrate with notifications service
    // For now, just return success
    // await this.notificationsService.sendPaymentReminder(payment);

    return {
      success: true,
      message: 'Reminder sent successfully',
      data: {
        paymentId: payment.id,
        userId: payment.userId,
        amount: payment.amount,
      },
    };
  }
}
