import { Controller, Get, Post, Body, UseGuards, Put } from '@nestjs/common';
import { AppConfigService } from './app-config.service';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('app-config')
@Controller('app-config')
export class AppConfigController {
  constructor(private readonly appConfigService: AppConfigService) {}

  @Get('splash')
  @ApiOperation({ summary: 'Get current splash screen configuration' })
  getSplashConfig() {
    return this.appConfigService.getSplashConfig();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Get('all')
  @ApiOperation({ summary: 'Get all app configuration (Admin only)' })
  getConfig() {
    return this.appConfigService.getConfig();
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Post('splash')
  @ApiOperation({ summary: 'Update splash screen image' })
  updateSplash(@Body('imageUrl') imageUrl: string) {
    return this.appConfigService.updateSplashImage(imageUrl);
  }
}
