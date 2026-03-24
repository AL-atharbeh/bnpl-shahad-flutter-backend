import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { OtpCode } from '../users/entities/otp-code.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class OtpService {
  constructor(
    @InjectRepository(OtpCode)
    private otpCodeRepository: Repository<OtpCode>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private configService: ConfigService,
  ) {}

  /**
   * Generate a 6-digit OTP code
   */
  private generateOtpCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Send OTP to phone number
   */
  async sendOtp(phone: string): Promise<{ message: string; expiresIn: string }> {
    // Generate OTP code
    const code = this.generateOtpCode();
    const expiryMinutes = this.configService.get('OTP_EXPIRY_MINUTES', 5);
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + expiryMinutes);

    // Delete any existing unused OTPs for this phone
    await this.otpCodeRepository.delete({
      phone,
      isUsed: false,
    });

    // Save new OTP to otp_codes table
    await this.otpCodeRepository.save({
      phone,
      code,
      expiresAt,
      isUsed: false,
    });

    // Update or create user with OTP and set phone as unverified
    const user = await this.userRepository.findOne({ where: { phone } });
    if (user) {
      user.otp = code;
      user.isPhoneVerified = false; // Reset verification status when new OTP is sent
      await this.userRepository.save(user);
    }
    // Note: For new users who don't exist yet, we only store OTP in otp_codes table
    // The user record will be created during registration, and OTP verification
    // will be done through otp_codes table for new users

    // TODO: Integrate with AWS SNS or SMS provider
    console.log(`📱 OTP for ${phone}: ${code}`);
    console.log(`⏰ Expires at: ${expiresAt.toISOString()}`);

    return {
      message: 'تم إرسال رمز التحقق',
      expiresIn: `${expiryMinutes} minutes`,
    };
  }

  /**
   * Verify OTP code
   */
  async verifyOtp(phone: string, code: string): Promise<boolean> {
    // Verify OTP from otp_codes table (for expiration check)
    const otpRecord = await this.otpCodeRepository.findOne({
      where: {
        phone,
        code,
        isUsed: false,
      },
    });

    if (!otpRecord) {
      throw new BadRequestException('رمز التحقق غير صحيح');
    }

    // Check if expired
    if (new Date() > otpRecord.expiresAt) {
      throw new BadRequestException('رمز التحقق منتهي الصلاحية');
    }

    // Check user's OTP field if user exists
    let user = await this.userRepository.findOne({ where: { phone } });
    
    if (user) {
      // For existing users, verify OTP matches user's stored OTP
      if (!user.otp || user.otp !== code) {
        throw new BadRequestException('رمز التحقق غير صحيح');
      }
      
      // Clear OTP from user and verify phone
      user.otp = null;
      user.isPhoneVerified = true;
      await this.userRepository.save(user);
    } else {
      // For new users, create a temporary user record with verified phone
      // This allows createAccount to verify that phone was verified via OTP
      const tempPassword = Math.random().toString(36).slice(-10);
      const tempPasswordHash = await bcrypt.hash(tempPassword, 10);
      
      user = this.userRepository.create({
        phone,
        name: '', // Temporary, will be filled during createAccount
        passwordHash: tempPasswordHash, // Temporary password
        isPhoneVerified: true, // Phone verified via OTP
        otp: null, // OTP cleared after verification
        isActive: true,
      });
      
      await this.userRepository.save(user);
    }

    // Mark OTP as used in otp_codes table
    otpRecord.isUsed = true;
    otpRecord.usedAt = new Date();
    await this.otpCodeRepository.save(otpRecord);

    return true;
  }

  /**
   * Clean up expired OTPs (should be called periodically)
   */
  async cleanupExpiredOtps(): Promise<void> {
    await this.otpCodeRepository.delete({
      expiresAt: LessThan(new Date()),
    });
  }
}

