import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Payment } from '../../payments/entities/payment.entity';
import { SavedCard } from './saved-card.entity';
import { User } from '../../users/entities/user.entity';

@Entity('auto_payment_logs')
export class AutoPaymentLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'payment_id' })
  paymentId: number;

  @Column({ name: 'saved_card_id', nullable: true })
  savedCardId: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'stripe_payment_intent_id', length: 100, nullable: true })
  stripePaymentIntentId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ length: 3, default: 'JOD' })
  currency: string;

  @Column({ length: 50, default: 'pending' })
  status: string; // success, failed, pending

  @Column({ name: 'failure_reason', type: 'text', nullable: true })
  failureReason: string;

  @Column({ name: 'attempt_number', default: 1 })
  attemptNumber: number;

  @Column({ name: 'next_retry_at', type: 'timestamp', nullable: true })
  nextRetryAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relations
  @ManyToOne(() => Payment)
  @JoinColumn({ name: 'payment_id' })
  payment: Payment;

  @ManyToOne(() => SavedCard)
  @JoinColumn({ name: 'saved_card_id' })
  savedCard: SavedCard;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
