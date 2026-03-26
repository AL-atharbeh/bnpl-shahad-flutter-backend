import { Controller, Get, Put, Post, Body, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { StoresService } from './stores.service';
import { ProductsService } from '../products/products.service';

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

  @Get('admin/all')
  @ApiOperation({ summary: 'Get all stores for admin (includes pending/inactive)' })
  async getAllAdminStores() {
    const stores = await this.storesService.getAllAdminStores();
    return {
      success: true,
      data: stores,
    };
  }

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

  @Post()
  @ApiOperation({ summary: 'Create new store' })
  async createStore(@Body() createStoreDto: any) {
    const store = await this.storesService.createStore(createStoreDto);
    return {
      success: true,
      data: store,
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

  @Put(':id/top-store')
  @ApiOperation({ summary: 'Toggle top store status' })
  async toggleTopStore(@Param('id', ParseIntPipe) id: number) {
    const store = await this.storesService.toggleTopStore(id);
    return {
      success: true,
      data: store,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get store by ID' })
  async getStore(@Param('id') id: number) {
    const store = await this.storesService.getStoreById(id);
    return {
      success: true,
      data: store,
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

  @Put(':id')
  @ApiOperation({ summary: 'Update store details' })
  async updateStore(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateStoreDto: any,
  ) {
    const store = await this.storesService.updateStore(id, updateStoreDto);
    return {
      success: true,
      data: store,
    };
  }
}

