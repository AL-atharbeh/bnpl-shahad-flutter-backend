import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Store } from '../../stores/entities/store.entity';
import { Product } from '../../products/entities/product.entity';

@Entity('categories')
export class Category {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255 })
  name: string;

  @Column({ name: 'name_ar', length: 255 })
  nameAr: string;

  @Column({ name: 'gender_type', type: 'enum', enum: ['Women', 'Men', 'Kids', 'All'], nullable: true, default: 'All' })
  genderType: 'Women' | 'Men' | 'Kids' | 'All';


  @Column({ name: 'image_url', type: 'longtext', nullable: true })
  imageUrl: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'description_ar', type: 'text', nullable: true })
  descriptionAr: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'sort_order', default: 0 })
  sortOrder: number;

  @Column({ name: 'stores_count', default: 0 })
  storesCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @OneToMany(() => Store, (store) => store.categoryRelation)
  stores: Store[];

  @OneToMany(() => Product, (product) => product.categoryRelation)
  products: Product[];
}

