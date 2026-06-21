import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { FeaturedBrandsService } from './featured-brands.service';
import { FeaturedBrand } from './entities/featured-brand.entity';
import { CreateFeaturedBrandDto } from './dto/create-featured-brand.dto';
import { UpdateFeaturedBrandDto } from './dto/update-featured-brand.dto';

@ApiTags('featured-brands')
@Controller('featured-brands')
export class FeaturedBrandsController {
  constructor(private readonly featuredBrandsService: FeaturedBrandsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all active featured brands' })
  @ApiResponse({ status: 200, description: 'List of active featured brands' })
  async getActive() {
    const brands = await this.featuredBrandsService.findAllActive();
    return {
      success: true,
      data: brands,
    };
  }

  @Get('admin')
  @ApiOperation({ summary: 'Get all featured brands for admin dashboard' })
  @ApiResponse({ status: 200, description: 'List of all featured brands' })
  async getAllAdmin() {
    const brands = await this.featuredBrandsService.findAllAdmin();
    return {
      success: true,
      data: brands,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get featured brand by ID' })
  @ApiResponse({ status: 200, description: 'Featured brand details' })
  @ApiResponse({ status: 404, description: 'Featured brand not found' })
  async getOne(@Param('id', ParseIntPipe) id: number) {
    const brand = await this.featuredBrandsService.findOne(id);
    return {
      success: true,
      data: brand,
    };
  }

  @Post()
  @ApiOperation({ summary: 'Create a new featured brand' })
  @ApiResponse({ status: 201, description: 'Featured brand created successfully' })
  async create(@Body() createDto: CreateFeaturedBrandDto) {
    const brand = await this.featuredBrandsService.create(createDto);
    return {
      success: true,
      message: 'تم إضافة العلامة التجارية المميزة بنجاح',
      data: brand,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update featured brand' })
  @ApiResponse({ status: 200, description: 'Featured brand updated successfully' })
  @ApiResponse({ status: 404, description: 'Featured brand not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateFeaturedBrandDto,
  ) {
    const brand = await this.featuredBrandsService.update(id, updateDto);
    return {
      success: true,
      message: 'تم تحديث العلامة التجارية المميزة بنجاح',
      data: brand,
    };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete featured brand' })
  @ApiResponse({ status: 200, description: 'Featured brand deleted successfully' })
  @ApiResponse({ status: 404, description: 'Featured brand not found' })
  async delete(@Param('id', ParseIntPipe) id: number) {
    await this.featuredBrandsService.delete(id);
    return {
      success: true,
      message: 'تم حذف العلامة التجارية المميزة بنجاح',
    };
  }
}
