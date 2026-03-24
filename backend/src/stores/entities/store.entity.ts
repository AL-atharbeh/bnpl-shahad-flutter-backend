import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Product } from '../../products/entities/product.entity';
import { Payment } from '../../payments/entities/payment.entity';
import { Category } from '../../categories/entities/category.entity';
import { Deal } from '../../deals/entities/deal.entity';

@Entity('stores')
export class Store {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255 })
  name: string;

  @Column({ name: 'name_ar', length: 255, nullable: true })
  nameAr: string;

  @Column({ name: 'logo_url', type: 'longtext', nullable: true })
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

  @Column({ name: 'commission_rate', type: 'decimal', precision: 5, scale: 2, default: 2.5 })
  commissionRate: number;

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

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'top_store', type: 'boolean', default: false })
  topStore: boolean;

  @Column({ name: 'products_count', default: 0 })
  productsCount: number;

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
}

