import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { User } from './user.entity';

@Entity('user_security_settings')
export class UserSecuritySetting {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id', unique: true })
  userId: number;

  @OneToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'pin', type: 'varchar', length: 4, nullable: true })
  @Exclude()
  pin: string; // PIN must be exactly 4 digits

  @Column({ name: 'pin_enabled', type: 'boolean', default: false })
  pinEnabled: boolean;

  @Column({ name: 'biometric_enabled', type: 'boolean', default: false })
  biometricEnabled: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

