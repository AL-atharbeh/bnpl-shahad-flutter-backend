import { Controller, Get, Post, Put, Body, Param, Query, ParseIntPipe } from '@nestjs/common';
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

    @Get('admin/stores-balances')
    @ApiOperation({ summary: 'Get all stores accounting and balance tracking summary' })
    async getStoresBalances() {
        return this.settlementsService.getStoresBalances();
    }

    @Get('admin/all')
    @ApiOperation({ summary: 'Get all settlements' })
    async getAllSettlements(
        @Query('page') page: number = 1,
        @Query('limit') limit: number = 10,
        @Query('storeId') storeId?: string,
        @Query('status') status?: string,
    ) {
        const parsedStoreId = storeId && storeId !== 'undefined' && storeId !== 'null' ? parseInt(storeId) : undefined;
        return this.settlementsService.getAllSettlements({ page, limit, storeId: parsedStoreId, status });
    }

    @Post('admin/create')
    @ApiOperation({ summary: 'Create a new settlement' })
    async createSettlement(
        @Body() data: {
            storeId: number;
            sessionIds: number[];
            notes?: string;
        },
    ) {
        return this.settlementsService.createSettlement(data);
    }

    @Get('admin/stores/:id/outstanding-orders')
    @ApiOperation({ summary: 'Get outstanding approved orders for a store that are not settled yet' })
    async getStoreOutstandingOrders(
        @Param('id', ParseIntPipe) id: number,
    ) {
        return this.settlementsService.getStoreOutstandingOrders(id);
    }

    @Get('admin/:id')
    @ApiOperation({ summary: 'Get settlement by ID' })
    async getSettlementById(@Param('id') id: number) {
        return this.settlementsService.getSettlementById(id);
    }
    
    @Post('request')
    @ApiOperation({ summary: 'Request immediate settlement' })
    async requestSettlement(
        @Body() data: { storeId: number; vendorName: string },
    ) {
        return this.settlementsService.requestSettlement(data.storeId, data.vendorName);
    }

    @Put('admin/:id/status')
    @ApiOperation({ summary: 'Update settlement status' })
    async updateSettlementStatus(
        @Param('id', ParseIntPipe) id: number,
        @Body() data: { status: string; notes?: string },
    ) {
        return this.settlementsService.updateSettlementStatus(id, data.status, data.notes);
    }
}
