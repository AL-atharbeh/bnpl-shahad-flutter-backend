import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('contact_settings')
export class ContactSetting {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'contact_email', length: 255 })
  contactEmail: string;

  @Column({ name: 'contact_phone', length: 20 })
  contactPhone: string;

  @Column({ name: 'whatsapp_number', length: 20 })
  whatsappNumber: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

