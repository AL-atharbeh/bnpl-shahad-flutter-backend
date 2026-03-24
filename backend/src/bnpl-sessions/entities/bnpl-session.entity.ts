import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
    OneToMany,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Store } from '../../stores/entities/store.entity';
import { BnplSessionItem } from './bnpl-session-item.entity';

export enum SessionStatus {
    PENDING = 'pending',
    APPROVED = 'approved',
    PAYMENT_PENDING = 'payment_pending',
    REJECTED = 'rejected',
    COMPLETED = 'completed',
    CANCELLED = 'cancelled',
    EXPIRED = 'expired',
}

@Entity('bnpl_sessions')
export class BnplSession {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ name: 'session_id', length: 100, unique: true })
    sessionId: string;

    @Column({ name: 'store_id' })
    storeId: number;

    @Column({ name: 'store_order_id', length: 255 })
    storeOrderId: string;

    @Column({ name: 'user_id', nullable: true })
    userId: number;

    @Column({ name: 'customer_phone', length: 20, nullable: true })
    customerPhone: string;

    @Column({ name: 'customer_email', length: 255, nullable: true })
    customerEmail: string;

    @Column({ name: 'customer_name', length: 255, nullable: true })
    customerName: string;

    @Column({ name: 'total_amount', type: 'decimal', precision: 10, scale: 2 })
    totalAmount: number;

    @Column({ length: 3, default: 'JOD' })
    currency: string;

    @Column({ name: 'installments_count', default: 4 })
    installmentsCount: number;

    @OneToMany(() => BnplSessionItem, (item) => item.session)
    sessionItems: BnplSessionItem[];

    @Column({
        type: 'enum',
        enum: SessionStatus,
        default: SessionStatus.PENDING,
    })
    status: SessionStatus;

    @Column({ name: 'success_url', type: 'text', nullable: true })
    successUrl: string;

    @Column({ name: 'cancel_url', type: 'text', nullable: true })
    cancelUrl: string;

    @Column({ name: 'webhook_url', type: 'text', nullable: true })
    webhookUrl: string;

    @Column({ type: 'json', nullable: true })
    metadata: any;

    @Column({ name: 'expires_at', type: 'timestamp', nullable: true })
    expiresAt: Date;

    @Column({ name: 'approved_at', type: 'timestamp', nullable: true })
    approvedAt: Date;

    @Column({ name: 'completed_at', type: 'timestamp', nullable: true })
    completedAt: Date;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @UpdateDateColumn({ name: 'updated_at' })
    updatedAt: Date;

    @ManyToOne(() => Store, { nullable: false })
    @JoinColumn({ name: 'store_id' })
    store: Store;

    @ManyToOne(() => User, { nullable: true })
    @JoinColumn({ name: 'user_id' })
    user: User;
}
