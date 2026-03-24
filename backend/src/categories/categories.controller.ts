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
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { CategoriesService } from './categories.service';
import { Category } from './entities/category.entity';

@ApiTags('categories')
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all active categories' })
  @ApiResponse({ status: 200, description: 'List of categories' })
  async getAllCategories(@Query('genderType') genderType?: 'Women' | 'Men' | 'Kids' | 'All') {
    const categories = await this.categoriesService.getAllCategories(genderType);
    return {
      success: true,
      data: categories,
    };
  }

  @Get('with-counts')
  @ApiOperation({ summary: 'Get categories with store counts' })
  @ApiResponse({ status: 200, description: 'Categories with store counts' })
  async getCategoriesWithCounts() {
    const categories = await this.categoriesService.getCategoriesWithCounts();
    return {
      success: true,
      data: categories,
    };
  }

  @Get('admin')
  @ApiOperation({ summary: 'Get all categories (including inactive) - Admin only' })
  @ApiResponse({ status: 200, description: 'List of all categories' })
  async getAllCategoriesAdmin() {
    const categories = await this.categoriesService.getAllCategoriesAdmin();
    return {
      success: true,
      data: categories,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get category by ID' })
  @ApiResponse({ status: 200, description: 'Category details' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async getCategory(@Param('id', ParseIntPipe) id: number) {
    const category = await this.categoriesService.getCategoryById(id);
    return {
      success: true,
      data: category,
    };
  }

  @Post()
  @ApiOperation({ summary: 'Create a new category' })
  @ApiResponse({ status: 201, description: 'Category created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  async createCategory(@Body() categoryData: Partial<Category>) {
    const category = await this.categoriesService.createCategory(categoryData);
    return {
      success: true,
      message: 'تم إنشاء الفئة بنجاح',
      data: category,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update category' })
  @ApiResponse({ status: 200, description: 'Category updated successfully' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async updateCategory(
    @Param('id', ParseIntPipe) id: number,
    @Body() categoryData: Partial<Category>,
  ) {
    const category = await this.categoriesService.updateCategory(id, categoryData);
    return {
      success: true,
      message: 'تم تحديث الفئة بنجاح',
      data: category,
    };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete category' })
  @ApiResponse({ status: 200, description: 'Category deleted successfully' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async deleteCategory(@Param('id', ParseIntPipe) id: number) {
    await this.categoriesService.deleteCategory(id);
    return {
      success: true,
      message: 'تم حذف الفئة بنجاح',
    };
  }
}

