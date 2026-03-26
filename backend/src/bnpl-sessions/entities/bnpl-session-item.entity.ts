import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    ManyToOne,
    JoinColumn
} from 'typeorm';
import { BnplSession } from './bnpl-session.entity';

@Entity('bnpl_session_items')
export class BnplSessionItem {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ name: 'session_id' })
    sessionId: number;

    @Column({ name: 'product_id', nullable: true })
    productId: number;

    @Column({ length: 255 })
    name: string;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    price: number;

    @Column({ default: 1 })
    quantity: number;

    @Column({ type: 'text', nullable: true })
    image: string;

    @Column({ type: 'text', nullable: true })
    description: string;

    @ManyToOne(() => BnplSession, (session) => session.sessionItems, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'session_id' })
    session: BnplSession;
}
