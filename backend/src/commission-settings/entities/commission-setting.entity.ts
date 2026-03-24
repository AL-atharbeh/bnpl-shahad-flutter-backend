import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('commission_settings')
export class CommissionSetting {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ type: 'decimal', precision: 5, scale: 4 })
    bankCommission: number;

    @Column({ type: 'decimal', precision: 5, scale: 4 })
    platformCommission: number;

    @Column({ type: 'decimal', precision: 5, scale: 4, default: 0.0500 })
    storeDiscount: number;

    @Column({ type: 'datetime' })
    effectiveFrom: Date;

    @Column({ nullable: true })
    createdBy: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
