import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, In, LessThanOrEqual, MoreThanOrEqual, IsNull } from 'typeorm';
import { Store } from './entities/store.entity';
import { Deal } from '../deals/entities/deal.entity';
import { Vendor } from '../vendors/entities/vendor.entity';
import { NotificationsService } from '../notifications/notifications.service';
import { UsersService } from '../users/users.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';

@Injectable()
export class StoresService {
  constructor(
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
    @InjectRepository(Deal)
    private dealRepository: Repository<Deal>,
    @InjectRepository(Vendor)
    private vendorRepository: Repository<Vendor>,
    private notificationsService: NotificationsService,
    private usersService: UsersService,
  ) { }

  async getAllStores(categoryId?: number, topStore?: boolean, genderCategoryId?: number): Promise<Store[]> {
    const where: any = { isActive: true };

    if (categoryId) {
      where.categoryId = categoryId;
    }

    // If topStore is true, only return stores with top_store = 1
    if (topStore === true) {
      where.topStore = true;
    }

    // Filter by gender category (Women, Men, Kids)
    if (genderCategoryId) {
      where.genderCategoryId = genderCategoryId;
    }

    return this.storeRepository.find({
      where,
      // relations: ['categoryRelation'], // Temporarily disabled - causing API to hang
      order: { rating: 'DESC' },
    });
  }

  async getAllAdminStores(): Promise<Store[]> {
    return this.storeRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async updateStoreStatus(id: number, status: string): Promise<Store> {
    const store = await this.storeRepository.findOne({ where: { id } });

    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }

    store.status = status;
    store.isActive = status === 'approved';
    
    return this.storeRepository.save(store);
  }

  async getStoreById(id: number): Promise<Store> {
    const store = await this.storeRepository.findOne({
      where: { id, isActive: true },
      relations: ['categoryRelation', 'products'],
    });

    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }

    return store;
  }

  async getStoresWithDeals(categoryId?: number): Promise<Store[]> {
    const where: any = { isActive: true, hasDeal: true };

    if (categoryId) {
      where.categoryId = categoryId;
    }

    const stores = await this.storeRepository.find({
      where,
      relations: ['categoryRelation'],
      order: { rating: 'DESC' },
    });

    if (!stores.length) {
      return [];
    }

    const storeIds = stores.map((store) => store.id);
    const now = new Date();

    const activeDeals = await this.dealRepository.find({
      where: [
        {
          storeId: In(storeIds),
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: MoreThanOrEqual(now),
        },
        {
          storeId: In(storeIds),
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: IsNull(),
        },
        {
          storeId: In(storeIds),
          isActive: true,
          startDate: IsNull(),
          endDate: MoreThanOrEqual(now),
        },
        {
          storeId: In(storeIds),
          isActive: true,
          startDate: IsNull(),
          endDate: IsNull(),
        },
      ],
      relations: ['product'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
    });

    const dealsByStore = new Map<number, Deal[]>();
    for (const deal of activeDeals) {
      const list = dealsByStore.get(deal.storeId) ?? [];
      list.push(deal);
      dealsByStore.set(deal.storeId, list);
    }

    return stores
      .map((store) => {
        store.deals = dealsByStore.get(store.id) ?? [];
        return store;
      })
      .filter((store) => store.deals.length > 0);
  }

  async searchStores(query: string, categoryId?: number): Promise<Store[]> {
    const whereConditions: any[] = [
      { name: Like(`%${query}%`), isActive: true },
      { nameAr: Like(`%${query}%`), isActive: true },
      { description: Like(`%${query}%`), isActive: true },
      { descriptionAr: Like(`%${query}%`), isActive: true },
    ];

    if (categoryId) {
      whereConditions.forEach(condition => {
        condition.categoryId = categoryId;
      });
    }

    return this.storeRepository.find({
      where: whereConditions,
      relations: ['categoryRelation'],
    });
  }

  /**
   * Get stores by category
   */
  async getStoresByCategory(categoryId: number): Promise<Store[]> {
    return this.storeRepository.find({
      where: { categoryId, isActive: true },
      relations: ['categoryRelation'],
      order: { rating: 'DESC' },
    });
  }

  /**
   * Toggle top store status
   */
  async toggleTopStore(id: number): Promise<Store> {
    const store = await this.storeRepository.findOne({ where: { id } });

    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }

    store.topStore = !store.topStore;
    return this.storeRepository.save(store);
  }

  /**
   * Create a new store (default status: pending)
   */
  async createStore(createStoreDto: any): Promise<Store> {
    const store = (this.storeRepository.create({
      ...createStoreDto,
      isActive: false, // New stores are inactive until approved
      status: 'pending', // New stores are pending until approved
      topStore: createStoreDto.topStore ?? false,
      rating: createStoreDto.rating ?? 0,
      commissionRate: createStoreDto.commissionRate ?? 2.5,
      minOrderAmount: createStoreDto.minOrderAmount ?? 50,
      maxOrderAmount: createStoreDto.maxOrderAmount ?? 5000,
      productsCount: 0,
    }) as unknown) as Store;

    const savedStore = await this.storeRepository.save(store);

    // Notify Admins
    const admins = await this.usersService.findAllAdmins();
    const notificationTitle = 'طلب إضافة متجر جديد';
    const notificationBody = `قام المورد بطلب إضافة متجر جديد باسم: ${store.nameAr || store.name}`;
    const notificationData = {
      type: 'new_store_request',
      storeId: savedStore.id.toString(),
      storeName: savedStore.name,
    };

    for (const admin of admins) {
      await this.notificationsService.sendToUser(admin.id, notificationTitle, notificationBody, notificationData, 'urgent');
    }

    return savedStore;
  }

  /**
   * Update store details
   */
  async updateStore(id: number, updateStoreDto: UpdateStoreDto): Promise<Store> {
    const store = await this.storeRepository.findOne({ where: { id } });
    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }
    const updatedStore = Object.assign(store, updateStoreDto);
    return this.storeRepository.save(updatedStore);
  }

  /**
   * Delete a store
   */
  async deleteStore(id: number): Promise<void> {
    const store = await this.storeRepository.findOne({ where: { id } });
    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }
    await this.storeRepository.remove(store);
  }

  /**
   * Get all vendors for admin dropdown
   */
  async getAllVendors(): Promise<Vendor[]> {
    return this.vendorRepository.find({
      order: { name: 'ASC' },
    });
  }
}

