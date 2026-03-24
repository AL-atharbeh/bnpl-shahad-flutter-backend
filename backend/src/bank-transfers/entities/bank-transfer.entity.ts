import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToMany, JoinTable } from 'typeorm';
import { Payment } from '../../payments/entities/payment.entity';

@Entity('bank_transfers')
export class BankTransfer {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ type: 'datetime' })
    transferDate: Date;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    amount: number;

    @Column({ nullable: true })
    transferredBy: string;

    @Column({ type: 'enum', enum: ['pending', 'completed', 'failed'], default: 'pending' })
    status: string;

    @Column({ type: 'text', nullable: true })
    notes: string;

    @ManyToMany(() => Payment)
    @JoinTable({
        name: 'bank_transfer_payments',
        joinColumn: { name: 'bank_transfer_id', referencedColumnName: 'id' },
        inverseJoinColumn: { name: 'payment_id', referencedColumnName: 'id' },
    })
    payments: Payment[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
