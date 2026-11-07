import { Controller, Get, Param, Query, ParseIntPipe, Post, Body, Put, Delete, UseInterceptors, UploadedFile, Res, Req, BadRequestException, UseGuards } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiQuery, ApiConsumes, ApiBody, ApiBearerAuth } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { memoryStorage } from 'multer';
import { Response } from 'express';
import { storeUpload, uploadedFilePath } from '../common/upload-storage';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { assertStoreAccess } from '../auth/store-access';

@ApiTags('products')
@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) { }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @Post('upload')
  @ApiOperation({ summary: 'Upload product image' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @UseInterceptors(FileInterceptor('file', {
    storage: memoryStorage(),
    fileFilter: (req, file, cb) => {
      if (!file.mimetype.match(/\/(jpg|jpeg|png|gif)$/)) {
        return cb(new BadRequestException('Only image files are allowed!'), false);
      }
      cb(null, true);
    },
  }))
  async uploadProduct(@UploadedFile() file: Express.Multer.File, @Req() req: any) {
    if (!file) {
      throw new BadRequestException('File is not provided');
    }

    try {
      return { success: true, data: await storeUpload('products', file) };
    } catch (error) {
      throw new BadRequestException(`Failed to upload image: ${error.message}`);
    }
  }

  @Get('uploads/:filename')
  @ApiOperation({ summary: 'Get product image' })
  async getProductImage(@Param('filename') filename: string, @Res() res: Response) {
    const filePath = uploadedFilePath('products', filename);
    if (filePath) {
      res.sendFile(filePath);
    } else {
      res.status(404).json({
        success: false,
        message: 'Image not found',
      });
    }
  }

  @Get()
  @ApiOperation({ summary: 'Get all products' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async getAllProducts(@Query('categoryId') categoryId?: number) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const products = await this.productsService.getAllProducts(categoryIdNum);
    return {
      success: true,
      data: products,
    };
  }

  @Get('store/:storeId')
  @ApiOperation({ summary: 'Get products by store' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async getProductsByStore(
    @Param('storeId', ParseIntPipe) storeId: number,
    @Query('categoryId') categoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const products = await this.productsService.getProductsByStore(storeId, categoryIdNum);
    return {
      success: true,
      data: products,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @Post()
  @ApiOperation({ summary: 'Create new product' })
  async createProduct(@Body() dto: CreateProductDto, @Req() req: any) {
    assertStoreAccess(req.user, dto.store_id);
    if (req.user.role === 'vendor') await this.productsService.assertStoreLive(dto.store_id);
    const product = await this.productsService.create(dto);
    return {
      success: true,
      data: product,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @Put(':id')
  @ApiOperation({ summary: 'Update product' })
  async updateProduct(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateProductDto,
    @Req() req: any,
  ) {
    // The product must be the vendor's now, and stay theirs after the edit.
    const storeId = await this.productsService.getProductStoreId(id);
    assertStoreAccess(req.user, storeId);
    if (dto.store_id !== undefined) assertStoreAccess(req.user, dto.store_id);
    if (req.user.role === 'vendor') await this.productsService.assertStoreLive(storeId);
    const product = await this.productsService.update(id, dto);
    return {
      success: true,
      data: product,
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin', 'vendor')
  @ApiBearerAuth()
  @Delete(':id')
  @ApiOperation({ summary: 'Delete product' })
  async deleteProduct(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const storeId = await this.productsService.getProductStoreId(id);
    assertStoreAccess(req.user, storeId);
    if (req.user.role === 'vendor') await this.productsService.assertStoreLive(storeId);
    await this.productsService.remove(id);
    return {
      success: true,
      data: true,
    };
  }

  @Get('search')
  @ApiOperation({ summary: 'Search products' })
  @ApiQuery({ name: 'q', required: true, description: 'Search query' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID' })
  async searchProducts(
    @Query('q') query: string,
    @Query('categoryId') categoryId?: number,
  ) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const products = await this.productsService.searchProducts(query, categoryIdNum);
    return {
      success: true,
      data: products,
    };
  }

  @Get('category/:categoryId')
  @ApiOperation({ summary: 'Get products by category' })
  async getProductsByCategory(@Param('categoryId', ParseIntPipe) categoryId: number) {
    const products = await this.productsService.getProductsByCategory(categoryId);
    return {
      success: true,
      data: products,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get product by ID' })
  async getProduct(@Param('id') id: number) {
    const product = await this.productsService.getProductById(id);
    return {
      success: true,
      data: product,
    };
  }
}

