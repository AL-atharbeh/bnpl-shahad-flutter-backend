import { Injectable, NotFoundException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InAppNotification } from './entities/in-app-notification.entity';
import { Notification } from './entities/notification.entity';

@Injectable()
export class InAppNotificationsService {
  constructor(
    @InjectRepository(InAppNotification)
    private inAppNotificationRepository: Repository<InAppNotification>,
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
  ) {}

  /**
   * Create in-app notification linked to main notification
   */
  async createInAppNotification(
    notificationId: number,
    userId: number,
    options?: {
      priority?: string;
      category?: string;
      actionButtonText?: string;
      actionUrl?: string;
      expiresAt?: Date;
      metadata?: Record<string, any>;
    },
  ): Promise<InAppNotification> {
    // Verify that the notification exists
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    // Check if in-app notification already exists
    const existing = await this.inAppNotificationRepository.findOne({
      where: { notificationId },
    });

    if (existing) {
      return existing;
    }

    // Create new in-app notification
    const inAppNotification = this.inAppNotificationRepository.create({
      notificationId,
      userId,
      priority: options?.priority || 'medium',
      category: options?.category || null,
      actionButtonText: options?.actionButtonText || null,
      actionUrl: options?.actionUrl || null,
      expiresAt: options?.expiresAt || null,
      metadata: options?.metadata || null,
    });

    return await this.inAppNotificationRepository.save(inAppNotification);
  }

  /**
   * Get all in-app notifications for a user
   */
  async getUserInAppNotifications(userId: number): Promise<InAppNotification[]> {
    return await this.inAppNotificationRepository.find({
      where: { userId },
      relations: ['notification', 'user'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get unread in-app notifications for a user
   */
  async getUnreadInAppNotifications(userId: number): Promise<InAppNotification[]> {
    return await this.inAppNotificationRepository
      .createQueryBuilder('inApp')
      .leftJoinAndSelect('inApp.notification', 'notification')
      .where('inApp.userId = :userId', { userId })
      .andWhere('notification.isRead = :isRead', { isRead: false })
      .orderBy('inApp.createdAt', 'DESC')
      .getMany();
  }

  /**
   * Mark notification as displayed
   */
  async markAsDisplayed(id: number): Promise<void> {
    await this.inAppNotificationRepository.update(id, {
      isDisplayed: true,
      displayedAt: new Date(),
    });
  }

  /**
   * Mark notification as clicked
   */
  async markAsClicked(id: number): Promise<void> {
    await this.inAppNotificationRepository.update(id, {
      isClicked: true,
      clickedAt: new Date(),
    });
  }

  /**
   * Delete in-app notification
   */
  async deleteInAppNotification(id: number): Promise<void> {
    await this.inAppNotificationRepository.delete(id);
  }

  /**
   * Get notification statistics for a user
   */
  async getUserNotificationStats(userId: number): Promise<{
    total: number;
    unread: number;
    displayed: number;
    clicked: number;
  }> {
    const total = await this.inAppNotificationRepository.count({
      where: { userId },
    });

    const unread = await this.inAppNotificationRepository
      .createQueryBuilder('inApp')
      .leftJoin('inApp.notification', 'notification')
      .where('inApp.userId = :userId', { userId })
      .andWhere('notification.isRead = :isRead', { isRead: false })
      .getCount();

    const displayed = await this.inAppNotificationRepository.count({
      where: { userId, isDisplayed: true },
    });

    const clicked = await this.inAppNotificationRepository.count({
      where: { userId, isClicked: true },
    });

    return {
      total,
      unread,
      displayed,
      clicked,
    };
  }
}

