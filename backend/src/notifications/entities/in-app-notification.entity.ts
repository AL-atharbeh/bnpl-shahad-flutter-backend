import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToOne,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Notification } from './notification.entity';

/**
 * In-App Notifications Entity
 * جدول منفصل للإشعارات داخل التطبيق
 * مرتبط بجدول notifications الأساسي
 */
@Entity('in_app_notifications')
export class InAppNotification {
  @PrimaryGeneratedColumn()
  id: number;

  // Relation to main notifications table
  @Column({ name: 'notification_id', unique: true })
  notificationId: number;

  @OneToOne(() => Notification, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'notification_id' })
  notification: Notification;

  // User who received the notification
  @Column({ name: 'user_id' })
  userId: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  // Notification display settings
  @Column({ name: 'is_displayed', default: false })
  isDisplayed: boolean;

  @Column({ name: 'displayed_at', type: 'timestamp', nullable: true })
  displayedAt: Date;

  // Notification interaction tracking
  @Column({ name: 'is_clicked', default: false })
  isClicked: boolean;

  @Column({ name: 'clicked_at', type: 'timestamp', nullable: true })
  clickedAt: Date;

  // Priority level (low, medium, high, urgent)
  @Column({ length: 20, default: 'medium' })
  priority: string;

  // Category for grouping notifications
  @Column({ length: 50, nullable: true })
  category: string;

  // Action button data (optional)
  @Column({ name: 'action_button_text', length: 100, nullable: true })
  actionButtonText: string;

  @Column({ name: 'action_url', type: 'text', nullable: true })
  actionUrl: string;

  // Expiration date (optional)
  @Column({ name: 'expires_at', type: 'timestamp', nullable: true })
  expiresAt: Date;

  // Additional metadata specific to in-app notifications
  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

