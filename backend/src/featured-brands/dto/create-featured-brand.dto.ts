import { IsNumber, IsString, IsBoolean, IsOptional } from 'class-validator';

export class CreateFeaturedBrandDto {
  @IsNumber()
  storeId: number;

  @IsString()
  imageUrl: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}
