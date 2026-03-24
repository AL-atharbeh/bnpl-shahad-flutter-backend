import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Payment } from '../../payments/entities/payment.entity';

@Entity('postponements')
export class Postponement {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'payment_id' })
  paymentId: number;

  @Column({ name: 'original_due_date', type: 'timestamp' })
  originalDueDate: Date;

  @Column({ name: 'new_due_date', type: 'timestamp' })
  newDueDate: Date;

  @Column({ name: 'days_postponed' })
  daysPostponed: number;

  @Column({ name: 'is_free', default: false })
  isFree: boolean; // Free monthly postponement

  @Column({ name: 'merchant_name', length: 255, nullable: true })
  merchantName: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  amount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.postponements)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Payment, (payment) => payment.postponements)
  @JoinColumn({ name: 'payment_id' })
  payment: Payment;
}

