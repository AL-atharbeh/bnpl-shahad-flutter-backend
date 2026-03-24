import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { Store } from '../stores/entities/store.entity';
import { User } from '../users/entities/user.entity';
import { Vendor } from '../vendors/entities/vendor.entity';
import { OtpService } from './otp.service';
import { CheckPhoneDto } from './dto/check-phone.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { CreateAccountDto } from './dto/create-account.dto';
import { VendorRegisterDto } from './dto/vendor-register.dto';
import { VendorLoginDto } from './dto/vendor-login.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
    @InjectRepository(Vendor)
    private vendorRepository: Repository<Vendor>,
    private jwtService: JwtService,
    private otpService: OtpService,
  ) { }

  /**
   * Check if phone number exists in database
   */
  async checkPhone(checkPhoneDto: CheckPhoneDto) {
    const { phone } = checkPhoneDto;
    const user = await this.userRepository.findOne({ where: { phone } });

    if (user) {
      return {
        success: true,
        exists: true,
        message: 'مستخدم موجود',
        data: {
          phone,
          name: user.name,
          requiresOtp: true,
        },
      };
    }

    return {
      success: true,
      exists: false,
      message: 'مستخدم جديد',
      data: {
        phone,
        requiresOtp: true,
        requiresRegistration: true,
      },
    };
  }

  /**
   * Send OTP to phone
   */
  async sendOtp(sendOtpDto: SendOtpDto) {
    const { phone } = sendOtpDto;
    const result = await this.otpService.sendOtp(phone);

    return {
      success: true,
      message: result.message,
      data: {
        phone,
        expiresIn: result.expiresIn,
      },
    };
  }

  /**
   * Verify OTP code
   */
  async verifyOtp(verifyOtpDto: VerifyOtpDto) {
    const { phone, code } = verifyOtpDto;

    // Verify OTP (this will set isPhoneVerified = true and clear OTP if valid)
    const isValid = await this.otpService.verifyOtp(phone, code);

    if (!isValid) {
      throw new UnauthorizedException('رمز التحقق غير صحيح');
    }

    // Check if user exists (user should exist now because otpService creates it if not)
    const user = await this.userRepository.findOne({ where: { phone } });

    if (user && user.isPhoneVerified) {
      // Check if user has completed profile (has name and other required fields)
      const userExists = user.name && user.name.trim() !== '';

      if (userExists) {
        // Existing user with complete profile - return token
        const token = this.generateToken(user);

        return {
          success: true,
          message: 'تم التحقق من رقم الهاتف بنجاح',
          data: {
            userExists: true,
            token,
            user: this.sanitizeUser(user),
          },
        };
      }
    }

    // New user or incomplete profile - return success but require profile completion
    return {
      success: true,
      message: 'تم التحقق من رقم الهاتف بنجاح',
      data: {
        userExists: false,
        phone,
        requiresProfileCompletion: true,
      },
    };
  }

  /**
   * Create new account with profile data
   */
  async createAccount(createAccountDto: CreateAccountDto) {
    const { phone, fullName, civilIdNumber, email, ...profileData } =
      createAccountDto;

    // Check if phone already exists and has complete profile
    const existingUser = await this.userRepository.findOne({
      where: { phone },
    });

    if (existingUser) {
      // Check if user has complete profile (has name)
      if (existingUser.name && existingUser.name.trim() !== '') {
        throw new ConflictException('رقم الهاتف مستخدم بالفعل');
      }
      // If user exists but incomplete profile, update it instead of creating new
      // This happens when user verified OTP but didn't complete registration
    }

    // Check if email already exists
    if (email) {
      const existingEmail = await this.userRepository.findOne({
        where: { email },
      });

      if (existingEmail && existingEmail.phone !== phone) {
        throw new ConflictException('البريد الإلكتروني مستخدم بالفعل');
      }
    }

    // Verify that phone number was verified via OTP
    const userToCheck = existingUser || await this.userRepository.findOne({
      where: { phone },
    });

    if (!userToCheck || !userToCheck.isPhoneVerified) {
      throw new BadRequestException('يجب التحقق من رقم الهاتف أولاً عبر OTP');
    }

    // Create temporary password (user will use OTP for login)
    const tempPassword = Math.random().toString(36).slice(-10);
    const passwordHash = await bcrypt.hash(tempPassword, 10);

    let user;
    if (existingUser && (!existingUser.name || existingUser.name.trim() === '')) {
      // Update existing incomplete user
      user = existingUser;
      user.name = fullName;
      user.civilIdNumber = civilIdNumber;
      user.email = email || null;
      user.passwordHash = passwordHash;
      user.otp = null; // Clear OTP after account creation
      Object.assign(user, profileData);
      await this.userRepository.save(user);
    } else {
      // Create new user
      user = this.userRepository.create({
        name: fullName,
        phone,
        civilIdNumber,
        email: email || null,
        passwordHash,
        isPhoneVerified: true, // Already verified via OTP
        otp: null, // Clear OTP after account creation
        ...profileData,
      });
      await this.userRepository.save(user);
    }

    // Generate JWT token
    const token = this.generateToken(user);

    return {
      success: true,
      message: 'تم إنشاء الحساب بنجاح',
      data: {
        token,
        user: this.sanitizeUser(user),
      },
    };
  }

  /**
   * Get user profile
   */
  async getProfile(userId: number) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('المستخدم غير موجود');
    }

    return {
      success: true,
      data: {
        user: this.sanitizeUser(user),
      },
    };
  }

  /**
   * Validate user by ID (used by JWT strategy)
   */
  async validateUserById(userId: number): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id: userId, isActive: true },
    });

    if (!user) {
      throw new UnauthorizedException('المستخدم غير موجود أو غير نشط');
    }

    return user;
  }

  /**
   * Vendor Registration: Creates both a Store and a Vendor Record
   */
  async vendorRegister(vendorRegisterDto: VendorRegisterDto) {
    const { name, storeName, email, phone, password } = vendorRegisterDto;

    // Check if vendor already exists in vendors table
    const existingVendor = await this.vendorRepository.findOne({
      where: [{ email }, { phone }],
    });

    if (existingVendor) {
      throw new ConflictException('البريد الإلكتروني أو رقم الهاتف مستخدم بالفعل للمورد');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // 1. Create the store
    const store = this.storeRepository.create({
      name: storeName,
      nameAr: storeName,
      isActive: true,
    });
    const savedStore = await this.storeRepository.save(store);

    // 2. Create the vendor record
    const vendor = this.vendorRepository.create({
      name,
      email,
      phone,
      passwordHash,
      storeId: savedStore.id,
      isActive: true,
    });

    await this.vendorRepository.save(vendor);

    const token = this.generateToken(vendor, 'vendor');

    return {
      success: true,
      message: 'تم إنشاء حساب المورد والمتجر بنجاح',
      data: {
        token,
        user: this.sanitizeVendor(vendor),
      },
    };
  }

  /**
   * Vendor Login via Email and Password
   */
  async vendorLogin(vendorLoginDto: VendorLoginDto) {
    const { email, password } = vendorLoginDto;

    const vendor = await this.vendorRepository.findOne({
      where: { email },
    });

    if (!vendor) {
      throw new UnauthorizedException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }

    const isPasswordValid = await bcrypt.compare(password, vendor.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }

    const token = this.generateToken(vendor, 'vendor');

    return {
      success: true,
      message: 'تم تسجيل الدخول بنجاح',
      data: {
        token,
        user: this.sanitizeVendor(vendor),
      },
    };
  }

  /**
   * Generate JWT token
   */
  private generateToken(entity: User | Vendor, role: string = 'user'): string {
    const payload = {
      sub: entity.id,
      phone: entity.phone,
      role: role,
      storeId: (entity as any).storeId,
    };

    return this.jwtService.sign(payload);
  }

  /**
   * Remove sensitive data from user object
   */
  private sanitizeUser(user: User) {
    const { passwordHash, ...sanitized } = user;
    return sanitized;
  }

  /**
   * Remove sensitive data from vendor object
   */
  private sanitizeVendor(vendor: Vendor) {
    const { passwordHash, ...sanitized } = vendor;
    return sanitized;
  }
}

