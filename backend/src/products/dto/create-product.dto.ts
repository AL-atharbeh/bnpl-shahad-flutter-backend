import { Type } from 'class-transformer';
import { IsBoolean, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString, MaxLength, Min, IsArray } from 'class-validator';

export class CreateProductDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  store_id: number;

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  name_ar?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  description_ar?: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price: number;

  @IsOptional()
  @IsString()
  @MaxLength(3)
  currency?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  category?: string;

  @Type(() => Number)
  @IsOptional()
  @IsInt()
  @Min(1)
  category_id?: number;

  @IsOptional()
  @IsString()
  image_url?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];

  @Type(() => Boolean)
  @IsOptional()
  @IsBoolean()
  in_stock?: boolean;

  @Type(() => Number)
  @IsOptional()
  @IsNumber()
  rating?: number;

  @Type(() => Number)
  @IsOptional()
  @IsInt()
  reviews_count?: number;

  @Type(() => Boolean)
  @IsOptional()
  @IsBoolean()
  is_active?: boolean;
}
