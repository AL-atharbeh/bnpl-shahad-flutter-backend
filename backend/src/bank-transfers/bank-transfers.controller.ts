import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { BankTransfersService } from './bank-transfers.service';

@ApiTags('Bank Transfers')
@Controller('bank-transfers')
export class BankTransfersController {
    constructor(private readonly bankTransfersService: BankTransfersService) { }

    @Get('admin/all')
    @ApiOperation({ summary: 'Get all bank transfers' })
    async getAllTransfers(
        @Query('page') page: number = 1,
        @Query('limit') limit: number = 10,
    ) {
        return this.bankTransfersService.getAllTransfers({ page, limit });
    }

    @Post('admin/create')
    @ApiOperation({ summary: 'Record a new bank transfer' })
    async createTransfer(
        @Body() data: {
            transferDate: Date;
            amount: number;
            transferredBy?: string;
            notes?: string;
        },
    ) {
        return this.bankTransfersService.createTransfer(data);
    }
}
