import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { Store } from '../../stores/entities/store.entity';
import { Product } from '../../products/entities/product.entity';

@Entity('deals')
export class Deal {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'store_id' })
  storeId: number;

  @Column({ name: 'product_id' })
  productId: number;

  @Column({ length: 255 })
  title: string;

  @Column({ name: 'title_ar', length: 255, nullable: true })
  titleAr: string | null;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ name: 'description_ar', type: 'text', nullable: true })
  descriptionAr: string | null;

  @Column({ name: 'discount_label', length: 120, nullable: true })
  discountLabel: string | null;

  @Column({ name: 'discount_value', length: 120, nullable: true })
  discountValue: string | null;

  @Column({ name: 'image_url', type: 'text', nullable: true })
  imageUrl: string | null;

  @Column({ name: 'store_url', type: 'text', nullable: true })
  storeUrl: string | null;

  @Column({ name: 'badge_color', length: 12, nullable: true })
  badgeColor: string | null;

  @Column({ name: 'accent_color', length: 12, nullable: true })
  accentColor: string | null;

  @Column({ name: 'start_date', type: 'datetime', nullable: true })
  startDate: Date | null;

  @Column({ name: 'end_date', type: 'datetime', nullable: true })
  endDate: Date | null;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'show_in_home', type: 'boolean', default: true })
  showInHome: boolean;

  @Column({ name: 'sort_order', default: 0 })
  sortOrder: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Store, (store) => store.deals, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'store_id' })
  store: Store;

  @ManyToOne(() => Product, (product) => product.deals, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
