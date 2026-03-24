import { Controller, Get, Query, ParseIntPipe } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('reports')
@Controller('reports')
export class ReportsController {
    constructor(private readonly reportsService: ReportsService) { }

    @Get('stats')
    @ApiOperation({ summary: 'Get dashboard statistics for reports' })
    async getDashboardStats(@Query('storeId', new ParseIntPipe({ optional: true })) storeId?: number) {
        return this.reportsService.getDashboardStats(storeId);
    }

    @Get('performance')
    @ApiOperation({ summary: 'Get performance chart data' })
    async getPerformanceData(@Query('storeId', new ParseIntPipe({ optional: true })) storeId?: number) {
        return this.reportsService.getPerformanceData(storeId);
    }

    @Get('risks')
    @ApiOperation({ summary: 'Get risk distribution data' })
    async getRiskDistribution(@Query('storeId', new ParseIntPipe({ optional: true })) storeId?: number) {
        return this.reportsService.getRiskDistribution(storeId);
    }

    @Get('top-stores')
    @ApiOperation({ summary: 'Get top performing stores' })
    async getTopStores() {
        return this.reportsService.getTopStores();
    }

    @Get('sales-detailed')
    @ApiOperation({ summary: 'Get detailed sales operations for a store' })
    async getSalesDetailed(@Query('storeId', ParseIntPipe) storeId: number) {
        return this.reportsService.getSalesDetailed(storeId);
    }
}
