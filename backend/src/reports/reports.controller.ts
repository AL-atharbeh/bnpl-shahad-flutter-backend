import { Controller, ForbiddenException, Get, Query, Req, UseGuards } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('reports')
@ApiBearerAuth()
@Controller('reports')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'vendor')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  /**
   * These figures are commercially sensitive, so a vendor always reads its own
   * store no matter what storeId the request asks for. Only an admin may look
   * at another store, or at every store at once.
   */
  private resolveStoreId(req: any, storeId?: string): number | undefined {
    if (req.user?.role === 'vendor') {
      if (!req.user.storeId) {
        throw new ForbiddenException('لا يوجد متجر مرتبط بهذا الحساب');
      }
      return req.user.storeId;
    }

    if (!storeId || storeId === 'undefined' || storeId === 'null') {
      return undefined;
    }

    const parsed = parseInt(storeId, 10);
    return Number.isNaN(parsed) ? undefined : parsed;
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get dashboard statistics for reports' })
  async getDashboardStats(@Req() req: any, @Query('storeId') storeId?: string) {
    return this.reportsService.getDashboardStats(this.resolveStoreId(req, storeId));
  }

  @Get('performance')
  @ApiOperation({ summary: 'Get performance chart data' })
  async getPerformanceData(@Req() req: any, @Query('storeId') storeId?: string) {
    return this.reportsService.getPerformanceData(this.resolveStoreId(req, storeId));
  }

  @Get('risks')
  @ApiOperation({ summary: 'Get risk distribution data' })
  async getRiskDistribution(@Req() req: any, @Query('storeId') storeId?: string) {
    return this.reportsService.getRiskDistribution(this.resolveStoreId(req, storeId));
  }

  @Get('top-stores')
  @Roles('admin')
  @ApiOperation({ summary: 'Get top performing stores' })
  async getTopStores() {
    return this.reportsService.getTopStores();
  }

  @Get('sales-detailed')
  @ApiOperation({ summary: 'Get detailed sales operations for a store' })
  async getSalesDetailed(@Req() req: any, @Query('storeId') storeId?: string) {
    const resolved = this.resolveStoreId(req, storeId);

    if (!resolved) {
      throw new ForbiddenException('storeId مطلوب');
    }

    return this.reportsService.getSalesDetailed(resolved);
  }
}
