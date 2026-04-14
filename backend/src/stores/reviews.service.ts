import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review } from './entities/review.entity';
import { CreateReviewDto, UpdateReviewDto } from './dto/create-review.dto';
import { Store } from './entities/store.entity';

@Injectable()
export class ReviewsService {
  constructor(
    @InjectRepository(Review)
    private reviewRepository: Repository<Review>,
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
  ) {}

  async create(createReviewDto: CreateReviewDto): Promise<Review> {
    const store = await this.storeRepository.findOne({
      where: { id: createReviewDto.storeId },
    });

    if (!store) {
      throw new NotFoundException('Store not found');
    }

    const review = this.reviewRepository.create(createReviewDto);
    const savedReview = await this.reviewRepository.save(review);
    
    // Update store overall rating
    await this.updateStoreRating(createReviewDto.storeId);
    
    return savedReview;
  }

  async findAllByStore(storeId: number): Promise<Review[]> {
    return this.reviewRepository.find({
      where: { storeId },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Review> {
    const review = await this.reviewRepository.findOne({ where: { id } });
    if (!review) {
      throw new NotFoundException('Review not found');
    }
    return review;
  }

  async update(id: number, updateReviewDto: UpdateReviewDto): Promise<Review> {
    const review = await this.findOne(id);
    const updated = Object.assign(review, updateReviewDto);
    return this.reviewRepository.save(updated);
  }

  async remove(id: number): Promise<void> {
    const review = await this.findOne(id);
    const storeId = review.storeId;
    await this.reviewRepository.remove(review);
    
    // Update store overall rating
    await this.updateStoreRating(storeId);
  }

  private async updateStoreRating(storeId: number): Promise<void> {
    const reviews = await this.reviewRepository.find({
      where: { storeId },
    });

    if (reviews.length === 0) {
      await this.storeRepository.update(storeId, { rating: 0 });
      return;
    }

    const totalRating = reviews.reduce((sum, review) => sum + Number(review.rating), 0);
    const averageRating = totalRating / reviews.length;

    await this.storeRepository.update(storeId, { 
      rating: Number(averageRating.toFixed(1)) 
    });
  }
}
