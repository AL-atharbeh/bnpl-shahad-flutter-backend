import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  SendNotificationDto,
  SendBulkNotificationDto,
  SendTopicNotificationDto,
  SubscribeToTopicDto,
} from '../firebase/dto/notification.dto';

@ApiTags('notifications')
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) { }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all user notifications' })
  async getNotifications(@Request() req) {
    const notifications = await this.notificationsService.getUserNotifications(
      req.user.id,
    );
    return {
      success: true,
      data: notifications,
    };
  }

  @Put(':id/read')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Mark notification as read' })
  async markAsRead(@Param('id') id: number) {
    await this.notificationsService.markAsRead(id);
    return {
      success: true,
      message: 'تم تحديد الإشعار كمقروء',
    };
  }

  @Put('read-all')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Mark all notifications as read' })
  async markAllAsRead(@Request() req) {
    await this.notificationsService.markAllAsRead(req.user.id);
    return {
      success: true,
      message: 'تم تحديد جميع الإشعارات كمقروءة',
    };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete notification' })
  async deleteNotification(@Param('id') id: number) {
    await this.notificationsService.deleteNotification(id);
    return {
      success: true,
      message: 'تم حذف الإشعار',
    };
  }

  // Admin endpoints for sending notifications
  @Post('send')
  @ApiOperation({ summary: 'Send notification to a user (Admin)' })
  async sendNotification(@Body() dto: SendNotificationDto) {
    const notification = await this.notificationsService.sendToUser(
      parseInt(dto.userId),
      dto.title,
      dto.body,
      dto.data,
    );
    return {
      success: true,
      message: 'تم إرسال الإشعار بنجاح',
      data: notification,
    };
  }

  @Post('send-bulk')
  @ApiOperation({ summary: 'Send notification to multiple users (Admin)' })
  async sendBulkNotification(@Body() dto: SendBulkNotificationDto) {
    const notifications = await this.notificationsService.sendToMultipleUsers(
      dto.userIds.map((id) => parseInt(id)),
      dto.title,
      dto.body,
      dto.data,
    );
    return {
      success: true,
      message: 'تم إرسال الإشعارات بنجاح',
      data: notifications,
    };
  }

  @Post('send-topic')
  @ApiOperation({ summary: 'Send notification to a topic (Admin)' })
  async sendTopicNotification(@Body() dto: SendTopicNotificationDto) {
    await this.notificationsService.sendToTopic(
      dto.topic,
      dto.title,
      dto.body,
      dto.data,
    );
    return {
      success: true,
      message: 'تم إرسال الإشعار للموضوع بنجاح',
    };
  }

  @Post('subscribe-topic')
  @ApiOperation({ summary: 'Subscribe user to a topic' })
  async subscribeToTopic(@Body() dto: SubscribeToTopicDto) {
    await this.notificationsService.subscribeToTopic(
      parseInt(dto.userId),
      dto.topic,
    );
    return {
      success: true,
      message: 'تم الاشتراك في الموضوع بنجاح',
    };
  }
}

