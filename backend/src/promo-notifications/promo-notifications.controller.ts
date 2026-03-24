import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { PromoNotificationsService } from './promo-notifications.service';
import { CreatePromoNotificationDto } from './dto/create-promo-notification.dto';
import { UpdatePromoNotificationDto } from './dto/update-promo-notification.dto';

@ApiTags('promo-notifications')
@Controller('promo-notifications')
export class PromoNotificationsController {
  constructor(
    private readonly promoNotificationsService: PromoNotificationsService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new promo notification' })
  async create(@Body() createDto: CreatePromoNotificationDto) {
    const notification = await this.promoNotificationsService.create(createDto);
    return {
      success: true,
      data: notification,
    };
  }

  @Get()
  @ApiOperation({ summary: 'Get all active promo notifications' })
  @ApiQuery({ name: 'categoryId', required: false, type: Number, description: 'Filter by category ID - shows notifications for this category AND global notifications' })
  async findAll(@Query('categoryId') categoryId?: number) {
    const categoryIdNum = categoryId ? parseInt(categoryId.toString()) : undefined;
    const notifications = await this.promoNotificationsService.findAll(categoryIdNum);
    return {
      success: true,
      data: notifications,
    };
  }

  @Get('admin')
  @ApiOperation({ summary: 'Get all promo notifications (admin)' })
  async findAllForAdmin() {
    const notifications = await this.promoNotificationsService.findAllForAdmin();
    return {
      success: true,
      data: notifications,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get promo notification by ID' })
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const notification = await this.promoNotificationsService.findOne(id);
    return {
      success: true,
      data: notification,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update promo notification' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdatePromoNotificationDto,
  ) {
    const notification = await this.promoNotificationsService.update(id, updateDto);
    return {
      success: true,
      data: notification,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete promo notification' })
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.promoNotificationsService.remove(id);
    return {
      success: true,
      message: 'تم حذف الإشعار بنجاح',
    };
  }

  @Post(':id/click')
  @ApiOperation({ summary: 'Increment click count for promo notification' })
  async incrementClick(@Param('id', ParseIntPipe) id: number) {
    const notification = await this.promoNotificationsService.incrementClick(id);
    return {
      success: true,
      data: notification,
    };
  }
}

