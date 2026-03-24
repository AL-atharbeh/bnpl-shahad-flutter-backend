import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ContactController } from './contact.controller';
import { ContactService } from './contact.service';
import { ContactSetting } from './entities/contact-setting.entity';
import { ContactMessage } from './entities/contact-message.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ContactSetting, ContactMessage])],
  controllers: [ContactController],
  providers: [ContactService],
  exports: [ContactService],
})
export class ContactModule {}

