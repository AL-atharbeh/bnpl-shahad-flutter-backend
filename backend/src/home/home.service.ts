import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, LessThanOrEqual, MoreThanOrEqual, Repository } from 'typeorm';
import { Store } from '../stores/entities/store.entity';
import { Product } from '../products/entities/product.entity';
import { Payment } from '../payments/entities/payment.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { Deal } from '../deals/entities/deal.entity';
import { Banner } from '../banners/entities/banner.entity';

@Injectable()
export class HomeService {
  constructor(
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    @InjectRepository(Deal)
    private dealRepository: Repository<Deal>,
    @InjectRepository(Banner)
    private bannerRepository: Repository<Banner>,
  ) {}

  /**
   * Get all home page data
   * Combines: stores, offers, featured stores, pending payments, notifications
   */
  async getHomeData(userId?: number) {
    // Get all active stores (top stores)
    const topStores = await this.storeRepository.find({
      where: { isActive: true },
      order: { rating: 'DESC' },
      take: 8,
    });

    // Get stores with active deals (best offers)
    const bestDeals = await this.dealRepository.find({
      where: [
        {
          isActive: true,
          startDate: LessThanOrEqual(new Date()),
          endDate: MoreThanOrEqual(new Date()),
        },
        {
          isActive: true,
          startDate: LessThanOrEqual(new Date()),
          endDate: IsNull(),
        },
        {
          isActive: true,
          startDate: IsNull(),
          endDate: MoreThanOrEqual(new Date()),
        },
        {
          isActive: true,
          startDate: IsNull(),
          endDate: IsNull(),
        },
      ],
      relations: ['store', 'product'],
      order: { sortOrder: 'ASC', createdAt: 'DESC' },
      take: 6,
    });

    // Get featured stores (high rating + has deal)
    const featuredStores = await this.storeRepository.find({
      where: { hasDeal: true, isActive: true },
      order: { rating: 'DESC' },
      take: 4,
    });

    // Get pending payments for user (if userId provided)
    let pendingPayments = [];
    if (userId) {
      pendingPayments = await this.paymentRepository.find({
        where: {
          userId,
          status: 'pending',
        },
        relations: ['store'],
        order: { dueDate: 'ASC' },
        take: 3, // Limit to 3 payments to match database
      });
      console.log(`[HomeService] Found ${pendingPayments.length} pending payments for user ${userId}`);
      pendingPayments.forEach((p, i) => {
        console.log(`  Payment ${i + 1}: ID=${p.id}, Amount=${p.amount}, Store=${p.store?.name || 'No store'}, DueDate=${p.dueDate}`);
      });
    }

    // Get unread notifications for user (if userId provided)
    let unreadNotifications = [];
    if (userId) {
      unreadNotifications = await this.notificationRepository.find({
        where: {
          userId,
          isRead: false,
        },
        order: { createdAt: 'DESC' },
        take: 5,
      });
    }

    // Categories (static for now, can be moved to database later)
    const categories = [
      {
        id: 1,
        name: 'الإلكترونيات',
        nameEn: 'Electronics',
        icon: 'devices',
        image: '/images/categories/electronics.jpg',
        color: '#10B981',
      },
      {
        id: 2,
        name: 'الملابس',
        nameEn: 'Fashion',
        icon: 'style',
        image: '/images/categories/fashion.jpg',
        color: '#34D399',
      },
      {
        id: 3,
        name: 'الرياضة',
        nameEn: 'Sports',
        icon: 'sports_soccer',
        image: '/images/categories/sports.jpg',
        color: '#6EE7B7',
      },
      {
        id: 4,
        name: 'الكتب',
        nameEn: 'Books',
        icon: 'book',
        image: '/images/categories/books.jpg',
        color: '#059669',
      },
    ];

    // Banner images (static for now)
    // Get active banners from database
    const dbBanners = await this.bannerRepository.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC' },
    });

    const banners = dbBanners.map(b => ({
      id: b.id,
      image: b.imageUrl,
      title: b.title,
      titleEn: b.title || '',
      link: b.linkUrl || '',
      linkType: b.linkType,
      linkId: b.linkId,
    }));

    return {
      banners,
      categories,
      topStores: topStores.map((store) => this.formatStore(store)),
      bestOffers: bestDeals.map((deal) => this.formatDealOffer(deal)),
      featuredStores: featuredStores.map((store) => this.formatStore(store)),
      pendingPayments: pendingPayments.map((payment) => {
        const formatted = this.formatPayment(payment);
        console.log(`[HomeService] Formatted payment ID=${formatted.id}: amount=${formatted.amount}, title=${formatted.title}, daysUntilDue=${formatted.daysUntilDue}`);
        return formatted;
      }),
      unreadNotifications: unreadNotifications.map((notification) =>
        this.formatNotification(notification),
      ),
      stats: {
        totalStores: await this.storeRepository.count({
          where: { isActive: true },
        }),
        totalOffers: await this.storeRepository.count({
          where: { hasDeal: true, isActive: true },
        }),
        pendingPaymentsCount: userId
          ? await this.paymentRepository.count({
              where: { userId, status: 'pending' },
            })
          : 0,
        unreadNotificationsCount: userId
          ? await this.notificationRepository.count({
              where: { userId, isRead: false },
            })
          : 0,
      },
    };
  }

  /**
   * Format store for home page
   */
  private formatStore(store: Store) {
    return {
      id: store.id,
      name: store.name,
      nameAr: store.nameAr || store.name,
      logo: store.logoUrl,
      image: store.logoUrl,
      category: store.category,
      categoryAr: store.category || '',
      rating: store.rating || 0,
      productsCount: store.productsCount || 0,
      color: '#10B981', // Default color
      icon: 'store', // Default icon
    };
  }

  /**
   * Format store as offer
   */
  private formatStoreOffer(store: Store) {
    return {
      id: store.id,
      storeName: store.name,
      storeNameAr: store.nameAr || store.name,
      description: store.dealDescription || '',
      descriptionAr: store.dealDescription || '',
      discount: store.dealDescription || '10%',
      image: store.logoUrl,
      logo: store.logoUrl,
      badgeColor: '#D1FAE5',
      storeColor: '#10B981',
    };
  }

  private formatDealOffer(deal: Deal) {
    const store = deal.store;
    const product = deal.product;
    const parsePrice = (value: any): number | null => {
      if (value === null || value === undefined) return null;
      if (typeof value === 'number') return value;
      const parsed = parseFloat(value);
      return Number.isNaN(parsed) ? null : parsed;
    };

    const productImages =
      Array.isArray(product?.images) && product?.images?.length
        ? product.images.filter((img) => !!img)
        : [];

    const primaryImage =
      deal.imageUrl ||
      product?.imageUrl ||
      productImages[0] ||
      store?.logoUrl ||
      '';

    return {
      id: store?.id ?? deal.storeId,
      storeId: store?.id ?? deal.storeId,
      productId: product?.id ?? deal.productId,
      storeName: store?.name ?? '',
      storeNameAr: store?.nameAr ?? store?.name ?? '',
      description: deal.title || deal.description || product?.description || '',
      descriptionAr:
        deal.titleAr ||
        deal.descriptionAr ||
        product?.descriptionAr ||
        deal.title ||
        '',
      discount: deal.discountLabel || deal.discountValue || '',
      discountLabel: deal.discountLabel || '',
      discountValue: deal.discountValue || '',
      image: primaryImage,
      productImage: primaryImage,
      productImages,
      logo: store?.logoUrl || product?.imageUrl || '',
      badgeColor: deal.badgeColor || '#D1FAE5',
      storeColor: deal.accentColor || '#10B981',
      productName: product?.name || '',
      productNameAr: product?.nameAr || product?.name || '',
      productPrice: parsePrice(product?.price),
      currency: product?.currency || 'JOD',
      storeUrl: store?.storeUrl || store?.websiteUrl || '',
    };
  }

  /**
   * Format payment for home page
   */
  private formatPayment(payment: Payment) {
    const store = payment.store;
    // Use postponedDueDate if payment is postponed, otherwise use original dueDate
    const effectiveDueDate = payment.isPostponed && payment.postponedDueDate 
      ? new Date(payment.postponedDueDate)
      : new Date(payment.dueDate);
    const now = new Date();
    const daysLeft = Math.ceil(
      (effectiveDueDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24),
    );

    // Convert amount to number if it's a string or Decimal
    let amountValue: number;
    if (typeof payment.amount === 'number') {
      amountValue = payment.amount;
    } else if (typeof payment.amount === 'string') {
      amountValue = parseFloat(payment.amount);
    } else {
      // Handle Decimal type or other types
      amountValue = parseFloat(String(payment.amount));
    }

    // Ensure amountValue is a proper number (not string)
    const finalAmount = typeof amountValue === 'number' ? amountValue : parseFloat(String(amountValue)) || 0;

    return {
      id: payment.id,
      title: store?.name || 'Unknown Store',
      titleEn: store?.name || 'Unknown Store',
      amount: finalAmount, // Return as number, not formatted string
      amountEn: finalAmount, // Return as number, not formatted string
      amountFormatted: `${payment.currency} ${finalAmount.toFixed(2)}`, // Formatted version
      amountFormattedEn: `${payment.currency} ${finalAmount.toFixed(2)}`, // Formatted version
      dueDate: daysLeft > 0 ? `${daysLeft} أيام` : 'مستحق الآن',
      dueDateEn: daysLeft > 0 ? `${daysLeft} days` : 'Due Now',
      daysLeft: daysLeft > 0 ? `${daysLeft} أيام` : '0 أيام',
      daysLeftEn: daysLeft > 0 ? `${daysLeft} days` : '0 days',
      daysUntilDue: daysLeft, // Add numeric value for easier calculation
      status: payment.status,
      color: '#10B981',
      icon: 'store',
      store: store ? {
        id: store.id,
        name: store.name,
        nameAr: store.nameAr,
      } : null,
    };
  }

  /**
   * Format notification for home page
   */
  private formatNotification(notification: Notification) {
    return {
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
    };
  }
}

