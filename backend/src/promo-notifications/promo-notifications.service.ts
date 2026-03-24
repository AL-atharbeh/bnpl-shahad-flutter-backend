import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PromoNotification } from './entities/promo-notification.entity';
import { CreatePromoNotificationDto } from './dto/create-promo-notification.dto';
import { UpdatePromoNotificationDto } from './dto/update-promo-notification.dto';

@Injectable()
export class PromoNotificationsService {
  constructor(
    @InjectRepository(PromoNotification)
    private promoNotificationRepository: Repository<PromoNotification>,
  ) {}

  async create(createDto: CreatePromoNotificationDto): Promise<PromoNotification> {
    const notification = this.promoNotificationRepository.create({
      ...createDto,
      startDate: createDto.startDate ? new Date(createDto.startDate) : null,
      endDate: createDto.endDate ? new Date(createDto.endDate) : null,
    });
    return this.promoNotificationRepository.save(notification);
  }

  async findAll(categoryId?: number): Promise<PromoNotification[]> {
    // If categoryId is provided, show notifications for that category AND global notifications (category_id = NULL)
    // If categoryId is not provided (home page), show only global notifications (category_id = NULL)

    if (categoryId) {
      // Show notifications for this category OR global notifications
      return this.promoNotificationRepository
        .createQueryBuilder('notification')
        .where('notification.isActive = :isActive', { isActive: true })
        .andWhere('(notification.categoryId = :categoryId OR notification.categoryId IS NULL)', { categoryId })
        .leftJoinAndSelect('notification.category', 'category')
        .orderBy('notification.sortOrder', 'ASC')
        .addOrderBy('notification.id', 'ASC')
        .getMany();
    } else {
      // Show only global notifications (category_id = NULL)
      return this.promoNotificationRepository
        .createQueryBuilder('notification')
        .where('notification.isActive = :isActive', { isActive: true })
        .andWhere('notification.categoryId IS NULL')
        .leftJoinAndSelect('notification.category', 'category')
        .orderBy('notification.sortOrder', 'ASC')
        .addOrderBy('notification.id', 'ASC')
        .getMany();
    }
  }

  async findAllForAdmin(): Promise<PromoNotification[]> {
    return this.promoNotificationRepository.find({
      relations: ['category'],
      order: { sortOrder: 'ASC', id: 'ASC' },
    });
  }

  async findOne(id: number): Promise<PromoNotification> {
    const notification = await this.promoNotificationRepository.findOne({
      where: { id },
      relations: ['category'],
    });

    if (!notification) {
      throw new NotFoundException('الإشعار غير موجود');
    }

    return notification;
  }

  async update(id: number, updateDto: UpdatePromoNotificationDto): Promise<PromoNotification> {
    const notification = await this.findOne(id);

    if (updateDto.startDate) {
      updateDto.startDate = new Date(updateDto.startDate).toISOString();
    }
    if (updateDto.endDate) {
      updateDto.endDate = new Date(updateDto.endDate).toISOString();
    }

    Object.assign(notification, {
      ...updateDto,
      startDate: updateDto.startDate ? new Date(updateDto.startDate) : notification.startDate,
      endDate: updateDto.endDate ? new Date(updateDto.endDate) : notification.endDate,
    });

    return this.promoNotificationRepository.save(notification);
  }

  async remove(id: number): Promise<void> {
    const notification = await this.findOne(id);
    await this.promoNotificationRepository.remove(notification);
  }

  async incrementClick(id: number): Promise<PromoNotification> {
    const notification = await this.findOne(id);
    notification.clickCount += 1;
    return this.promoNotificationRepository.save(notification);
  }
}

