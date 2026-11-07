import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { unlink } from 'fs/promises';
import { randomInt } from 'crypto';
import * as bcrypt from 'bcrypt';
import { privateDocumentPath, storePrivateDocument } from '../common/upload-storage';
import {
  DOCUMENT_TYPES,
  DocumentType,
  TERMS_VERSION,
  applicationMissing,
  hasBeenApproved,
  normalizeIban,
} from './merchant-application';
import { v4 as uuidv4 } from 'uuid';
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
  private readonly logger = new Logger(StoresService.name);
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
    const stores = await this.storeRepository.find({
      relations: ['categoryRelation'],
      order: { createdAt: 'DESC' },
    });

    // The admin panel shows the old free-text `category`, which stores now
    // leave empty since they pick a category by id. Show the picked one.
    for (const store of stores) {
      if (store.categoryRelation) {
        store.category = store.categoryRelation.nameAr || store.categoryRelation.name;
      }
    }
    return stores;
  }

  async updateStoreStatus(id: number, status: string, note?: string): Promise<Store> {
    if (!['approved', 'rejected', 'pending', 'suspended'].includes(status)) {
      throw new BadRequestException('status must be approved, rejected, pending or suspended');
    }
    const store = await this.storeRepository.findOne({ where: { id } });

    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }
    // Suspending stops a live store; one that never went live is rejected instead.
    if (status === 'suspended' && store.status !== 'approved') {
      throw new BadRequestException('يمكن إيقاف المتاجر المفعّلة فقط');
    }

    store.status = status;
    store.isActive = status === 'approved';
    // The merchant sees why they were turned down or stopped; approval clears it.
    store.reviewNote = ['rejected', 'suspended'].includes(status) ? (note || '').trim() || null : null;
    
    // Generate credentials if they don't exist and store is being approved
    if (status === 'approved' && (!store.apiKey || !store.apiSecret)) {
      const { apiKey, apiSecret } = this.generateApiCredentials();
      store.apiKey = apiKey;
      store.apiSecret = apiSecret;
    }
    
    return this.storeRepository.save(store);
  }

  private generateApiCredentials(): { apiKey: string; apiSecret: string } {
    const apiKey = `sh_pk_${uuidv4().replace(/-/g, '').substring(0, 24)}`;
    const apiSecret = `sh_sk_${uuidv4().replace(/-/g, '')}${uuidv4().replace(/-/g, '')}`;
    return { apiKey, apiSecret };
  }

  /**
   * A store as the public sees it: only once it is live. Its own vendor and
   * admins pass includeInactive to reach it while it is under review,
   * rejected or suspended.
   */
  async getStoreById(id: number, includeInactive = false): Promise<Store> {
    const store = await this.storeRepository.findOne({
      where: includeInactive ? { id } : { id, isActive: true },
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
      bankCommissionRate: createStoreDto.bankCommissionRate ?? null,
      platformCommissionRate: createStoreDto.platformCommissionRate ?? null,
      commissionRate: (createStoreDto.bankCommissionRate !== undefined && createStoreDto.platformCommissionRate !== undefined) 
        ? Number(createStoreDto.bankCommissionRate) + Number(createStoreDto.platformCommissionRate) 
        : null,
      minOrderAmount: createStoreDto.minOrderAmount ?? 50,
      maxOrderAmount: createStoreDto.maxOrderAmount ?? 5000,
      productsCount: 0,
    }) as unknown) as Store;

    // Auto-generate keys for new stores (even if pending, so they can see them)
    const { apiKey, apiSecret } = this.generateApiCredentials();
    store.apiKey = apiKey;
    store.apiSecret = apiSecret;

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

    // Update fields
    Object.assign(store, updateStoreDto);
    if (updateStoreDto.iban !== undefined) {
      const iban = normalizeIban(updateStoreDto.iban);
      if (iban.length > 34) throw new BadRequestException('IBAN أطول من 34 حرفاً');
      store.iban = iban || null;
    }
    if (updateStoreDto.ownerNationalId !== undefined) {
      store.ownerNationalId = updateStoreDto.ownerNationalId.trim() || null;
    }

    // Recalculate total commission rate if ratios changed
    if (updateStoreDto.bankCommissionRate !== undefined || updateStoreDto.platformCommissionRate !== undefined) {
      const bankRate = updateStoreDto.bankCommissionRate !== undefined ? updateStoreDto.bankCommissionRate : store.bankCommissionRate;
      const platformRate = updateStoreDto.platformCommissionRate !== undefined ? updateStoreDto.platformCommissionRate : store.platformCommissionRate;
      
      if (bankRate === null || platformRate === null) {
        store.commissionRate = null;
      } else {
        store.commissionRate = Number(bankRate) + Number(platformRate);
      }
    }

    return this.storeRepository.save(store);
  }

  /** Saves a merchant document privately and records it on the store. */
  async saveDocument(storeId: number, type: DocumentType, file: Express.Multer.File): Promise<Store> {
    const store = await this.getStoreById(storeId, true);
    const column = DOCUMENT_TYPES[type];
    const previous = store[column];

    store[column] = await storePrivateDocument(file);
    const saved = await this.storeRepository.save(store);

    // The replaced file has no other owner; drop it so old IDs do not linger.
    const oldPath = previous && privateDocumentPath(previous);
    if (oldPath) await unlink(oldPath).catch(() => undefined);
    return saved;
  }

  /** Where a store's document is on disk, or 404. */
  async getDocumentPath(storeId: number, type: DocumentType): Promise<string> {
    const store = await this.getStoreById(storeId, true);
    const path = privateDocumentPath(store[DOCUMENT_TYPES[type]]);
    if (!path) throw new NotFoundException('المستند غير موجود');
    return path;
  }

  /**
   * Sends the application to the admins once it is complete and the terms are
   * accepted. A rejected store that fixed its application goes back to
   * pending, so applying again needs no help from support.
   */
  async submitApplication(storeId: number, termsAccepted: boolean): Promise<Store> {
    const store = await this.getStoreById(storeId, true);
    if (hasBeenApproved(store.status)) {
      throw new BadRequestException(
        store.status === 'suspended' ? 'المتجر موقوف من الإدارة' : 'المتجر مفعّل بالفعل',
      );
    }
    const missing = applicationMissing(store);
    if (missing.length) {
      throw new BadRequestException({ message: 'الطلب غير مكتمل', missing });
    }
    if (!termsAccepted) {
      throw new BadRequestException('يجب الموافقة على الشروط والأحكام');
    }

    store.termsAcceptedAt = new Date();
    store.termsVersion = TERMS_VERSION;
    store.applicationSubmittedAt = new Date();
    store.status = 'pending';
    store.reviewNote = null;
    const saved = await this.storeRepository.save(store);

    try {
      const admins = await this.usersService.findAllAdmins();
      for (const admin of admins) {
        await this.notificationsService.sendToUser(
          admin.id,
          'طلب تاجر جاهز للمراجعة',
          `متجر «${store.nameAr || store.name}» أرسل طلبه مكتملاً مع المستندات`,
          { type: 'store_application_submitted', storeId: String(store.id) },
          'urgent',
        );
      }
    } catch (err) {
      this.logger.warn(`Could not notify admins of application ${store.id}: ${err.message}`);
    }
    return saved;
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
  /** Every merchant account with its store's standing, without password hashes. */
  async getAllVendors() {
    const vendors = await this.vendorRepository.find({
      relations: ['store'],
      order: { name: 'ASC' },
    });
    return vendors.map((v) => this.vendorSummary(v));
  }

  async setVendorActive(id: number, isActive: boolean) {
    const vendor = await this.vendorRepository.findOne({ where: { id }, relations: ['store'] });
    if (!vendor) throw new NotFoundException('التاجر غير موجود');
    vendor.isActive = isActive;
    await this.vendorRepository.save(vendor);
    return this.vendorSummary(vendor);
  }

  async resetVendorPassword(id: number) {
    const vendor = await this.vendorRepository.findOne({ where: { id } });
    if (!vendor) throw new NotFoundException('التاجر غير موجود');
    // Unambiguous characters, since the admin reads it out to the merchant.
    const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    const temporaryPassword = Array.from({ length: 12 }, () => alphabet[randomInt(alphabet.length)]).join('');
    vendor.passwordHash = await bcrypt.hash(temporaryPassword, 10);
    await this.vendorRepository.save(vendor);
    return { id: vendor.id, temporaryPassword };
  }

  private vendorSummary(v: Vendor) {
    return {
      id: v.id,
      name: v.name,
      email: v.email,
      phone: v.phone,
      isActive: v.isActive,
      createdAt: v.createdAt,
      storeId: v.storeId,
      store: v.store
        ? {
            id: v.store.id,
            name: v.store.name,
            nameAr: v.store.nameAr,
            status: v.store.status,
            isActive: v.store.isActive,
            applicationSubmittedAt: v.store.applicationSubmittedAt,
          }
        : null,
    };
  }
}

