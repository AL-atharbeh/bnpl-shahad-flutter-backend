import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { RewardsService } from './rewards.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('rewards')
@Controller('rewards')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class RewardsController {
  constructor(private readonly rewardsService: RewardsService) {}

  @Get('points')
  @ApiOperation({ summary: 'Get current reward points balance' })
  async getPoints(@Request() req) {
    const points = await this.rewardsService.getUserPoints(req.user.id);
    return {
      success: true,
      data: {
        currentPoints: points,
      },
    };
  }

  @Get('history')
  @ApiOperation({ summary: 'Get points transaction history' })
  async getHistory(@Request() req) {
    const history = await this.rewardsService.getPointsHistory(req.user.id);
    return {
      success: true,
      data: history,
    };
  }

  @Post('redeem')
  @ApiOperation({ summary: 'Redeem points for discount' })
  async redeemPoints(@Request() req, @Body('points') points: number) {
    const rewardPoint = await this.rewardsService.redeemPoints(req.user.id, points);
    return {
      success: true,
      message: 'تم استبدال النقاط بنجاح',
      data: rewardPoint,
    };
  }
}

