import { IsString, IsOptional, IsNumber, IsBoolean, Min, Max } from 'class-validator';

export class CreateStoreDto {
    @IsString()
    name: string;

    @IsString()
    @IsOptional()
    nameAr?: string;

    @IsString()
    @IsOptional()
    logoUrl?: string;

    @IsString()
    @IsOptional()
    description?: string;

    @IsString()
    @IsOptional()
    descriptionAr?: string;

    @IsNumber()
    @IsOptional()
    categoryId?: number;

    @IsNumber()
    @Min(0)
    @Max(5)
    @IsOptional()
    rating?: number;

    @IsNumber()
    @Min(0)
    @Max(100)
    @IsOptional()
    commissionRate?: number;

    @IsNumber()
    @Min(0)
    @IsOptional()
    minOrderAmount?: number;

    @IsNumber()
    @Min(0)
    @IsOptional()
    maxOrderAmount?: number;

    @IsString()
    @IsOptional()
    websiteUrl?: string;

    @IsString()
    @IsOptional()
    storeUrl?: string;

    @IsBoolean()
    @IsOptional()
    isActive?: boolean;

    @IsBoolean()
    @IsOptional()
    topStore?: boolean;
}
