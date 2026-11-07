import { Controller, Get, Put, Post, Delete, Body, Param, Query, ParseIntPipe, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { StoresService } from './stores.service';
import { ProductsService } from '../products/products.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { assertStoreAccess, publicStore } from '../auth/store-access';
import { ShowStoreCredentials } from '../common/hide-store-credentials.interceptor';

/** Fields only an admin may set: money, approval and placement. */
const ADMIN_ONLY_STORE_FIELDS = [
  'rating',
  'commissionRate',
  'bankCommissionRate',
  'platformCommissionRate',
  'isActive',
  'topStore',
  'vendorId',
  'status',
  'payoutCycle',
] as const;

@ApiTags('stores')
@Controller('stores')
export class StoresController {
  constructor(
    private readonly storesService: StoresService,
    private readonly productsService: ProductsService,
  ) { }

  @Get()
  @ApiOperation({ summary: 'Get all stores' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  @ApiQuery({ name: 'topStore', required: false, type: Boolean, description: 'Filter by top stores (1 or 0)' })
  @ApiQuery({ name: 'genderCategoryId', required: false, type: Number, description: 'Filter by gender category ID (Women, Men, Kids)' })
  async getAllStores(
    @Query('categoryId') categoryId?: number,
    @Query('topStore') topStore?: string,
    @Query('genderCategoryId') genderCategoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const topStoreBool = topStore === 'true' || topStore === '1' ? true : undefined;
    const genderCategoryIdNum = genderCategoryId ? parseInt(genderCategoryId.toString()) : undefined;
    const stores = await this.storesService.getAllStores(categoryIdNum, topStoreBool, genderCategoryIdNum);
    return {
      success: true,
      data: stores,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @ShowStoreCredentials()
  @Get('admin/all')
  @ApiOperation({ summary: 'Get all stores for admin (includes pending/inactive)' })
  async getAllAdminStores() {
    const stores = await this.storesService.getAllAdminStores();
    return {
      success: true,
      data: stores,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Put('admin/:id/status')
  @ApiOperation({ summary: 'Update store status (approve/reject)' })
  async updateStoreStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body('status') status: string,
  ) {
    const store = await this.storesService.updateStoreStatus(id, status);
    return {
      success: true,
      data: store,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Get('admin/vendors')
  @ApiOperation({ summary: 'Get all vendors for admin dropdown' })
  async getAllVendors() {
    const vendors = await this.storesService.getAllVendors();
    return {
      success: true,
      data: vendors,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Post()
  @ApiOperation({ summary: 'Create new store' })
  async createStore(@Body() createStoreDto: CreateStoreDto) {
    const store = await this.storesService.createStore(createStoreDto);
    return {
      success: true,
      data: store,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Delete(':id')
  @ApiOperation({ summary: 'Delete store' })
  async deleteStore(@Param('id', ParseIntPipe) id: number) {
    await this.storesService.deleteStore(id);
    return {
      success: true,
      message: 'تم حذف المتجر بنجاح',
    };
  }

  @Get('deals')
  @ApiOperation({ summary: 'Get stores with active deals' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async getStoresWithDeals(@Query('categoryId') categoryId?: number) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const stores = await this.storesService.getStoresWithDeals(categoryIdNum);
    return {
      success: true,
      data: stores,
    };
  }

  @Get('search')
  @ApiOperation({ summary: 'Search stores' })
  @ApiQuery({ name: 'q', required: true, description: 'Search query' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async searchStores(
    @Query('q') query: string,
    @Query('categoryId') categoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const stores = await this.storesService.searchStores(query, categoryIdNum);
    return {
      success: true,
      data: stores,
    };
  }

  @Get('category/:categoryId')
  @ApiOperation({ summary: 'Get stores by category' })
  async getStoresByCategory(@Param('categoryId', ParseIntPipe) categoryId: number) {
    const stores = await this.storesService.getStoresByCategory(categoryId);
    return {
      success: true,
      data: stores,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Put(':id/top-store')
  @ApiOperation({ summary: 'Toggle top store status' })
  async toggleTopStore(@Param('id', ParseIntPipe) id: number) {
    const store = await this.storesService.toggleTopStore(id);
    return {
      success: true,
      data: store,
    };
  }

  /**
   * Public, since the customer app opens store pages. The store's own vendor
   * and admins also get its API keys, for the credentials screen.
   */
  @UseGuards(OptionalJwtAuthGuard)
  @ShowStoreCredentials()
  @Get(':id')
  @ApiOperation({ summary: 'Get store by ID' })
  async getStore(@Param('id') id: number, @Req() req: any) {
    const isOwnerOrAdmin =
      req.user?.role === 'admin' ||
      (req.user?.role === 'vendor' && Number(req.user.storeId) === Number(id));
    const store = await this.storesService.getStoreById(id, isOwnerOrAdmin);
    return {
      success: true,
      data: isOwnerOrAdmin ? store : publicStore(store),
    };
  }

  @Get(':id/products')
  @ApiOperation({ summary: 'Get products for store' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async getStoreProducts(
    @Param('id', ParseIntPipe) id: number,
    @Query('categoryId') categoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const products = await this.productsService.getProductsByStore(id, categoryIdNum);
    return {
      success: true,
      data: products,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @Put(':id')
  @ApiOperation({ summary: 'Update store details' })
  async updateStore(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateStoreDto: UpdateStoreDto,
    @Req() req: any,
  ) {
    assertStoreAccess(req.user, id);

    if (req.user.role === 'vendor') {
      const blocked = ADMIN_ONLY_STORE_FIELDS.filter((f) => updateStoreDto[f] !== undefined);
      if (blocked.length) {
        throw new ForbiddenException(`هذه الحقول يعدّلها المشرف فقط: ${blocked.join(', ')}`);
      }
    }

    const store = await this.storesService.updateStore(id, updateStoreDto);
    return {
      success: true,
      data: store,
    };
  }
}
