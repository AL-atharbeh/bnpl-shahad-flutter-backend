import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, Between } from 'typeorm';
import { Payment } from '../payments/entities/payment.entity';
import { SavedCard } from './entities/saved-card.entity';
import { AutoPaymentLog } from './entities/auto-payment-log.entity';
import { StripeService } from '../payments/stripe.service';
import { NotificationsService } from '../notifications/notifications.service';
import dayjs from 'dayjs';

@Injectable()
export class AutoPaymentScheduler {
  private readonly logger = new Logger(AutoPaymentScheduler.name);

  constructor(
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    @InjectRepository(SavedCard)
    private savedCardRepository: Repository<SavedCard>,
    @InjectRepository(AutoPaymentLog)
    private autoPaymentLogRepository: Repository<AutoPaymentLog>,
    private stripeService: StripeService,
    private notificationsService: NotificationsService,
  ) { }

  /**
   * Daily task at 9:00 AM to process due payments
   */
  @Cron('0 9 * * *')
  async handleDailyPayments() {
    this.logger.log('🚀 Starting daily auto-payment processing...');

    const today = dayjs().startOf('day').toDate();
    const endOfToday = dayjs().endOf('day').toDate();

    // 1. Fetch payments due today
    const duePayments = await this.paymentRepository.find({
      where: [
        { status: 'pending', dueDate: Between(today, endOfToday) },
        { status: 'pending', postponedDueDate: Between(today, endOfToday) },
      ],
      relations: ['user'],
    });

    this.logger.log(`📅 Found ${duePayments.length} payments due today.`);

    for (const payment of duePayments) {
      await this.processPayment(payment);
    }

    // 2. Fetch payments that failed in the last 2 days for retry
    const twoDaysAgo = dayjs().subtract(2, 'days').startOf('day').toDate();
    const failedPayments = await this.paymentRepository.find({
      where: {
        status: 'failed',
        updatedAt: Between(twoDaysAgo, today),
      },
      relations: ['user'],
    });

    this.logger.log(`🔄 Found ${failedPayments.length} recently failed payments for retry.`);
    for (const payment of failedPayments) {
      await this.processPayment(payment, true);
    }

    // 3. Send reminders for payments due in the next 4 days
    await this.sendDueSoonReminders();

    this.logger.log('✅ Daily auto-payment processing completed.');
  }

  private async processPayment(payment: Payment, isRetry = false) {
    const userId = payment.userId;
    const defaultCard = await this.savedCardRepository.findOne({
      where: { userId, isDefault: true, isActive: true },
    });

    if (!defaultCard) {
      this.logger.warn(`⚠️ User ${userId} has no default card for payment ${payment.id}`);
      await this.notificationsService.sendToUser(
        userId,
        'يرجى إضافة وسيلة دفع',
        `لديك قسط مستحق بقيمة ${payment.amount} JOD، يرجى إضافة بطاقة دفع لتفعيل الخصم التلقائي.`,
        { paymentId: payment.id.toString(), type: 'no_card' },
        'urgent'
      );
      return;
    }

    // Log the attempt
    const attemptNumber = isRetry ? (await this.getAttemptCount(payment.id) + 1) : 1;
    if (attemptNumber > 3) {
      this.logger.warn(`🚫 Max retries reached for payment ${payment.id}`);
      return;
    }

    const log = this.autoPaymentLogRepository.create({
      paymentId: payment.id,
      userId,
      savedCardId: defaultCard.id,
      amount: payment.amount,
      currency: payment.currency,
      status: 'pending',
      attemptNumber,
    });
    await this.autoPaymentLogRepository.save(log);

    try {
      this.logger.log(`💳 Attempting charge for user ${userId}, amount ${payment.amount}`);
      
      const charge = await this.stripeService.chargeWithSavedCard({
        customerId: defaultCard.stripeCustomerId,
        paymentMethodId: defaultCard.stripePaymentMethodId,
        amount: payment.amount,
        currency: 'usd',
        description: `Auto-payment for Installment #${payment.installmentNumber} (Order: ${payment.orderId})`,
        metadata: {
          paymentId: payment.id.toString(),
          userId: userId.toString(),
          type: 'auto_payment',
        },
      });

      if (charge.status === 'succeeded') {
        // Success!
        payment.status = 'completed';
        payment.paidAt = new Date();
        payment.transactionId = charge.id;
        await this.paymentRepository.save(payment);

        log.status = 'success';
        log.stripePaymentIntentId = charge.id;
        await this.autoPaymentLogRepository.save(log);

        await this.notificationsService.sendToUser(
          userId,
          'تم الدفع بنجاح ✅',
          `تم خصم مبلغ ${payment.amount} JOD من بطاقتك بنجاح مقابل القسط المستحق. شكراً لك!`,
          { paymentId: payment.id.toString(), transactionId: charge.id },
          'payment_success'
        );
        
        this.logger.log(`✅ Success for payment ${payment.id}`);
      } else {
        throw new Error(`Charge status: ${charge.status}`);
      }
    } catch (error) {
      this.logger.error(`❌ Charge failed for payment ${payment.id}: ${error.message}`);
      
      payment.status = 'failed';
      await this.paymentRepository.save(payment);

      log.status = 'failed';
      log.failureReason = error.message;
      log.nextRetryAt = dayjs().add(1, 'day').startOf('day').add(9, 'hour').toDate();
      await this.autoPaymentLogRepository.save(log);

      await this.notificationsService.sendToUser(
        userId,
        'فشل الخصم التلقائي ❌',
        `فشلنا في خصم القسط المستحق من بطاقتك. يرجى التحقق من الرصيد أو تحديث وسيلة الدفع. سنحاول مرة أخرى غداً.`,
        { paymentId: payment.id.toString(), error: error.message },
        'payment_failed'
      );
    }
  }

  private async sendDueSoonReminders() {
    const startOfTomorrow = dayjs().add(1, 'day').startOf('day').toDate();
    const endOfFourDays = dayjs().add(4, 'days').endOf('day').toDate();

    const upcomingPayments = await this.paymentRepository.find({
      where: [
        { status: 'pending', dueDate: Between(startOfTomorrow, endOfFourDays) },
        { status: 'pending', postponedDueDate: Between(startOfTomorrow, endOfFourDays) },
      ],
      relations: ['user'],
    });

    this.logger.log(`⏰ Found ${upcomingPayments.length} upcoming payments within 4 days to remind.`);

    for (const payment of upcomingPayments) {
      const activeDueDate = payment.isPostponed && payment.postponedDueDate ? payment.postponedDueDate : payment.dueDate;
      const daysLeft = dayjs(activeDueDate).diff(dayjs().startOf('day'), 'day');
      
      let daysText = '';
      if (daysLeft === 1) {
        daysText = 'غداً';
      } else if (daysLeft === 2) {
        daysText = 'بعد غد';
      } else {
        daysText = `خلال ${daysLeft} أيام`;
      }

      await this.notificationsService.sendToUser(
        payment.userId,
        'تذكير بموعد الدفع ⏰',
        `نود تذكيرك بأن قسطك القادم بقيمة ${payment.amount} JOD مستحق ${daysText}. سيتم الخصم تلقائياً من بطاقتك.`,
        { paymentId: payment.id.toString(), type: 'payment_reminder', daysLeft: daysLeft.toString() },
        'info'
      );
    }
  }

  private async getAttemptCount(paymentId: number): Promise<number> {
    return this.autoPaymentLogRepository.count({ where: { paymentId } });
  }
}
