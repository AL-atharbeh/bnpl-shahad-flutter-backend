import { Controller, Get, Post, Body, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { SettlementsService } from './settlements.service';

@ApiTags('Settlements')
@Controller('settlements')
export class SettlementsController {
    constructor(private readonly settlementsService: SettlementsService) { }

    @Get('stats')
    @ApiOperation({ summary: 'Get settlement stats (pending balance, last transfer)' })
    async getStats(
        @Query('storeId', ParseIntPipe) storeId: number,
    ) {
        return this.settlementsService.getSettlementStats(storeId);
    }

    @Get('admin/all')
    @ApiOperation({ summary: 'Get all settlements' })
    async getAllSettlements(
        @Query('page') page: number = 1,
        @Query('limit') limit: number = 10,
        @Query('storeId') storeId?: number,
    ) {
        return this.settlementsService.getAllSettlements({ page, limit, storeId });
    }

    @Post('admin/create')
    @ApiOperation({ summary: 'Create a new settlement' })
    async createSettlement(
        @Body() data: {
            settlementDate: Date;
            totalCollected: number;
            bankShare: number;
            platformShare: number;
            notes?: string;
            paymentIds?: number[];
        },
    ) {
        return this.settlementsService.createSettlement(data);
    }

    @Get('admin/:id')
    @ApiOperation({ summary: 'Get settlement by ID' })
    async getSettlementById(@Param('id') id: number) {
        return this.settlementsService.getSettlementById(id);
    }
}
