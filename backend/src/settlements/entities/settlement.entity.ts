import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToMany, JoinTable } from 'typeorm';
import { Payment } from '../../payments/entities/payment.entity';

@Entity('settlements')
export class Settlement {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ type: 'datetime' })
    settlementDate: Date;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    totalCollected: number;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    bankShare: number;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    platformShare: number;

    @Column({ type: 'enum', enum: ['pending', 'completed', 'failed'], default: 'pending' })
    status: string;

    @Column({ type: 'text', nullable: true })
    notes: string;

    @ManyToMany(() => Payment)
    @JoinTable({
        name: 'settlement_payments',
        joinColumn: { name: 'settlement_id', referencedColumnName: 'id' },
        inverseJoinColumn: { name: 'payment_id', referencedColumnName: 'id' },
    })
    payments: Payment[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
