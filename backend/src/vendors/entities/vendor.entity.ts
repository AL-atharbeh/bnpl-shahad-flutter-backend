import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { Store } from '../../stores/entities/store.entity';

@Entity('vendors')
export class Vendor {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ length: 255 })
    name: string;

    @Column({ length: 255, unique: true })
    email: string;

    @Column({ length: 20, unique: true })
    phone: string;

    @Column({ name: 'password_hash', length: 255 })
    @Exclude()
    passwordHash: string;

    @Column({ name: 'store_id' })
    storeId: number;

    @ManyToOne(() => Store)
    @JoinColumn({ name: 'store_id' })
    store: Store;

    @Column({ name: 'is_active', default: true })
    isActive: boolean;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @UpdateDateColumn({ name: 'updated_at' })
    updatedAt: Date;
}
