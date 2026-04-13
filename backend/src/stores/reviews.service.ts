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
    return this.reviewRepository.save(review);
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
    await this.reviewRepository.remove(review);
  }
}
