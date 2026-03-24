import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ContactService } from './contact.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ContactMessageStatus } from './entities/contact-message.entity';

@ApiTags('contact')
@Controller('contact')
export class ContactController {
  constructor(private readonly contactService: ContactService) {}

  // Public endpoints (no auth required)
  @Get('settings')
  @ApiOperation({ summary: 'Get contact settings (email, phone, WhatsApp)' })
  async getContactSettings() {
    const settings = await this.contactService.getContactSettings();
    return {
      success: true,
      data: {
        contactEmail: settings.contactEmail,
        contactPhone: settings.contactPhone,
        whatsappNumber: settings.whatsappNumber,
      },
    };
  }

  @Post('message')
  @ApiOperation({ summary: 'Send a contact message (public)' })
  async createContactMessage(
    @Body('fullName') fullName: string,
    @Body('email') email: string,
    @Body('phone') phone: string,
    @Body('message') message: string,
  ) {
    const contactMessage = await this.contactService.createContactMessage(
      fullName,
      email,
      phone,
      message,
    );

    return {
      success: true,
      message: 'تم إرسال رسالتك بنجاح. سنتواصل معك قريباً',
      data: {
        id: contactMessage.id,
        fullName: contactMessage.fullName,
        email: contactMessage.email,
        createdAt: contactMessage.createdAt,
      },
    };
  }

  // Admin endpoints (auth required)
  @Put('settings')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update contact settings (admin only)' })
  async updateContactSettings(
    @Body('contactEmail') contactEmail?: string,
    @Body('contactPhone') contactPhone?: string,
    @Body('whatsappNumber') whatsappNumber?: string,
  ) {
    const settings = await this.contactService.updateContactSettings({
      contactEmail,
      contactPhone,
      whatsappNumber,
    });

    return {
      success: true,
      message: 'تم تحديث معلومات التواصل بنجاح',
      data: {
        contactEmail: settings.contactEmail,
        contactPhone: settings.contactPhone,
        whatsappNumber: settings.whatsappNumber,
      },
    };
  }

  @Get('messages')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all contact messages (admin only)' })
  async getAllMessages(@Body('status') status?: ContactMessageStatus) {
    const messages = await this.contactService.getAllMessages(status);
    return {
      success: true,
      data: messages,
    };
  }

  @Get('messages/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get a single contact message (admin only)' })
  async getMessageById(@Param('id', ParseIntPipe) id: number) {
    const message = await this.contactService.getMessageById(id);
    return {
      success: true,
      data: message,
    };
  }

  @Put('messages/:id/status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update message status (admin only)' })
  async updateMessageStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body('status') status: ContactMessageStatus,
  ) {
    const message = await this.contactService.updateMessageStatus(id, status);
    return {
      success: true,
      message: 'تم تحديث حالة الرسالة بنجاح',
      data: message,
    };
  }

  @Delete('messages/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a contact message (admin only)' })
  async deleteMessage(@Param('id', ParseIntPipe) id: number) {
    await this.contactService.deleteMessage(id);
    return {
      success: true,
      message: 'تم حذف الرسالة بنجاح',
    };
  }
}

