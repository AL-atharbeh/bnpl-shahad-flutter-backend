import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Store } from '../../stores/entities/store.entity';
import { Postponement } from '../../postponements/entities/postponement.entity';

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'store_id' })
  storeId: number;

  @Column({ name: 'order_id', length: 255, nullable: true })
  orderId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ length: 3, default: 'JOD' })
  currency: string;

  // Installment fields
  @Column({ name: 'installments_count', default: 1 })
  installmentsCount: number; // Total number of installments (e.g., 4)

  @Column({ name: 'installment_number', default: 1 })
  installmentNumber: number; // Current installment number (e.g., 1, 2, 3, 4)

  @Column({ name: 'total_amount', type: 'decimal', precision: 10, scale: 2, nullable: true })
  totalAmount: number; // Total original amount before splitting into installments

  @Column({ name: 'payment_method', length: 50 })
  paymentMethod: string;

  @Column({ length: 50, default: 'pending' })
  status: string; // pending, completed, failed, refunded

  @Column({ name: 'commission', type: 'decimal', precision: 10, scale: 2, default: 0 })
  commission: number;

  @Column({ name: 'store_amount', type: 'decimal', precision: 10, scale: 2, default: 0 })
  storeAmount: number;

  @Column({ name: 'bank_commission_rate', type: 'decimal', precision: 5, scale: 2, nullable: true })
  bankCommissionRate: number;

  @Column({ name: 'platform_commission_rate', type: 'decimal', precision: 5, scale: 2, nullable: true })
  platformCommissionRate: number;

  @Column({ name: 'transaction_id', length: 255, nullable: true, unique: true })
  transactionId: string;

  @Column({ name: 'store_transaction_id', length: 255, nullable: true })
  storeTransactionId: string;

  @Column({ name: 'user_transaction_id', length: 255, nullable: true })
  userTransactionId: string;

  @Column({ name: 'due_date', type: 'timestamp', nullable: true })
  dueDate: Date;

  @Column({ name: 'paid_at', type: 'timestamp', nullable: true })
  paidAt: Date;

  @Column({ name: 'extension_requested', default: false })
  extensionRequested: boolean;

  @Column({ name: 'extension_days', nullable: true })
  extensionDays: number;

  // Postponement fields (for one-time postponement)
  @Column({ name: 'is_postponed', default: false })
  isPostponed: boolean; // Indicates if payment has been postponed

  @Column({ name: 'postponed_days', nullable: true })
  postponedDays: number; // Number of days postponed

  @Column({ name: 'postponed_due_date', type: 'timestamp', nullable: true })
  postponedDueDate: Date; // New due date after postponement

  @Column({ name: 'free_postpone_used', default: false })
  freePostponeUsed: boolean; // Track if free postponement used for THIS payment

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.payments)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Store, (store) => store.payments)
  @JoinColumn({ name: 'store_id' })
  store: Store;

  @OneToMany(() => Postponement, (postponement) => postponement.payment)
  postponements: Postponement[];
}

