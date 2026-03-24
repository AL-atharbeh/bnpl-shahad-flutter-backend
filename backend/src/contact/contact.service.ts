import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ContactSetting } from './entities/contact-setting.entity';
import {
  ContactMessage,
  ContactMessageStatus,
} from './entities/contact-message.entity';

@Injectable()
export class ContactService {
  constructor(
    @InjectRepository(ContactSetting)
    private contactSettingRepository: Repository<ContactSetting>,
    @InjectRepository(ContactMessage)
    private contactMessageRepository: Repository<ContactMessage>,
  ) {}

  /**
   * Get contact settings (email, phone, WhatsApp)
   */
  async getContactSettings(): Promise<ContactSetting> {
    let settings = await this.contactSettingRepository.findOne({
      where: { id: 1 },
    });

    // If no settings exist, create default ones
    if (!settings) {
      settings = this.contactSettingRepository.create({
        contactEmail: 'athatbehahmed99@gmail.com',
        contactPhone: '+962792380449',
        whatsappNumber: '962792380449',
      });
      settings = await this.contactSettingRepository.save(settings);
    }

    return settings;
  }

  /**
   * Update contact settings
   */
  async updateContactSettings(
    updateData: Partial<ContactSetting>,
  ): Promise<ContactSetting> {
    let settings = await this.contactSettingRepository.findOne({
      where: { id: 1 },
    });

    if (!settings) {
      // Create if doesn't exist
      settings = this.contactSettingRepository.create({
        contactEmail: updateData.contactEmail || 'athatbehahmed99@gmail.com',
        contactPhone: updateData.contactPhone || '+962792380449',
        whatsappNumber: updateData.whatsappNumber || '962792380449',
      });
    } else {
      // Update existing
      Object.assign(settings, updateData);
    }

    return this.contactSettingRepository.save(settings);
  }

  /**
   * Create a new contact message from user
   */
  async createContactMessage(
    fullName: string,
    email: string,
    phone: string,
    message: string,
  ): Promise<ContactMessage> {
    const contactMessage = this.contactMessageRepository.create({
      fullName,
      email,
      phone,
      message,
      status: ContactMessageStatus.NEW,
    });

    return this.contactMessageRepository.save(contactMessage);
  }

  /**
   * Get all contact messages (admin only)
   */
  async getAllMessages(
    status?: ContactMessageStatus,
  ): Promise<ContactMessage[]> {
    const where = status ? { status } : {};
    return this.contactMessageRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get a single contact message by ID
   */
  async getMessageById(id: number): Promise<ContactMessage> {
    const message = await this.contactMessageRepository.findOne({
      where: { id },
    });

    if (!message) {
      throw new NotFoundException('الرسالة غير موجودة');
    }

    return message;
  }

  /**
   * Update message status
   */
  async updateMessageStatus(
    id: number,
    status: ContactMessageStatus,
  ): Promise<ContactMessage> {
    const message = await this.getMessageById(id);
    message.status = status;
    return this.contactMessageRepository.save(message);
  }

  /**
   * Delete a contact message
   */
  async deleteMessage(id: number): Promise<void> {
    const message = await this.getMessageById(id);
    await this.contactMessageRepository.remove(message);
  }
}

