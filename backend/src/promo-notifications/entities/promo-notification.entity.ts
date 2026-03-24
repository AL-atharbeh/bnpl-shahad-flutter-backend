import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Category } from '../../categories/entities/category.entity';

@Entity('promo_notifications')
export class PromoNotification {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255 })
  title: string;

  @Column({ name: 'title_ar', length: 255 })
  titleAr: string;

  @Column({ length: 255, nullable: true })
  subtitle: string;

  @Column({ name: 'subtitle_ar', length: 255, nullable: true })
  subtitleAr: string;

  @Column({ length: 100, nullable: true })
  icon: string;

  @Column({ name: 'background_color', length: 50, default: '#10B981' })
  backgroundColor: string;

  @Column({ name: 'text_color', length: 50, default: '#FFFFFF' })
  textColor: string;

  @Column({ name: 'category_id', nullable: true })
  categoryId: number;

  @Column({
    name: 'link_type',
    type: 'enum',
    enum: ['category', 'store', 'product', 'external', 'none'],
    default: 'none',
  })
  linkType: string;

  @Column({ name: 'link_id', nullable: true })
  linkId: number;

  @Column({ name: 'link_url', length: 500, nullable: true })
  linkUrl: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'sort_order', default: 0 })
  sortOrder: number;

  @Column({ name: 'start_date', type: 'datetime', nullable: true })
  startDate: Date;

  @Column({ name: 'end_date', type: 'datetime', nullable: true })
  endDate: Date;

  @Column({ name: 'click_count', default: 0 })
  clickCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Category, { nullable: true })
  @JoinColumn({ name: 'category_id' })
  category: Category;
}

