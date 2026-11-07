import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { Vendor } from './entities/vendor.entity';
import { VendorNotification } from './entities/vendor-notification.entity';

export interface VendorMessage {
  type: string;
  title: string;
  body: string;
  titleEn: string;
  bodyEn: string;
  data?: Record<string, any>;
}

@Injectable()
export class VendorNotificationsService {
  private readonly logger = new Logger(VendorNotificationsService.name);

  constructor(
    @InjectRepository(VendorNotification)
    private readonly notifications: Repository<VendorNotification>,
    @InjectRepository(Vendor)
    private readonly vendors: Repository<Vendor>,
  ) {}

  /**
   * Tells every merchant account of a store. Never throws: a notice that
   * could not be saved must not undo the sale or decision it reports.
   */
  async notifyStore(storeId: number, message: VendorMessage): Promise<void> {
    try {
      const vendors = await this.vendors.find({ where: { storeId }, select: ['id'] });
      if (!vendors.length) return;
      await this.notifications.save(
        vendors.map((v) => this.notifications.create({ ...message, vendorId: v.id, storeId })),
      );
    } catch (err) {
      this.logger.warn(`Could not notify store ${storeId} (${message.type}): ${err.message}`);
    }
  }

  async list(vendorId: number, limit = 50) {
    const [items, unread] = await Promise.all([
      this.notifications.find({
        where: { vendorId },
        order: { createdAt: 'DESC' },
        take: Math.min(Math.max(limit, 1), 100),
      }),
      this.notifications.count({ where: { vendorId, readAt: IsNull() } }),
    ]);
    return { items, unread };
  }

  /** Marks one notice, or all of them when no id is given, as read. */
  async markRead(vendorId: number, id?: number): Promise<void> {
    await this.notifications.update(
      id ? { vendorId, id, readAt: IsNull() } : { vendorId, readAt: IsNull() },
      { readAt: new Date() },
    );
  }
}
