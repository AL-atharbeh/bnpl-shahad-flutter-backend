import { IsNumber, IsString, IsBoolean, IsOptional } from 'class-validator';

export class UpdateFeaturedBrandDto {
  @IsNumber()
  @IsOptional()
  storeId?: number;

  @IsString()
  @IsOptional()
  imageUrl?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}
