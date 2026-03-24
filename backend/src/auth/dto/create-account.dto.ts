import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsDateString,
  IsNumber,
  Matches,
  MinLength,
} from 'class-validator';

export class CreateAccountDto {
  @ApiProperty({
    description: 'Phone number (must be verified)',
    example: '+962799999999',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+962\d{9}$/, {
    message: 'Phone number must be in format +962XXXXXXXXX',
  })
  phone: string;

  @ApiProperty({
    description: 'Full name',
    example: 'أحمد محمد',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  fullName: string;

  @ApiProperty({
    description: 'Civil ID number',
    example: '2991234567',
  })
  @IsString()
  @IsNotEmpty()
  civilIdNumber: string;

  @ApiProperty({
    description: 'Date of birth',
    example: '1990-01-01',
  })
  @IsDateString()
  @IsNotEmpty()
  dateOfBirth: string;

  @ApiProperty({
    description: 'Address',
    example: 'Amman, Jordan',
  })
  @IsString()
  @IsNotEmpty()
  address: string;

  @ApiProperty({
    description: 'Monthly income in JOD',
    example: 1500.00,
  })
  @IsNumber()
  @IsNotEmpty()
  monthlyIncome: number;

  @ApiProperty({
    description: 'Employer name',
    example: 'Tech Company',
  })
  @IsString()
  @IsNotEmpty()
  employer: string;

  @ApiProperty({
    description: 'Civil ID front image (base64 or URL)',
    example: 'data:image/jpeg;base64,...',
  })
  @IsString()
  @IsNotEmpty()
  civilIdFront: string;

  @ApiProperty({
    description: 'Civil ID back image (base64 or URL)',
    example: 'data:image/jpeg;base64,...',
  })
  @IsString()
  @IsNotEmpty()
  civilIdBack: string;

  @ApiProperty({
    description: 'Email (optional)',
    example: 'ahmad@example.com',
    required: false,
  })
  @IsString()
  @IsOptional()
  email?: string;
}

