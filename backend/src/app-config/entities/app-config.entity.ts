import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity('app_config')
export class AppConfig {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'splash_image_url', length: 500, nullable: true })
  splashImageUrl: string;

  @Column({ name: 'maintenance_mode', default: false })
  maintenanceMode: boolean;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
