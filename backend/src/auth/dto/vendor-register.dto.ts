import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VendorRegisterDto {
    @ApiProperty({ example: 'احمد علي' })
    @IsString()
    @IsNotEmpty()
    name: string;

    @ApiProperty({ example: 'متجر زارا' })
    @IsString()
    @IsNotEmpty()
    storeName: string;

    @ApiProperty({ example: 'vendor@example.com' })
    @IsEmail()
    email: string;

    @ApiProperty({ example: '+962791234567' })
    @IsString()
    @IsNotEmpty()
    phone: string;

    @ApiProperty({ example: 'password123' })
    @IsString()
    @IsNotEmpty()
    @MinLength(6)
    password: string;
}
