import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PostponementsService } from './postponements.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('postponements')
@Controller('postponements')
export class PostponementsController {
  constructor(private readonly postponementsService: PostponementsService) { }

  @Get('can-postpone')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Check if user can use free postponement' })
  async canPostpone(@Request() req) {
    const canPostpone = await this.postponementsService.canPostponeForFree(
      req.user.id,
    );
    const daysRemaining = await this.postponementsService.getDaysUntilNextPostpone(
      req.user.id,
    );

    return {
      success: true,
      data: {
        canPostpone,
        daysUntilNext: daysRemaining,
      },
    };
  }

  @Post('postpone-free')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Use free monthly postponement (10 days)' })
  async postponeForFree(
    @Request() req,
    @Body('paymentId') paymentId: number,
    @Body('merchantName') merchantName: string,
    @Body('amount') amount: number,
  ) {
    const postponement = await this.postponementsService.postponeForFree(
      req.user.id,
      paymentId,
      merchantName,
      amount,
    );

    return {
      success: true,
      message: 'تم تأجيل القسط بنجاح لمدة 10 أيام',
      data: postponement,
    };
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get postponement history' })
  async getHistory(@Request() req) {
    const history = await this.postponementsService.getPostponementHistory(
      req.user.id,
    );

    return {
      success: true,
      data: history,
    };
  }

  // Admin endpoints
  @Get('admin/stats')
  @ApiOperation({ summary: 'Get postponements statistics for admin' })
  async getAdminStats() {
    return this.postponementsService.getAdminStats();
  }

  @Get('admin/all')
  @ApiOperation({ summary: 'Get all postponements for admin' })
  async getAllPostponements(@Request() req) {
    const { page = 1, limit = 10, userId, paymentId, startDate, endDate } = req.query;
    return this.postponementsService.getAllPostponementsForAdmin({
      page: parseInt(page),
      limit: parseInt(limit),
      userId: userId ? parseInt(userId) : undefined,
      paymentId: paymentId ? parseInt(paymentId) : undefined,
      startDate,
      endDate,
    });
  }

  @Get('admin/chart-data')
  @ApiOperation({ summary: 'Get postponements chart data for admin' })
  async getChartData() {
    return this.postponementsService.getChartData();
  }
}

