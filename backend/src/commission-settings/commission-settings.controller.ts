import { Controller, Get, Post, Body } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CommissionSettingsService } from './commission-settings.service';

@ApiTags('Commission Settings')
@Controller('commission-settings')
export class CommissionSettingsController {
    constructor(private readonly commissionSettingsService: CommissionSettingsService) { }

    @Get('current')
    @ApiOperation({ summary: 'Get current commission settings' })
    async getCurrentSettings() {
        return this.commissionSettingsService.getCurrentSettings();
    }

    @Post('update')
    @ApiOperation({ summary: 'Update commission settings' })
    async updateSettings(
        @Body() data: {
            bankCommission: number;
            platformCommission: number;
            storeDiscount?: number;
            createdBy?: string;
        },
    ) {
        return this.commissionSettingsService.updateSettings(data);
    }

    @Get('history')
    @ApiOperation({ summary: 'Get commission settings history' })
    async getSettingsHistory() {
        return this.commissionSettingsService.getSettingsHistory();
    }
}
