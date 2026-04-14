import { Controller, Get, Post, Body, UseGuards, Put } from '@nestjs/common';
import { AppConfigService } from './app-config.service';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('app-config')
@Controller('app-config')
export class AppConfigController {
  constructor(private readonly appConfigService: AppConfigService) {}

  @Get('splash')
  @ApiOperation({ summary: 'Get current splash screen configuration' })
  getSplashConfig() {
    return this.appConfigService.getSplashConfig();
  }

  @Get('all')
  @ApiOperation({ summary: 'Get all app configuration (Admin only)' })
  getConfig() {
    return this.appConfigService.getConfig();
  }

  @Post('splash')
  @ApiOperation({ summary: 'Update splash screen image' })
  updateSplash(@Body('imageUrl') imageUrl: string) {
    return this.appConfigService.updateSplashImage(imageUrl);
  }
}
