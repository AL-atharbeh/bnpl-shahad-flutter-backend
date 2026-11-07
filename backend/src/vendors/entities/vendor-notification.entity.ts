import { Column, CreateDateColumn, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

/**
 * Something a merchant should know about their store: a review decision, a
 * new sale, a settlement. Merchants are not users, so this is not the
 * customers' notification table. Text is kept in both languages because the
 * portal and app switch language after the event.
 */
@Entity('vendor_notifications')
@Index(['vendorId', 'createdAt'])
export class VendorNotification {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'vendor_id' })
  vendorId: number;

  @Column({ name: 'store_id', nullable: true })
  storeId: number;

  @Column({ length: 50 })
  type: string;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text' })
  body: string;

  @Column({ name: 'title_en', length: 255 })
  titleEn: string;

  @Column({ name: 'body_en', type: 'text' })
  bodyEn: string;

  @Column({ type: 'jsonb', nullable: true })
  data: Record<string, any>;

  @Column({ name: 'read_at', type: 'timestamp', nullable: true })
  readAt: Date | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
