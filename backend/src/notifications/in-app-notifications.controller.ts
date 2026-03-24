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
import { InAppNotificationsService } from './in-app-notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('in-app-notifications')
@Controller('in-app-notifications')
export class InAppNotificationsController {
  constructor(
    private readonly inAppNotificationsService: InAppNotificationsService,
  ) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all in-app notifications for current user' })
  async getInAppNotifications(@Request() req) {
    const notifications = await this.inAppNotificationsService.getUserInAppNotifications(
      req.user.id,
    );
    return {
      success: true,
      data: notifications,
    };
  }

  @Get('unread')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get unread in-app notifications' })
  async getUnreadInAppNotifications(@Request() req) {
    const notifications = await this.inAppNotificationsService.getUnreadInAppNotifications(
      req.user.id,
    );
    return {
      success: true,
      data: notifications,
    };
  }

  @Get('stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get notification statistics' })
  async getNotificationStats(@Request() req) {
    const stats = await this.inAppNotificationsService.getUserNotificationStats(
      req.user.id,
    );
    return {
      success: true,
      data: stats,
    };
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create in-app notification from existing notification' })
  async createInAppNotification(
    @Request() req,
    @Body()
    body: {
      notificationId: number;
      priority?: string;
      category?: string;
      actionButtonText?: string;
      actionUrl?: string;
      expiresAt?: string;
      metadata?: Record<string, any>;
    },
  ) {
    const inAppNotification = await this.inAppNotificationsService.createInAppNotification(
      body.notificationId,
      req.user.id,
      {
        priority: body.priority,
        category: body.category,
        actionButtonText: body.actionButtonText,
        actionUrl: body.actionUrl,
        expiresAt: body.expiresAt ? new Date(body.expiresAt) : undefined,
        metadata: body.metadata,
      },
    );
    return {
      success: true,
      message: 'تم إنشاء إشعار داخل التطبيق بنجاح',
      data: inAppNotification,
    };
  }

  @Put(':id/displayed')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Mark in-app notification as displayed' })
  async markAsDisplayed(@Param('id') id: number) {
    await this.inAppNotificationsService.markAsDisplayed(id);
    return {
      success: true,
      message: 'تم تحديد الإشعار كمعروض',
    };
  }

  @Put(':id/clicked')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Mark in-app notification as clicked' })
  async markAsClicked(@Param('id') id: number) {
    await this.inAppNotificationsService.markAsClicked(id);
    return {
      success: true,
      message: 'تم تحديد الإشعار كمضغوط',
    };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete in-app notification' })
  async deleteInAppNotification(@Param('id') id: number) {
    await this.inAppNotificationsService.deleteInAppNotification(id);
    return {
      success: true,
      message: 'تم حذف الإشعار',
    };
  }
}

