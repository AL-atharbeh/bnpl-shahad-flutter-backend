import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { ProfitDistributionService } from './profit-distribution.service';

@ApiTags('Profit Distribution')
@Controller('profit-distribution')
export class ProfitDistributionController {
    constructor(private readonly profitDistributionService: ProfitDistributionService) { }

    @Get('stats')
    @ApiOperation({ summary: 'Get profit distribution statistics' })
    async getDistributionStats() {
        return this.profitDistributionService.getDistributionStats();
    }

    @Get('chart')
    @ApiOperation({ summary: 'Get weekly chart data' })
    async getWeeklyChart(@Query('days') days: number = 7) {
        return this.profitDistributionService.getWeeklyChart(days);
    }
}
