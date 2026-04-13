import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('extension_options')
export class ExtensionOption {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'int' })
  days: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  fee: number;

  @Column({ name: 'name_ar', length: 255 })
  nameAr: string;

  @Column({ name: 'name_en', length: 255 })
  nameEn: string;

  @Column({ name: 'is_popular', default: false })
  isPopular: boolean;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
