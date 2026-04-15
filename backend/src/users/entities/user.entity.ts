import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { Payment } from '../../payments/entities/payment.entity';
import { RewardPoint } from '../../rewards/entities/reward-point.entity';
import { Postponement } from '../../postponements/entities/postponement.entity';
import { Notification } from '../../notifications/entities/notification.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255 })
  name: string;

  @Column({ length: 20, unique: true })
  phone: string;

  @Column({ name: 'civil_id_number', length: 50, nullable: true })
  civilIdNumber: string;

  @Column({ length: 255, nullable: true, unique: true })
  email: string;

  @Column({ name: 'password_hash', length: 255 })
  @Exclude()
  passwordHash: string;

  @Column({ name: 'civil_id_front', type: 'longtext', nullable: true })
  civilIdFront: string;

  @Column({ name: 'civil_id_back', type: 'longtext', nullable: true })
  civilIdBack: string;

  @Column({ name: 'date_of_birth', type: 'date', nullable: true })
  dateOfBirth: Date;

  @Column({ type: 'text', nullable: true })
  address: string;

  @Column({ name: 'monthly_income', type: 'decimal', precision: 10, scale: 2, nullable: true })
  monthlyIncome: number;

  @Column({ length: 255, nullable: true })
  employer: string;

  @Column({ name: 'avatar_url', type: 'longtext', nullable: true })
  avatarUrl: string;

  @Column({ name: 'free_postponement_count', default: 0 })
  freePostponementCount: number; // Number of times user used free postponement

  @Column({ name: 'days_since_last_postponement', default: 0 })
  daysSinceLastPostponement: number; // Days counter since last postponement (0-30, resets to 0 when used)

  @Column({ name: 'free_postpone_used', default: false })
  freePostponeUsed: boolean; // Simple flag: has user used their one-time free postponement?

  @Column({ length: 6, nullable: true })
  otp: string;

  @Column({ name: 'is_phone_verified', default: false })
  isPhoneVerified: boolean;

  @Column({ name: 'is_email_verified', default: false })
  isEmailVerified: boolean;

  @Column({ length: 2, default: 'JO' })
  country: string;

  @Column({ length: 3, default: 'JOD' })
  currency: string;

  @Column({ length: 50, default: 'user' })
  role: string;


  @Column({ name: 'fcm_token', type: 'text', nullable: true })
  fcmToken: string;

  @Column({ name: 'stripe_customer_id', length: 100, nullable: true })
  stripeCustomerId: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @OneToMany(() => Payment, (payment) => payment.user)
  payments: Payment[];

  @OneToMany(() => RewardPoint, (rewardPoint) => rewardPoint.user)
  rewardPoints: RewardPoint[];

  @OneToMany(() => Postponement, (postponement) => postponement.user)
  postponements: Postponement[];

  @OneToMany(() => Notification, (notification) => notification.user)
  notifications: Notification[];
}

