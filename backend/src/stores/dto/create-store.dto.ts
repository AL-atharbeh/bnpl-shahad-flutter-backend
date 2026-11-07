import { IsString, IsOptional, IsNumber, IsBoolean, Min, Max, MaxLength } from 'class-validator';

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
    @Max(100)
    @IsOptional()
    bankCommissionRate?: number;

    @IsNumber()
    @Min(0)
    @Max(100)
    @IsOptional()
    platformCommissionRate?: number;

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

    @IsNumber()
    @IsOptional()
    vendorId?: number;

    @IsString()
    @IsOptional()
    status?: string;

    @IsNumber()
    @IsOptional()
    genderCategoryId?: number;

    @IsString()
    @IsOptional()
    contactPerson?: string;

    @IsString()
    @IsOptional()
    contactPhone?: string;

    @IsString()
    @IsOptional()
    contactEmail?: string;

    @IsString()
    @IsOptional()
    address?: string;

    @IsString()
    @IsOptional()
    payoutCycle?: string;

    // Merchant application. Formats are checked again, all together, when
    // the merchant submits it for review.

    @IsString()
    @MaxLength(255)
    @IsOptional()
    legalName?: string;

    @IsString()
    @MaxLength(50)
    @IsOptional()
    commercialRegistrationNo?: string;

    @IsString()
    @MaxLength(50)
    @IsOptional()
    tradeLicenseNo?: string;

    @IsString()
    @MaxLength(100)
    @IsOptional()
    city?: string;

    @IsString()
    @MaxLength(20)
    @IsOptional()
    ownerNationalId?: string;

    @IsString()
    @MaxLength(100)
    @IsOptional()
    bankName?: string;

    @IsString()
    @MaxLength(255)
    @IsOptional()
    bankAccountHolder?: string;

    // Up to 50 so it can arrive as people write it, with spaces; it is
    // stored without them, at most 34 characters.
    @IsString()
    @MaxLength(50)
    @IsOptional()
    iban?: string;
}
