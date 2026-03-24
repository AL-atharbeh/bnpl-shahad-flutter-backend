import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AppService } from './app.service';

@ApiTags('App')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Get API information' })
  getHello(): any {
    return this.appService.getApiInfo();
  }

  @Get('health')
  @ApiOperation({ summary: 'Health check endpoint' })
  healthCheck(): any {
    return { status: 'ok', timestamp: new Date().toISOString() };
  }
}

