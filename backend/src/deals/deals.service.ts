import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, LessThanOrEqual, MoreThanOrEqual, Repository } from 'typeorm';
import { Deal } from './entities/deal.entity';
import { CreateDealDto } from './dto/create-deal.dto';
import { UpdateDealDto } from './dto/update-deal.dto';

@Injectable()
export class DealsService {
  constructor(
    @InjectRepository(Deal)
    private readonly dealRepository: Repository<Deal>,
  ) {}

  async create(createDealDto: CreateDealDto): Promise<Deal> {
    const deal = this.dealRepository.create(createDealDto);
    return this.dealRepository.save(deal);
  }

  async findAll(params?: {
    isActive?: boolean;
    storeId?: number;
    productId?: number;
    includeExpired?: boolean;
  }): Promise<Deal[]> {
    const { isActive, storeId, productId, includeExpired } = params || {};
    const now = new Date();

    const where: any = {};
    if (typeof isActive === 'boolean') {
      where.isActive = isActive;
    }
    if (storeId) {
      where.storeId = storeId;
    }
    if (productId) {
      where.productId = productId;
    }

    if (!includeExpired) {
      where.startDate = LessThanOrEqual(now);
      where.endDate = MoreThanOrEqual(now);
    }

    return this.dealRepository.find({
      where,
      relations: ['store', 'product'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
    });
  }

  async findActiveForHome(limit = 6): Promise<Deal[]> {
    const now = new Date();
    return this.dealRepository.find({
      where: [
        {
          isActive: true,
          showInHome: true,
          startDate: LessThanOrEqual(now),
          endDate: MoreThanOrEqual(now),
        },
        {
          isActive: true,
          showInHome: true,
          startDate: LessThanOrEqual(now),
          endDate: IsNull(),
        },
        {
          isActive: true,
          showInHome: true,
          startDate: IsNull(),
          endDate: MoreThanOrEqual(now),
        },
        {
          isActive: true,
          showInHome: true,
          startDate: IsNull(),
          endDate: IsNull(),
        },
      ],
      relations: ['store', 'product'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
      take: limit,
    });
  }

  async findOne(id: number): Promise<Deal> {
    const deal = await this.dealRepository.findOne({
      where: { id },
      relations: ['store', 'product'],
    });
    if (!deal) {
      throw new NotFoundException('العرض غير موجود');
    }
    return deal;
  }

  async update(id: number, updateDealDto: UpdateDealDto): Promise<Deal> {
    const deal = await this.findOne(id);
    Object.assign(deal, updateDealDto);
    return this.dealRepository.save(deal);
  }

  async remove(id: number): Promise<void> {
    const result = await this.dealRepository.delete(id);
    if (!result.affected) {
      throw new NotFoundException('العرض غير موجود');
    }
  }
}
