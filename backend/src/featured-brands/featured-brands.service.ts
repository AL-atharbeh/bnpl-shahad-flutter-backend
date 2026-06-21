import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FeaturedBrand } from './entities/featured-brand.entity';
import { CreateFeaturedBrandDto } from './dto/create-featured-brand.dto';
import { UpdateFeaturedBrandDto } from './dto/update-featured-brand.dto';

@Injectable()
export class FeaturedBrandsService {
  constructor(
    @InjectRepository(FeaturedBrand)
    private readonly featuredBrandRepository: Repository<FeaturedBrand>,
  ) {}

  /**
   * Get all active featured brands
   */
  async findAllActive(): Promise<FeaturedBrand[]> {
    return this.featuredBrandRepository.find({
      where: { isActive: true },
      relations: ['store'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
    });
  }

  /**
   * Get all featured brands for admin dashboard
   */
  async findAllAdmin(): Promise<FeaturedBrand[]> {
    return this.featuredBrandRepository.find({
      relations: ['store'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
    });
  }

  /**
   * Get one featured brand by ID
   */
  async findOne(id: number): Promise<FeaturedBrand> {
    const brand = await this.featuredBrandRepository.findOne({
      where: { id },
      relations: ['store'],
    });

    if (!brand) {
      throw new NotFoundException(`Featured brand with ID ${id} not found`);
    }

    return brand;
  }

  /**
   * Create a new featured brand
   */
  async create(createDto: CreateFeaturedBrandDto): Promise<FeaturedBrand> {
    const brand = this.featuredBrandRepository.create(createDto);
    return this.featuredBrandRepository.save(brand);
  }

  /**
   * Update a featured brand
   */
  async update(id: number, updateDto: UpdateFeaturedBrandDto): Promise<FeaturedBrand> {
    const brand = await this.findOne(id);
    Object.assign(brand, updateDto);
    return this.featuredBrandRepository.save(brand);
  }

  /**
   * Delete a featured brand
   */
  async delete(id: number): Promise<void> {
    const brand = await this.findOne(id);
    await this.featuredBrandRepository.remove(brand);
  }
}
