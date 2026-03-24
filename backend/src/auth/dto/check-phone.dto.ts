import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, Matches } from 'class-validator';

export class CheckPhoneDto {
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
}

