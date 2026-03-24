import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('reward_points')
export class RewardPoint {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ type: 'int' })
  points: number; // Can be positive (earned) or negative (redeemed)

  @Column({ name: 'transaction_type', length: 50 })
  transactionType: string; // earned, redeemed

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  amount: number; // Related payment amount

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'payment_id', nullable: true })
  paymentId: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.rewardPoints)
  @JoinColumn({ name: 'user_id' })
  user: User;
}

