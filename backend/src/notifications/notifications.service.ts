import { Injectable, NotFoundException, Logger, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { FirebaseService } from '../firebase/firebase.service';
import { UsersService } from '../users/users.service';
import { InAppNotificationsService } from './in-app-notifications.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    private firebaseService: FirebaseService,
    private usersService: UsersService,
    @Inject(forwardRef(() => InAppNotificationsService))
    private inAppNotificationsService?: InAppNotificationsService,
  ) { }

  async getUserNotifications(userId: number): Promise<Notification[]> {
    return this.notificationRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(notificationId: number): Promise<void> {
    await this.notificationRepository.update(notificationId, {
      isRead: true,
      readAt: new Date(),
    });
  }

  async markAllAsRead(userId: number): Promise<void> {
    await this.notificationRepository.update(
      { userId, isRead: false },
      { isRead: true, readAt: new Date() },
    );
  }

  async deleteNotification(notificationId: number): Promise<void> {
    await this.notificationRepository.delete(notificationId);
  }

  /**
   * Send notification to a single user
   */
  async sendToUser(
    userId: number,
    title: string,
    body: string,
    data?: Record<string, string>,
    type?: string,
  ) {
    // Get user's FCM token
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Save notification to database
    const notification = this.notificationRepository.create({
      userId,
      title,
      message: body,
      type: type || 'system',
      metadata: data,
    });
    await this.notificationRepository.save(notification);

    // Send via Firebase if user has FCM token
    if (user.fcmToken) {
      try {
        this.logger.log(`📱 Attempting to send FCM to user ${userId}. Token: ${user.fcmToken.substring(0, 10)}...`);
        this.logger.log(`📊 FCM Data: ${JSON.stringify(data)}`);
        const response = await this.firebaseService.sendToDevice(user.fcmToken, { title, body }, data);
        this.logger.log(`✅ FCM Notification response: ${JSON.stringify(response)}`);
      } catch (error) {
        this.logger.error(`❌ Failed to send FCM notification to user ${userId}:`, error.stack);
      }
    } else {
      this.logger.warn(`⚠️ User ${userId} does not have FCM token. Notification saved to database but not sent to device.`);
    }

    // Create in-app notification automatically
    if (this.inAppNotificationsService) {
      try {
        await this.inAppNotificationsService.createInAppNotification(
          notification.id,
          userId,
          {
            priority: type === 'urgent' ? 'urgent' : 'medium',
            category: type || 'system',
          },
        );
        this.logger.log(`In-app notification created for user ${userId}`);
      } catch (error) {
        this.logger.error(`Failed to create in-app notification:`, error);
      }
    }

    return notification;
  }

  /**
   * Send notification to multiple users
   */
  async sendToMultipleUsers(
    userIds: number[],
    title: string,
    body: string,
    data?: Record<string, string>,
    type?: string,
  ) {
    // Get users by IDs
    const users = await Promise.all(
      userIds.map(async (id) => {
        try {
          return await this.usersService.findById(id);
        } catch {
          return null;
        }
      }),
    );
    const validUsers = users.filter((u) => u !== null);
    const tokens = validUsers.filter((u) => u.fcmToken).map((u) => u.fcmToken);

    // Save notifications to database
    const notifications = userIds.map((userId) =>
      this.notificationRepository.create({
        userId,
        title,
        message: body,
        type: type || 'system',
        metadata: data,
      }),
    );
    await this.notificationRepository.save(notifications);

    // Send via Firebase
    if (tokens.length > 0) {
      try {
        await this.firebaseService.sendToMultipleDevices(tokens, { title, body }, data);
      } catch (error) {
        console.error('Failed to send FCM notifications:', error);
      }
    }

    return notifications;
  }

  /**
   * Send notification to a topic
   */
  async sendToTopic(topic: string, title: string, body: string, data?: Record<string, string>) {
    try {
      await this.firebaseService.sendToTopic(topic, { title, body }, data);
    } catch (error) {
      console.error('Failed to send topic notification:', error);
      throw error;
    }
  }

  /**
   * Subscribe user to a topic
   */
  async subscribeToTopic(userId: number, topic: string) {
    const user = await this.usersService.findById(userId);
    if (!user || !user.fcmToken) {
      throw new NotFoundException('User not found or no FCM token');
    }

    await this.firebaseService.subscribeToTopic([user.fcmToken], topic);
  }

  /**
   * Unsubscribe user from a topic
   */
  async unsubscribeFromTopic(userId: number, topic: string) {
    const user = await this.usersService.findById(userId);
    if (!user || !user.fcmToken) {
      throw new NotFoundException('User not found or no FCM token');
    }

    await this.firebaseService.unsubscribeFromTopic([user.fcmToken], topic);
  }
}
