import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';

export class VerifyOtpDto {
  @ApiProperty({
    description: 'Phone number with country code',
    example: '+962799999999',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+962\d{9}$/, {
    message: 'Phone number must be in format +962XXXXXXXXX (9 digits after +962)',
  })
  phone: string;

  @ApiProperty({
    description: '6-digit OTP code',
    example: '123456',
  })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  code: string;
}

