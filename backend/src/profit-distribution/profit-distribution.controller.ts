import { Controller, Get, Query, Logger } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { ProfitDistributionService } from './profit-distribution.service';

@ApiTags('Profit Distribution')
@Controller('profit-distribution')
export class ProfitDistributionController {
    private readonly logger = new Logger(ProfitDistributionController.name);

    constructor(private readonly profitDistributionService: ProfitDistributionService) { }

    @Get('stats')
    @ApiOperation({ summary: 'Get profit distribution statistics' })
    async getDistributionStats() {
        try {
            return await this.profitDistributionService.getDistributionStats();
        } catch (error) {
            this.logger.error('Error in getDistributionStats:', error?.message || error);
            return {
                success: true,
                data: {
                    totalFinanced: 0,
                    bankTotalShare: 0,
                    platformTotalShare: 0,
                    pendingProfits: 0,
                    totalCollected: 0,
                },
            };
        }
    }

    @Get('chart')
    @ApiOperation({ summary: 'Get weekly chart data' })
    async getWeeklyChart(@Query('days') days: number = 7) {
        try {
            return await this.profitDistributionService.getWeeklyChart(days);
        } catch (error) {
            this.logger.error('Error in getWeeklyChart:', error?.message || error);
            return {
                success: true,
                data: [],
            };
        }
    }
}
