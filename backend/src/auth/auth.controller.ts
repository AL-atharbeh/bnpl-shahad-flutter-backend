import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { CheckPhoneDto } from './dto/check-phone.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { CreateAccountDto } from './dto/create-account.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('check-phone')
  @ApiOperation({
    summary: 'Check if phone number exists',
    description: 'Check if a phone number is already registered in the system',
  })
  @ApiResponse({
    status: 200,
    description: 'Phone check successful',
  })
  async checkPhone(@Body() checkPhoneDto: CheckPhoneDto) {
    return this.authService.checkPhone(checkPhoneDto);
  }

  @Post('send-otp')
  @ApiOperation({
    summary: 'Send OTP to phone',
    description: 'Send a 6-digit OTP code to the provided phone number',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP sent successfully',
  })
  async sendOtp(@Body() sendOtpDto: SendOtpDto) {
    return this.authService.sendOtp(sendOtpDto);
  }

  @Post('verify-otp')
  @ApiOperation({
    summary: 'Verify OTP code',
    description: 'Verify the OTP code sent to phone number',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP verified successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid or expired OTP',
  })
  async verifyOtp(@Body() verifyOtpDto: VerifyOtpDto) {
    return this.authService.verifyOtp(verifyOtpDto);
  }

  @Post('create-account')
  @ApiOperation({
    summary: 'Create new account',
    description: 'Create a new user account with profile data and civil ID',
  })
  @ApiResponse({
    status: 201,
    description: 'Account created successfully',
  })
  @ApiResponse({
    status: 409,
    description: 'Phone or email already exists',
  })
  async createAccount(@Body() createAccountDto: CreateAccountDto) {
    return this.authService.createAccount(createAccountDto);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get user profile',
    description: 'Get authenticated user profile',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile retrieved successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized',
  })
  async getProfile(@Request() req) {
    return this.authService.getProfile(req.user.id);
  }
}

