import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto, UpdateReviewDto } from './dto/create-review.dto';

@ApiTags('reviews')
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new review (Admin only)' })
  async create(@Body() createReviewDto: CreateReviewDto) {
    const review = await this.reviewsService.create(createReviewDto);
    return {
      success: true,
      data: review,
    };
  }

  @Get('store/:storeId')
  @ApiOperation({ summary: 'Get all reviews for a store' })
  async findAllByStore(@Param('storeId', ParseIntPipe) storeId: number) {
    const reviews = await this.reviewsService.findAllByStore(storeId);
    return {
      success: true,
      data: reviews,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a single review' })
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const review = await this.reviewsService.findOne(id);
    return {
      success: true,
      data: review,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a review (Admin only)' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateReviewDto: UpdateReviewDto,
  ) {
    const review = await this.reviewsService.update(id, updateReviewDto);
    return {
      success: true,
      data: review,
    };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a review (Admin only)' })
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.reviewsService.remove(id);
    return {
      success: true,
      message: 'Review deleted successfully',
    };
  }
}
