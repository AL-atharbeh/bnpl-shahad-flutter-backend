import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { Banner, LinkType } from './entities/banner.entity';

@Injectable()
export class BannersService {
  constructor(
    @InjectRepository(Banner)
    private bannerRepository: Repository<Banner>,
  ) {}

  /**
   * Get all active banners (filtered by date and category if provided)
   */
  async getAllBanners(categoryId?: number): Promise<Banner[]> {
    const now = new Date();
    const where: any = {
      isActive: true,
    };

    // Filter by category if provided
    if (categoryId) {
      where.categoryId = categoryId;
    }

    // Order by sort order
    return await this.bannerRepository.find({
      where,
      relations: ['category'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
    });
  }

  /**
   * Get all banners (including inactive) - for admin
   */
  async getAllBannersAdmin(): Promise<Banner[]> {
    return this.bannerRepository.find({
      relations: ['category'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
    });
  }

  /**
   * Get banner by ID
   */
  async getBannerById(id: number): Promise<Banner> {
    const banner = await this.bannerRepository.findOne({
      where: { id },
      relations: ['category'],
    });

    if (!banner) {
      throw new NotFoundException('البانر غير موجود');
    }

    return banner;
  }

  /**
   * Create a new banner
   */
  async createBanner(bannerData: Partial<Banner>): Promise<Banner> {
    // Validate required fields
    if (!bannerData.imageUrl) {
      throw new BadRequestException('رابط الصورة مطلوب');
    }

    // Validate link type and link_id
    if (bannerData.linkType && bannerData.linkType !== LinkType.NONE && !bannerData.linkId) {
      throw new BadRequestException('link_id مطلوب عند تحديد link_type');
    }

    const banner = this.bannerRepository.create(bannerData);
    return this.bannerRepository.save(banner);
  }

  /**
   * Update banner
   */
  async updateBanner(id: number, bannerData: Partial<Banner>): Promise<Banner> {
    const banner = await this.getBannerById(id);

    // Validate link type and link_id
    if (bannerData.linkType && bannerData.linkType !== LinkType.NONE && !bannerData.linkId) {
      throw new BadRequestException('link_id مطلوب عند تحديد link_type');
    }

    Object.assign(banner, bannerData);
    return this.bannerRepository.save(banner);
  }

  /**
   * Delete banner
   */
  async deleteBanner(id: number): Promise<void> {
    const banner = await this.getBannerById(id);
    await this.bannerRepository.remove(banner);
  }

  /**
   * Increment click count for a banner
   */
  async incrementClickCount(id: number): Promise<void> {
    await this.bannerRepository.increment({ id }, 'clickCount', 1);
  }

  /**
   * Get banners by category
   */
  async getBannersByCategory(categoryId: number): Promise<Banner[]> {
    return this.getAllBanners(categoryId);
  }
}

