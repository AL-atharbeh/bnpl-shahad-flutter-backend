import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Product } from '../../products/entities/product.entity';
import { Payment } from '../../payments/entities/payment.entity';
import { Category } from '../../categories/entities/category.entity';
import { Deal } from '../../deals/entities/deal.entity';
import { Vendor } from '../../vendors/entities/vendor.entity';
import { Review } from './review.entity';

@Entity('stores')
export class Store {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255 })
  name: string;

  @Column({ name: 'name_ar', length: 255, nullable: true })
  nameAr: string;

  @Column({ name: 'logo_url', type: 'text', nullable: true })
  logoUrl: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'description_ar', type: 'text', nullable: true })
  descriptionAr: string;

  @Column({ length: 100, nullable: true })
  category: string; // Keep for backward compatibility

  @Column({ name: 'category_id', nullable: true })
  categoryId: number;

  @Column({ name: 'gender_category_id', nullable: true })
  genderCategoryId: number;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  rating: number;

  @Column({ name: 'has_deal', default: false })
  hasDeal: boolean;

  @Column({ name: 'deal_description', type: 'text', nullable: true })
  dealDescription: string;

  @Column({ name: 'deal_description_ar', type: 'text', nullable: true })
  dealDescriptionAr: string;

  @Column({ name: 'commission_rate', type: 'decimal', precision: 5, scale: 2, nullable: true })
  commissionRate: number;

  @Column({ name: 'bank_commission_rate', type: 'decimal', precision: 5, scale: 2, nullable: true })
  bankCommissionRate: number;

  @Column({ name: 'platform_commission_rate', type: 'decimal', precision: 5, scale: 2, nullable: true })
  platformCommissionRate: number;

  @Column({ name: 'min_order_amount', type: 'decimal', precision: 10, scale: 2, default: 50 })
  minOrderAmount: number;

  @Column({ name: 'max_order_amount', type: 'decimal', precision: 10, scale: 2, default: 5000 })
  maxOrderAmount: number;

  @Column({ name: 'website_url', type: 'text', nullable: true })
  websiteUrl: string;

  @Column({ name: 'store_url', type: 'text', nullable: true })
  storeUrl: string;

  @Column({ name: 'supported_countries', type: 'json', nullable: true })
  supportedCountries: string[];

  @Column({ name: 'supported_currencies', type: 'json', nullable: true })
  supportedCurrencies: string[];

  @Column({ name: 'is_active', default: false })
  isActive: boolean;

  @Column({ name: 'top_store', type: 'boolean', default: false })
  topStore: boolean;

  @Column({ name: 'products_count', default: 0 })
  productsCount: number;

  @Column({ name: 'vendor_id', nullable: true })
  vendorId: number;

  @Column({ length: 20, default: 'pending' })
  status: string; // 'pending' | 'approved' | 'rejected'

  @Index()
  @Column({ name: 'api_key', length: 100, nullable: true, unique: true })
  apiKey: string;

  @Column({ name: 'api_secret', length: 255, nullable: true })
  apiSecret: string;

  @Column({ name: 'contact_person', length: 255, nullable: true })
  contactPerson: string;

  @Column({ name: 'contact_phone', length: 50, nullable: true })
  contactPhone: string;

  @Column({ name: 'contact_email', length: 255, nullable: true })
  contactEmail: string;

  @Column({ name: 'address', type: 'text', nullable: true })
  address: string;

  @Column({ name: 'payout_cycle', length: 50, default: 'weekly' })
  payoutCycle: string; // 'daily' | 'weekly' | 'monthly'

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Category, (category) => category.stores, { nullable: true })
  @JoinColumn({ name: 'category_id' })
  categoryRelation: Category;

  @OneToMany(() => Product, (product) => product.store)
  products: Product[];

  @OneToMany(() => Deal, (deal) => deal.store)
  deals: Deal[];

  @OneToMany(() => Payment, (payment) => payment.store)
  payments: Payment[];

  @ManyToOne(() => Vendor, (vendor) => vendor.stores)
  @JoinColumn({ name: 'vendor_id' })
  vendor: Vendor;

  @OneToMany(() => Review, (review) => review.store)
  reviews: Review[];
}

