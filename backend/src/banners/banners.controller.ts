import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { BannersService } from './banners.service';
import { Banner } from './entities/banner.entity';

@ApiTags('banners')
@Controller('banners')
export class BannersController {
  constructor(private readonly bannersService: BannersService) {}

  @Get()
  @ApiOperation({ summary: 'Get all active banners' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  @ApiResponse({ status: 200, description: 'List of banners' })
  async getAllBanners(@Query('categoryId') categoryId?: number) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const banners = await this.bannersService.getAllBanners(categoryIdNum);
    return {
      success: true,
      data: banners,
    };
  }

  @Get('admin')
  @ApiOperation({ summary: 'Get all banners (including inactive) - Admin only' })
  @ApiResponse({ status: 200, description: 'List of all banners' })
  async getAllBannersAdmin() {
    const banners = await this.bannersService.getAllBannersAdmin();
    return {
      success: true,
      data: banners,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get banner by ID' })
  @ApiResponse({ status: 200, description: 'Banner details' })
  @ApiResponse({ status: 404, description: 'Banner not found' })
  async getBanner(@Param('id', ParseIntPipe) id: number) {
    const banner = await this.bannersService.getBannerById(id);
    return {
      success: true,
      data: banner,
    };
  }

  @Post()
  @ApiOperation({ summary: 'Create a new banner' })
  @ApiResponse({ status: 201, description: 'Banner created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  async createBanner(@Body() bannerData: Partial<Banner>) {
    const banner = await this.bannersService.createBanner(bannerData);
    return {
      success: true,
      message: 'تم إنشاء البانر بنجاح',
      data: banner,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update banner' })
  @ApiResponse({ status: 200, description: 'Banner updated successfully' })
  @ApiResponse({ status: 404, description: 'Banner not found' })
  async updateBanner(
    @Param('id', ParseIntPipe) id: number,
    @Body() bannerData: Partial<Banner>,
  ) {
    const banner = await this.bannersService.updateBanner(id, bannerData);
    return {
      success: true,
      message: 'تم تحديث البانر بنجاح',
      data: banner,
    };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete banner' })
  @ApiResponse({ status: 200, description: 'Banner deleted successfully' })
  @ApiResponse({ status: 404, description: 'Banner not found' })
  async deleteBanner(@Param('id', ParseIntPipe) id: number) {
    await this.bannersService.deleteBanner(id);
    return {
      success: true,
      message: 'تم حذف البانر بنجاح',
    };
  }

  @Post(':id/click')
  @ApiOperation({ summary: 'Increment banner click count' })
  @ApiResponse({ status: 200, description: 'Click count incremented' })
  async incrementClick(@Param('id', ParseIntPipe) id: number) {
    await this.bannersService.incrementClickCount(id);
    return {
      success: true,
      message: 'تم تحديث عدد النقرات',
    };
  }

  @Get('category/:categoryId')
  @ApiOperation({ summary: 'Get banners by category' })
  async getBannersByCategory(@Param('categoryId', ParseIntPipe) categoryId: number) {
    const banners = await this.bannersService.getBannersByCategory(categoryId);
    return {
      success: true,
      data: banners,
    };
  }
}

