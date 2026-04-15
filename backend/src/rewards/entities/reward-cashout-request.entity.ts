import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum CashoutStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

@Entity('reward_cashout_requests')
export class RewardCashoutRequest {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'points_requested', type: 'int' })
  pointsRequested: number; // Total points to redeem

  @Column({ name: 'amount_jod', type: 'decimal', precision: 10, scale: 2 })
  amountJod: number; // pointsRequested / 100

  @Column({ name: 'click_pay_link', type: 'text' })
  clickPayLink: string; // ClickPay link from the user

  @Column({
    type: 'enum',
    enum: CashoutStatus,
    default: CashoutStatus.PENDING,
  })
  status: CashoutStatus;

  @Column({ name: 'admin_note', type: 'text', nullable: true })
  adminNote: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
