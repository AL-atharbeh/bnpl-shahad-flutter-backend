import { Controller, Get, Param, Query, ParseIntPipe, Post, Body, Put, Delete, UseInterceptors, UploadedFile, Res, BadRequestException } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiQuery, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { memoryStorage } from 'multer';
import { extname, join } from 'path';
import { Response } from 'express';
import { existsSync } from 'fs';
import { put } from '@vercel/blob';

@ApiTags('products')
@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) { }

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
  async uploadProduct(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('File is not provided');
    }

    try {
      const filename = `${Date.now()}-${file.originalname}`;
      const blob = await put(`products/${filename}`, file.buffer, {
        access: 'public',
        addRandomSuffix: true,
      });

      return {
        success: true,
        data: {
          url: blob.url,
          filename: filename
        }
      };
    } catch (error) {
      throw new BadRequestException(`Failed to upload to Vercel Blob: ${error.message}`);
    }
  }

  @Get('uploads/:filename')
  @ApiOperation({ summary: 'Get product image' })
  async getProductImage(@Param('filename') filename: string, @Res() res: Response) {
    const filePath = join(process.cwd(), 'uploads/products', filename);
    if (existsSync(filePath)) {
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

  @Post()
  @ApiOperation({ summary: 'Create new product' })
  async createProduct(@Body() dto: CreateProductDto) {
    const product = await this.productsService.create(dto);
    return {
      success: true,
      data: product,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update product' })
  async updateProduct(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateProductDto,
  ) {
    const product = await this.productsService.update(id, dto);
    return {
      success: true,
      data: product,
    };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete product' })
  async deleteProduct(@Param('id', ParseIntPipe) id: number) {
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

