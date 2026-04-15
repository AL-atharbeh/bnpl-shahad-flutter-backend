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

@Entity('saved_cards')
export class SavedCard {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'stripe_customer_id', length: 100 })
  stripeCustomerId: string;

  @Column({ name: 'stripe_payment_method_id', length: 100, unique: true })
  stripePaymentMethodId: string;

  @Column({ length: 50, nullable: true })
  brand: string;

  @Column({ length: 4 })
  last4: string;

  @Column({ name: 'exp_month' })
  expMonth: number;

  @Column({ name: 'exp_year' })
  expYear: number;

  @Column({ name: 'cardholder_name', length: 255, nullable: true })
  cardholderName: string;

  @Column({ name: 'is_default', default: false })
  isDefault: boolean;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.payments) // Reusing the relation logic if needed, or just standard ManyToOne
  @JoinColumn({ name: 'user_id' })
  user: User;
}
