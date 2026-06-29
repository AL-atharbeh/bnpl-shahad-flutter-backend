import { Controller, Get, Query, ParseIntPipe } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('reports')
@Controller('reports')
export class ReportsController {
    constructor(private readonly reportsService: ReportsService) { }

    @Get('stats')
    @ApiOperation({ summary: 'Get dashboard statistics for reports' })
    async getDashboardStats(@Query('storeId') storeId?: string) {
        const parsedId = storeId && storeId !== 'undefined' && storeId !== 'null' ? parseInt(storeId) : undefined;
        return this.reportsService.getDashboardStats(parsedId);
    }

    @Get('performance')
    @ApiOperation({ summary: 'Get performance chart data' })
    async getPerformanceData(@Query('storeId') storeId?: string) {
        const parsedId = storeId && storeId !== 'undefined' && storeId !== 'null' ? parseInt(storeId) : undefined;
        return this.reportsService.getPerformanceData(parsedId);
    }

    @Get('risks')
    @ApiOperation({ summary: 'Get risk distribution data' })
    async getRiskDistribution(@Query('storeId') storeId?: string) {
        const parsedId = storeId && storeId !== 'undefined' && storeId !== 'null' ? parseInt(storeId) : undefined;
        return this.reportsService.getRiskDistribution(parsedId);
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
