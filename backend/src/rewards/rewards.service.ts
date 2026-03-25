import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RewardPoint } from './entities/reward-point.entity';

@Injectable()
export class RewardsService {
  constructor(
    @InjectRepository(RewardPoint)
    private rewardPointRepository: Repository<RewardPoint>,
  ) {}

  /**
   * Get user's current total points
   */
  async getUserPoints(userId: number): Promise<number> {
    const result = await this.rewardPointRepository
      .createQueryBuilder('reward')
      .select('SUM(reward.points)', 'total')
      .where('reward.userId = :userId', { userId })
      .getRawOne();

    console.log(`🔍 Points for user ${userId}:`, result);
    const total = result?.total ? Number(result.total) : 0;
    return total;
  }

  /**
   * Get user's points history
   */
  async getPointsHistory(userId: number): Promise<RewardPoint[]> {
    return this.rewardPointRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

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
   * Award points for successful purchase session (1 point per session)
   */
  async awardPointsForSession(
    userId: number,
    sessionId: string,
    amount: number,
  ): Promise<RewardPoint> {
    const rewardPoint = this.rewardPointRepository.create({
      userId,
      points: 1, // 1 point per purchase session as requested
      transactionType: 'earned',
      amount,
      description: `نقطة مكتسبة من عملية شراء - جلسة رقم ${sessionId}`,
    });

    return this.rewardPointRepository.save(rewardPoint);
  }

  /**
   * Redeem points (100 points = 1 JOD discount)
   */
  async redeemPoints(
    userId: number,
    pointsToRedeem: number,
  ): Promise<RewardPoint> {
    const currentPoints = await this.getUserPoints(userId);

    if (currentPoints < pointsToRedeem) {
      throw new Error('نقاط غير كافية');
    }

    if (pointsToRedeem < 100) {
      throw new Error('الحد الأدنى للاستبدال هو 100 نقطة');
    }

    const rewardPoint = this.rewardPointRepository.create({
      userId,
      points: -pointsToRedeem, // Negative for redemption
      transactionType: 'redeemed',
      amount: pointsToRedeem / 100, // 100 points = 1 JOD
      description: `استبدال ${pointsToRedeem} نقطة بخصم ${pointsToRedeem / 100} دينار`,
    });

    return this.rewardPointRepository.save(rewardPoint);
  }
}

