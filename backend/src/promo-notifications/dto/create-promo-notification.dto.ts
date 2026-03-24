import { IsString, IsOptional, IsBoolean, IsInt, IsEnum, IsDateString } from 'class-validator';

export class CreatePromoNotificationDto {
  @IsString()
  title: string;

  @IsString()
  titleAr: string;

  @IsString()
  @IsOptional()
  subtitle?: string;

  @IsString()
  @IsOptional()
  subtitleAr?: string;

  @IsString()
  @IsOptional()
  icon?: string;

  @IsString()
  @IsOptional()
  backgroundColor?: string;

  @IsString()
  @IsOptional()
  textColor?: string;

  @IsInt()
  @IsOptional()
  categoryId?: number;

  @IsEnum(['category', 'store', 'product', 'external', 'none'])
  @IsOptional()
  linkType?: string;

  @IsInt()
  @IsOptional()
  linkId?: number;

  @IsString()
  @IsOptional()
  linkUrl?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsInt()
  @IsOptional()
  sortOrder?: number;

  @IsDateString()
  @IsOptional()
  startDate?: string;

  @IsDateString()
  @IsOptional()
  endDate?: string;
}

