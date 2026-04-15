import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { RewardsService } from './rewards.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CashoutStatus } from './entities/reward-cashout-request.entity';

@ApiTags('rewards')
@Controller('rewards')
export class RewardsController {
  constructor(private readonly rewardsService: RewardsService) {}

  // ──────────────────────────────────────────────
  //  USER ENDPOINTS (require JWT auth)
  // ──────────────────────────────────────────────

  @Get('summary')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get points balance, JOD value, and cashout eligibility' })
  async getSummary(@Request() req) {
    const summary = await this.rewardsService.getPointsSummary(req.user.id);
    return { success: true, data: summary };
  }

  /** @deprecated Use /summary instead */
  @Get('points')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current reward points balance (legacy)' })
  async getPoints(@Request() req) {
    const points = await this.rewardsService.getUserPoints(req.user.id);
    return { success: true, data: { currentPoints: points } };
  }

  @Get('history')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get points transaction history' })
  async getHistory(@Request() req) {
    const history = await this.rewardsService.getPointsHistory(req.user.id);
    return { success: true, data: history };
  }

  @Get('my-cashout-requests')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my cashout requests history' })
  async getMyCashoutRequests(@Request() req) {
    const requests = await this.rewardsService.getUserCashoutRequests(req.user.id);
    return { success: true, data: requests };
  }

  @Post('cashout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Request cash transfer via ClickPay (min 1000 points = 10 JOD)',
  })
  async requestCashout(
    @Request() req,
    @Body('clickPayLink') clickPayLink: string,
  ) {
    const result = await this.rewardsService.requestCashout(req.user.id, clickPayLink);
    return {
      success: true,
      message: 'تم إرسال طلب الصرف بنجاح، سيتم مراجعته من قِبَل الإدارة.',
      data: result,
    };
  }

  /** @deprecated */
  @Post('redeem')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Redeem points for discount (legacy)' })
  async redeemPoints(@Request() req, @Body('points') points: number) {
    const rewardPoint = await this.rewardsService.redeemPoints(req.user.id, points);
    return { success: true, message: 'تم استبدال النقاط بنجاح', data: rewardPoint };
  }

  // ──────────────────────────────────────────────
  //  ADMIN ENDPOINTS (no auth required — same as other admin controllers)
  // ──────────────────────────────────────────────

  @Get('admin/cashout-requests')
  @ApiOperation({ summary: '[ADMIN] Get all cashout requests' })
  @ApiQuery({ name: 'status', required: false, enum: CashoutStatus })
  async getAllCashoutRequests(@Query('status') status?: CashoutStatus) {
    const requests = await this.rewardsService.getAllCashoutRequests(status);
    return { success: true, data: requests };
  }

  @Get('admin/cashout-requests/pending-count')
  @ApiOperation({ summary: '[ADMIN] Get count of pending cashout requests (for badge)' })
  async getPendingCount() {
    const count = await this.rewardsService.getPendingCashoutCount();
    return { success: true, data: { pendingCount: count } };
  }

  @Patch('admin/cashout-requests/:id/status')
  @ApiOperation({ summary: '[ADMIN] Approve or reject a cashout request' })
  async updateCashoutStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body('status') status: CashoutStatus,
    @Body('adminNote') adminNote?: string,
  ) {
    const updated = await this.rewardsService.updateCashoutStatus(id, status, adminNote);
    return {
      success: true,
      message: status === CashoutStatus.APPROVED ? 'تمت الموافقة على طلب الصرف' : 'تم رفض طلب الصرف',
      data: updated,
    };
  }
}
