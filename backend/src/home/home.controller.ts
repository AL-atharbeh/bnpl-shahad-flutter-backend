import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { HomeService } from './home.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('home')
@Controller('home')
export class HomeController {
  constructor(private readonly homeService: HomeService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get home page data',
    description:
      'Get all data needed for home page: stores, offers, featured, pending payments, notifications',
  })
  async getHomeData(@Request() req) {
    const userId = req.user?.id;
    const data = await this.homeService.getHomeData(userId);

    return {
      success: true,
      data,
    };
  }

  @Get('public')
  @ApiOperation({
    summary: 'Get public home page data (no auth required)',
    description: 'Get home page data without user-specific information',
  })
  async getPublicHomeData() {
    const data = await this.homeService.getHomeData();

    return {
      success: true,
      data,
    };
  }
}

