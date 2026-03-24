import { IsOptional, IsString, IsBoolean, IsEmail, IsNumber } from 'class-validator';

export class AdminUpdateUserDto {
    @IsOptional()
    @IsString()
    name?: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsOptional()
    @IsString()
    phone?: string;

    @IsOptional()
    @IsString()
    address?: string;

    @IsOptional()
    @IsNumber()
    monthlyIncome?: number;

    @IsOptional()
    @IsString()
    employer?: string;

    @IsOptional()
    @IsBoolean()
    isActive?: boolean;

    @IsOptional()
    @IsString()
    role?: string;
}
