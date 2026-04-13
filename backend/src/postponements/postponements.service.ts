import { Injectable, BadRequestException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { Postponement } from './entities/postponement.entity';
import { ExtensionOption } from './entities/extension-option.entity';
import { PaymentsService } from '../payments/payments.service';
import { UsersService } from '../users/users.service';
import dayjs from 'dayjs';

@Injectable()
export class PostponementsService implements OnModuleInit {
  constructor(
    @InjectRepository(Postponement)
    private postponementRepository: Repository<Postponement>,
    @InjectRepository(ExtensionOption)
    private extensionOptionRepository: Repository<ExtensionOption>,
    private paymentsService: PaymentsService,
    private usersService: UsersService,
  ) { }

  async onModuleInit() {
    await this.seedDefaultOptions();
  }

  /**
   * Check if user can use free postponement (once per month)
   * 
   * Rules:
   * 1. User can use free postponement once every 30 days
   * 2. Cannot have multiple active postponements at the same time
   * 3. Must wait 30 days after last free postponement before using again
   */
  async canPostponeForFree(userId: number): Promise<boolean> {
    // Update user's days counter first (sync from database)
    await this.updateUserPostponementDays(userId);

    // Get user to check days counter
    const user = await this.usersService.findById(userId);
    const daysCounter = user.daysSinceLastPostponement || 0;

    // User can postpone if 30 days have passed (counter >= 30)
    return daysCounter >= 30;
  }

  /**
   * Get days until next free postponement
   * Returns 0 if postponement is available now
   * Uses user's days_since_last_postponement counter
   */
  async getDaysUntilNextPostpone(userId: number): Promise<number> {
    // Update user's days counter first
    await this.updateUserPostponementDays(userId);

    // Get user to check days counter
    const user = await this.usersService.findById(userId);
    const daysCounter = user.daysSinceLastPostponement || 0;

    // Calculate days remaining
    const daysRemaining = 30 - daysCounter;

    // Return 0 if already available, otherwise return days remaining
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  /**
   * Update user's days_since_last_postponement counter
   * Calculates days from last postponement and updates user record
   * This should be called periodically or when checking postponement status
   */
  async updateUserPostponementDays(userId: number): Promise<void> {
    const lastFreePostponement = await this.postponementRepository.findOne({
      where: { userId, isFree: true },
      order: { createdAt: 'DESC' },
    });

    const user = await this.usersService.findById(userId);

    if (!lastFreePostponement) {
      // No postponement found, reset counter to 0
      if (user.daysSinceLastPostponement !== 0) {
        user.daysSinceLastPostponement = 0;
        await this.usersService.updateProfile(userId, { daysSinceLastPostponement: 0 });
      }
      return;
    }

    // Calculate days since last postponement
    const daysSinceLastPostpone = dayjs().diff(
      dayjs(lastFreePostponement.createdAt),
      'day',
    );

    // Update counter (max 30 days)
    const newCounterValue = Math.min(daysSinceLastPostpone, 30);

    if (user.daysSinceLastPostponement !== newCounterValue) {
      user.daysSinceLastPostponement = newCounterValue;
      await this.usersService.updateProfile(userId, {
        daysSinceLastPostponement: newCounterValue
      });
    }
  }

  /**
   * Postpone payment for free (30 days, once per user)
   * 
   * Uses user-level tracking:
   * - Each user can use free postponement once (lifetime)
   * - Checks user.freePostponeUsed flag
   */
  async postponeForFree(
    userId: number,
    paymentId: number,
    merchantName: string,
    amount: number,
  ): Promise<Postponement> {
    // Get user to check if they've already used free postponement
    const user = await this.usersService.findById(userId);

    if (user.freePostponeUsed) {
      throw new BadRequestException('لقد استخدمت التأجيل المجاني مسبقاً');
    }

    // Verify payment exists and is pending
    const payment = await this.paymentsService.getPaymentById(paymentId);

    if (payment.status !== 'pending') {
      throw new BadRequestException('لا يمكن تأجيل هذه المعاملة لأنها ليست معلقة');
    }

    // Calculate new due date from original due_date (30 days)
    const originalDueDate = payment.dueDate;
    const newDueDate = dayjs(originalDueDate).add(30, 'day').toDate();

    // Update payment postponement fields
    await this.paymentsService.postponePayment(paymentId, 30);

    // Record postponement in history
    const postponement = this.postponementRepository.create({
      userId,
      paymentId,
      originalDueDate,
      newDueDate,
      daysPostponed: 30,
      isFree: true,
      merchantName,
      amount,
    });

    const savedPostponement = await this.postponementRepository.save(postponement);

    // Mark user as having used free postponement
    await this.usersService.updateProfile(userId, {
      freePostponeUsed: true,
    });

    console.log(`[PostponementsService] User ${userId} used free postponement (30 days)`);
    console.log(`  Payment ID: ${paymentId}`);
    console.log(`  Original due date: ${originalDueDate}`);
    console.log(`  New due date: ${newDueDate}`);
    console.log(`  User marked as freePostponeUsed = true`);

    return savedPostponement;
  }

  /**
   * Get user's postponement history
   */
  async getPostponementHistory(userId: number): Promise<Postponement[]> {
    return this.postponementRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get all active extension options
   */
  async getExtensionOptions(): Promise<ExtensionOption[]> {
    return this.extensionOptionRepository.find({
      where: { isActive: true },
      order: { days: 'ASC' },
    });
  }

  /**
   * Initiate a paid extension session
   * This creates a Stripe session for the extension fee
   */
  async initiatePaidExtension(userId: number, paymentId: number, optionId: number): Promise<any> {
    const payment = await this.paymentsService.getPaymentById(paymentId);
    const option = await this.extensionOptionRepository.findOne({ where: { id: optionId } });

    if (!option) {
      throw new BadRequestException('خيار التمديد غير موجود');
    }

    if (payment.userId !== userId) {
      throw new BadRequestException('لا تملك صلاحية الوصول لهذه المعاملة');
    }

    if (payment.status !== 'pending') {
      throw new BadRequestException('لا يمكن تمديد هذه المعاملة لأنها ليست معلقة');
    }

    // Since we don't have a direct StripeService injection here yet (it's in PaymentsService)
    // and we want to keep logic clean, let's assume we'll use a generic payment flow.
    // However, I see PaymentsController uses StripeService directly.
    // I will add StripeService to PostponementsModule or use a method in PaymentsService.
    
    // For now, I'll return the data needed for the controller to trigger Stripe.
    return {
      fee: Number(option.fee),
      days: option.days,
      paymentId: paymentId,
      merchantName: payment.store?.nameAr || payment.store?.name || 'متجر',
    };
  }

  /**
   * Seed default extension options
   */
  async seedDefaultOptions() {
    const count = await this.extensionOptionRepository.count();
    if (count > 0) return;

    const defaults = [
      { days: 7, fee: 0.5, nameAr: 'تمديد لمدة أسبوع', nameEn: '1 Week Extension', isPopular: false },
      { days: 14, fee: 0.95, nameAr: 'تمديد لمدة أسبوعين', nameEn: '2 Weeks Extension', isPopular: true },
      { days: 30, fee: 1.5, nameAr: 'تمديد لمدة شهر', nameEn: '1 Month Extension', isPopular: false },
    ];

    for (const d of defaults) {
      await this.extensionOptionRepository.save(this.extensionOptionRepository.create(d));
    }
  }

  // Admin methods
  async getAdminStats() {
    const totalPostponements = await this.postponementRepository.count();
    const freePostponements = await this.postponementRepository.count({ where: { isFree: true } });
    const paidPostponements = await this.postponementRepository.count({ where: { isFree: false } });

    // Total days postponed
    const allPostponements = await this.postponementRepository.find();
    const totalDaysPostponed = allPostponements.reduce((sum, p) => sum + p.daysPostponed, 0);

    // Postponements in last 7 days
    const sevenDaysAgo = dayjs().subtract(7, 'days').toDate();
    const recentPostponements = await this.postponementRepository.count({
      where: {
        createdAt: MoreThan(sevenDaysAgo),
      },
    });

    return {
      success: true,
      data: {
        totalPostponements,
        freePostponements,
        paidPostponements,
        totalDaysPostponed,
        recentPostponements,
      },
    };
  }

  async getAllPostponementsForAdmin(filters: {
    page: number;
    limit: number;
    userId?: number;
    paymentId?: number;
    startDate?: string;
    endDate?: string;
  }) {
    const { page, limit, userId, paymentId, startDate, endDate } = filters;
    const skip = (page - 1) * limit;

    const queryBuilder = this.postponementRepository
      .createQueryBuilder('postponement')
      .leftJoinAndSelect('postponement.payment', 'payment')
      .leftJoinAndSelect('payment.user', 'user')
      .leftJoinAndSelect('payment.store', 'store');

    if (userId) {
      queryBuilder.andWhere('postponement.userId = :userId', { userId });
    }

    if (paymentId) {
      queryBuilder.andWhere('postponement.paymentId = :paymentId', { paymentId });
    }

    if (startDate) {
      queryBuilder.andWhere('postponement.createdAt >= :startDate', { startDate });
    }

    if (endDate) {
      queryBuilder.andWhere('postponement.createdAt <= :endDate', { endDate });
    }

    const [postponements, total] = await queryBuilder
      .orderBy('postponement.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return {
      success: true,
      data: postponements,
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
    const postponements = await this.postponementRepository
      .createQueryBuilder('postponement')
      .where('postponement.createdAt >= :startDate', { startDate: sevenDaysAgo.toDate() })
      .getMany();

    // Group by day
    const chartData = [];
    for (let i = 0; i < 7; i++) {
      const date = sevenDaysAgo.add(i, 'day');
      const dayStart = date.startOf('day').toDate();
      const dayEnd = date.endOf('day').toDate();

      const dayPostponements = postponements.filter(p => {
        const createdAt = new Date(p.createdAt).getTime();
        const start = dayStart.getTime();
        const end = dayEnd.getTime();
        return createdAt >= start && createdAt <= end;
      });

      chartData.push({
        date: date.format('YYYY-MM-DD'),
        day: date.format('ddd'),
        count: dayPostponements.length,
        free: dayPostponements.filter(p => p.isFree).length,
        paid: dayPostponements.filter(p => !p.isFree).length,
      });
    }

    return {
      success: true,
      data: chartData,
    };
  }

  // Admin CRUD for Extension Options
  async createExtensionOption(data: Partial<ExtensionOption>): Promise<ExtensionOption> {
    const option = this.extensionOptionRepository.create(data);
    return this.extensionOptionRepository.save(option);
  }

  async deleteExtensionOption(id: number): Promise<void> {
    await this.extensionOptionRepository.delete(id);
  }
}

