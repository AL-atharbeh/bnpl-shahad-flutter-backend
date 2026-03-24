import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

@Entity('otp_codes')
export class OtpCode {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 20 })
  phone: string;

  @Column({ length: 6 })
  code: string;

  @Column({ name: 'expires_at', type: 'timestamp' })
  expiresAt: Date;

  @Column({ name: 'is_used', default: false })
  isUsed: boolean;

  @Column({ name: 'used_at', type: 'timestamp', nullable: true })
  usedAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

