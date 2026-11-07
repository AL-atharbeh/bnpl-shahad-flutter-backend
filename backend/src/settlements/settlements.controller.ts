import { Controller, Get, Post, Put, Body, Param, Query, ParseIntPipe, UseGuards, Req, BadRequestException } from '@nestjs/common';
import { ApiOperation, ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { SettlementsService } from './settlements.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { scopedStoreId } from '../auth/store-access';

@ApiTags('Settlements')
@Controller('settlements')
export class SettlementsController {
    constructor(private readonly settlementsService: SettlementsService) { }

    @Get('stats')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin', 'vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get settlement stats (pending balance, last transfer)' })
    async getStats(@Query('storeId') storeId: string, @Req() req: any) {
        const id = scopedStoreId(req.user, storeId);
        if (id === undefined) throw new BadRequestException('storeId مطلوب');
        return this.settlementsService.getSettlementStats(id);
    }

    @Get('mine')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: "The signed-in vendor's settlement history" })
    async getMySettlements(@Req() req: any, @Query('page') page?: string, @Query('limit') limit?: string) {
        return this.settlementsService.getStoreSettlementHistory(req.user.storeId, Number(page) || 1, Number(limit) || 20);
    }

    @Get('admin/stores-balances')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin')
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get all stores accounting and balance tracking summary' })
    async getStoresBalances() {
        return this.settlementsService.getStoresBalances();
    }

    @Get('admin/all')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin')
    @ApiBearerAuth()
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
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin')
    @ApiBearerAuth()
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
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin')
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get outstanding approved orders for a store that are not settled yet' })
    async getStoreOutstandingOrders(
        @Param('id', ParseIntPipe) id: number,
    ) {
        return this.settlementsService.getStoreOutstandingOrders(id);
    }

    @Get('admin/:id')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin')
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get settlement by ID' })
    async getSettlementById(@Param('id') id: number) {
        return this.settlementsService.getSettlementById(id);
    }
    
    // A vendor can only ask for their own store's money, whatever storeId the
    // body names.
    @Post('request')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin', 'vendor')
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Request immediate settlement' })
    async requestSettlement(
        @Body() data: { storeId: number; vendorName: string },
        @Req() req: any,
    ) {
        const id = scopedStoreId(req.user, data.storeId);
        if (id === undefined) throw new BadRequestException('storeId مطلوب');
        return this.settlementsService.requestSettlement(id, data.vendorName);
    }

    @Put('admin/:id/status')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles('admin')
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Update settlement status' })
    async updateSettlementStatus(
        @Param('id', ParseIntPipe) id: number,
        @Body() data: { status: string; notes?: string },
    ) {
        return this.settlementsService.updateSettlementStatus(id, data.status, data.notes);
    }
}
