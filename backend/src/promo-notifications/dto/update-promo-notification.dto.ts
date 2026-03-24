import { PartialType } from '@nestjs/mapped-types';
import { CreatePromoNotificationDto } from './create-promo-notification.dto';

export class UpdatePromoNotificationDto extends PartialType(CreatePromoNotificationDto) {}

