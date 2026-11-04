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
  UseInterceptors,
  UploadedFile,
  Res,
  Req,
  BadRequestException,
  UseGuards,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiQuery, ApiResponse, ApiConsumes, ApiBody, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { memoryStorage } from 'multer';
import { Response } from 'express';
import { BannersService } from './banners.service';
import { Banner } from './entities/banner.entity';
import { storeUpload, uploadedFilePath } from '../common/upload-storage';

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

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
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

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
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

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
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

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
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
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @ApiBearerAuth()
  @Post('upload')
  @ApiOperation({ summary: 'Upload banner image' })
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
      // Relaxed check to include common image formats case-insensitively
      if (!file.mimetype.match(/\/(jpg|jpeg|png|gif|webp|heic)$/i)) {
        return cb(new BadRequestException('Invalid file type. Only JPG, PNG, GIF, and WEBP are allowed.'), false);
      }
      cb(null, true);
    },
    limits: {
      fileSize: 20 * 1024 * 1024, // 20MB limit
    },
  }))
  async uploadBanner(@UploadedFile() file: Express.Multer.File, @Req() req: any) {
    if (!file) {
      throw new BadRequestException('File is not provided');
    }

    try {
      return { success: true, data: await storeUpload('banners', file) };
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }
      // Handle Multer size limit error specifically
      if (error.code === 'LIMIT_FILE_SIZE') {
        throw new BadRequestException('حجم الملف كبير جداً. الحد الأقصى هو 20 ميجابايت.');
      }
      throw new BadRequestException(`فشل في رفع الصورة: ${error.message}`);
    }
  }


  @Get('uploads/:filename')
  @ApiOperation({ summary: 'Get banner image' })
  async getBannerImage(@Param('filename') filename: string, @Res() res: Response) {
    const filePath = uploadedFilePath('banners', filename);
    if (filePath) {
      res.sendFile(filePath);
    } else {
      res.status(404).json({
        success: false,
        message: 'Image not found',
      });
    }
  }
}

