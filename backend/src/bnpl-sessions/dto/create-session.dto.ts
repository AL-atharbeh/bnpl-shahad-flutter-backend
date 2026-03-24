import { IsNotEmpty, IsNumber, IsString, IsOptional, IsArray, Min, IsEmail, IsUrl } from 'class-validator';

export class SessionItemDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsNumber()
    @Min(1)
    quantity: number;

    @IsNumber()
    @Min(0)
    price: number;

    @IsString()
    @IsOptional()
    description?: string;

    @IsString()
    @IsOptional()
    image?: string;
}

export class CreateSessionDto {
    @IsNumber()
    store_id: number;

    @IsString()
    @IsNotEmpty()
    store_order_id: string;

    @IsNumber()
    @Min(1)
    total_amount: number;

    @IsString()
    @IsOptional()
    currency?: string;

    @IsNumber()
    @IsOptional()
    @Min(2)
    installments_count?: number;

    @IsString()
    @IsOptional()
    customer_phone?: string;

    @IsEmail()
    @IsOptional()
    customer_email?: string;

    @IsString()
    @IsOptional()
    customer_name?: string;

    @IsArray()
    @IsOptional()
    items?: SessionItemDto[];

    @IsString()
    @IsOptional()
    success_url?: string;

    @IsString()
    @IsOptional()
    cancel_url?: string;

    @IsUrl()
    @IsOptional()
    webhook_url?: string;

    @IsOptional()
    metadata?: any;
}
