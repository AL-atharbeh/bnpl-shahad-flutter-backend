import { Injectable, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RewardPoint } from './entities/reward-point.entity';
import { RewardCashoutRequest, CashoutStatus } from './entities/reward-cashout-request.entity';

@Injectable()
export class RewardsService {
  constructor(
    @InjectRepository(RewardPoint)
    private rewardPointRepository: Repository<RewardPoint>,
    @InjectRepository(RewardCashoutRequest)
    private cashoutRepository: Repository<RewardCashoutRequest>,
  ) {}

  // ─────────────────────────────────────────────────────────────────
  //  READ — Points balance & history
  // ─────────────────────────────────────────────────────────────────

  /** Get user's current TOTAL points (earned − spent) */
  async getUserPoints(userId: number): Promise<number> {
    const result = await this.rewardPointRepository
      .createQueryBuilder('reward')
      .select('SUM(reward.points)', 'total')
      .where('reward.userId = :userId', { userId })
      .getRawOne();

    const total = result?.total ? Number(result.total) : 0;
    return total < 0 ? 0 : total;
  }

  /** Get user's points history (newest first) */
  async getPointsHistory(userId: number): Promise<RewardPoint[]> {
    return this.rewardPointRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /** Returns points summary: balance, JOD value, cashout eligibility */
  async getPointsSummary(userId: number) {
    const points = await this.getUserPoints(userId);
    const jodValue = points / 100;                 // 100 points = 1 JOD
    const cashoutEligible = points >= 1000;        // Minimum 1000 points = 10 JOD

    // Check if user already has a pending cashout request
    const pendingRequest = await this.cashoutRepository.findOne({
      where: { userId, status: CashoutStatus.PENDING },
    });

    return {
      points,
      jodValue: parseFloat(jodValue.toFixed(2)),
      cashoutEligible,
      hasPendingCashout: !!pendingRequest,
      minimumCashoutPoints: 1000,
      minimumCashoutJod: 10,
    };
  }

  // ─────────────────────────────────────────────────────────────────
  //  WRITE — Award & Redeem points
  // ─────────────────────────────────────────────────────────────────

  /**
   * Award points for a completed payment installment.
   * Rate: 1 point per JOD paid.
   * @deprecated Use awardPointsForSession instead for new sessions.
   */
  async awardPointsForPayment(
    userId: number,
    paymentId: number,
    amount: number,
  ): Promise<RewardPoint> {
    const points = Math.floor(amount); // 1 JOD = 1 point

    const rewardPoint = this.rewardPointRepository.create({
      userId,
      paymentId,
      points,
      transactionType: 'earned',
      amount,
      description: `نقاط من عملية دفع بمبلغ ${amount} دينار`,
    });

    return this.rewardPointRepository.save(rewardPoint);
  }

  /**
   * Award points when a BNPL session is approved.
   * Rule: 1 point per JOD of the total purchase amount.
   * Example: 50 JOD purchase → 50 points.
   */
  async awardPointsForSession(
    userId: number,
    sessionId: string,
    amount: number,
  ): Promise<RewardPoint> {
    const points = Math.floor(amount); // 1 JOD = 1 point

    const rewardPoint = this.rewardPointRepository.create({
      userId,
      points,
      transactionType: 'earned',
      amount,
      description: `نقاط مكتسبة من شراء بمبلغ ${amount} دينار - جلسة ${sessionId}`,
    });

    return this.rewardPointRepository.save(rewardPoint);
  }

  // ─────────────────────────────────────────────────────────────────
  //  CASHOUT — User requests cash transfer via ClickPay
  // ─────────────────────────────────────────────────────────────────

  /**
   * User submits a cashout request.
   * Requires ≥ 1000 points (= 10 JOD).
   * TODO: In production, automate via ClickPay API or e-wallet transfer.
   */
  async requestCashout(userId: number, clickPayLink: string): Promise<RewardCashoutRequest> {
    const summary = await this.getPointsSummary(userId);

    if (!summary.cashoutEligible) {
      throw new BadRequestException(
        `نقاطك الحالية (${summary.points}) غير كافية. الحد الأدنى للصرف هو 1000 نقطة (= 10 دنانير).`,
      );
    }

    if (summary.hasPendingCashout) {
      throw new BadRequestException('لديك طلب صرف معلق بالفعل. يرجى الانتظار حتى تتم مراجعته.');
    }

    if (!clickPayLink || clickPayLink.trim().length < 5) {
      throw new BadRequestException('يرجى إدخال رابط ClickPay صحيح.');
    }

    // Deduct points immediately to prevent double-spending
    const pointsToRedeem = summary.points;
    const amountJod = pointsToRedeem / 100;

    await this.rewardPointRepository.save(
      this.rewardPointRepository.create({
        userId,
        points: -pointsToRedeem,
        transactionType: 'redeemed',
        amount: amountJod,
        description: `طلب صرف ${pointsToRedeem} نقطة = ${amountJod.toFixed(2)} دينار عبر ClickPay`,
      }),
    );

    // Create cashout request for admin review
    const request = this.cashoutRepository.create({
      userId,
      pointsRequested: pointsToRedeem,
      amountJod: parseFloat(amountJod.toFixed(2)),
      clickPayLink: clickPayLink.trim(),
      status: CashoutStatus.PENDING,
    });

    return this.cashoutRepository.save(request);
  }

  // ─────────────────────────────────────────────────────────────────
  //  ADMIN — Manage cashout requests
  // ─────────────────────────────────────────────────────────────────

  /** Get all cashout requests (for admin page) */
  async getAllCashoutRequests(status?: CashoutStatus) {
    const where: any = {};
    if (status) where.status = status;

    return this.cashoutRepository.find({
      where,
      relations: ['user'],
      order: { createdAt: 'DESC' },
    });
  }

  /** Count pending cashout requests (for admin badge) */
  async getPendingCashoutCount(): Promise<number> {
    return this.cashoutRepository.count({
      where: { status: CashoutStatus.PENDING },
    });
  }

  /** Admin approves or rejects a cashout request */
  async updateCashoutStatus(
    requestId: number,
    status: CashoutStatus,
    adminNote?: string,
  ): Promise<RewardCashoutRequest> {
    const request = await this.cashoutRepository.findOne({ where: { id: requestId } });

    if (!request) {
      throw new BadRequestException('طلب الصرف غير موجود.');
    }

    if (request.status !== CashoutStatus.PENDING) {
      throw new BadRequestException('تمت معالجة هذا الطلب مسبقاً.');
    }

    // If rejected → restore points to user
    if (status === CashoutStatus.REJECTED) {
      await this.rewardPointRepository.save(
        this.rewardPointRepository.create({
          userId: request.userId,
          points: request.pointsRequested,
          transactionType: 'refunded',
          amount: request.amountJod,
          description: `استرداد ${request.pointsRequested} نقطة بسبب رفض طلب الصرف`,
        }),
      );
    }

    request.status = status;
    request.adminNote = adminNote || null;

    return this.cashoutRepository.save(request);
  }

  // ─────────────────────────────────────────────────────────────────
  //  LEGACY — Keep for backwards compatibility
  // ─────────────────────────────────────────────────────────────────

  /**
   * @deprecated Use requestCashout instead.
   * Redeem points for discount (old flow — kept as comment for reference).
   * TODO: When Wallet integration is ready, auto-transfer via wallet API.
   * TODO: When ClickPay auto-payment is ready, call ClickPay API directly here.
   */
  async redeemPoints(userId: number, pointsToRedeem: number): Promise<RewardPoint> {
    const currentPoints = await this.getUserPoints(userId);

    if (currentPoints < pointsToRedeem) throw new Error('نقاط غير كافية');
    if (pointsToRedeem < 100) throw new Error('الحد الأدنى للاستبدال هو 100 نقطة');

    const rewardPoint = this.rewardPointRepository.create({
      userId,
      points: -pointsToRedeem,
      transactionType: 'redeemed',
      amount: pointsToRedeem / 100,
      description: `استبدال ${pointsToRedeem} نقطة بخصم ${pointsToRedeem / 100} دينار`,
    });

    return this.rewardPointRepository.save(rewardPoint);
  }

  /** Get user's own cashout requests history */
  async getUserCashoutRequests(userId: number): Promise<RewardCashoutRequest[]> {
    return this.cashoutRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }
}
