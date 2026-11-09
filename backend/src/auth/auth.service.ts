import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as admin from 'firebase-admin';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import * as bcrypt from 'bcrypt';
import { Store } from '../stores/entities/store.entity';
import { User } from '../users/entities/user.entity';
import { Vendor } from '../vendors/entities/vendor.entity';
import { OtpService } from './otp.service';
import { UsersService } from '../users/users.service';
import { NotificationsService } from '../notifications/notifications.service';
import { TERMS_VERSION, applicationMissing } from '../stores/merchant-application';
import { CheckPhoneDto } from './dto/check-phone.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { CreateAccountDto } from './dto/create-account.dto';
import { AdminLoginDto } from './dto/admin-login.dto';
import { VendorRegisterDto } from './dto/vendor-register.dto';
import { VendorLoginDto } from './dto/vendor-login.dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Store)
    private storeRepository: Repository<Store>,
    @InjectRepository(Vendor)
    private vendorRepository: Repository<Vendor>,
    private jwtService: JwtService,
    private otpService: OtpService,
    private usersService: UsersService,
    private notificationsService: NotificationsService,
  ) { }

  /**
   * Normalize Jordanian phone numbers to +962XXXXXXXXX
   */
  private normalizePhone(phone: string): string {
    if (!phone) return phone;
    let clean = phone.trim();
    // Remove any spaces or dashes
    clean = clean.replace(/[\s-]/g, '');

    if (clean.startsWith('+9620')) {
      clean = '+962' + clean.substring(5);
    } else if (clean.startsWith('9620')) {
      clean = '+962' + clean.substring(4);
    } else if (clean.startsWith('009620')) {
      clean = '+962' + clean.substring(6);
    } else if (clean.startsWith('00962')) {
      clean = '+962' + clean.substring(5);
    } else if (clean.startsWith('962')) {
      clean = '+962' + clean.substring(3);
    } else if (clean.startsWith('07')) {
      clean = '+962' + clean.substring(1);
    } else if (clean.startsWith('7') && clean.length === 9) {
      clean = '+962' + clean;
    }
    return clean;
  }

  /**
   * Check if phone number exists in database
   */
  async checkPhone(checkPhoneDto: CheckPhoneDto) {
    const phone = this.normalizePhone(checkPhoneDto.phone);
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
        requiresOtp: false,
        requiresRegistration: true,
      },
    };
  }

  /**
   * Send OTP to phone
   */
  async sendOtp(sendOtpDto: SendOtpDto) {
    const phone = this.normalizePhone(sendOtpDto.phone);
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
    const phone = this.normalizePhone(verifyOtpDto.phone);
    const { code } = verifyOtpDto;

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
    const phone = this.normalizePhone(createAccountDto.phone);
    const { fullName, civilIdNumber, email, ...profileData } =
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

    // Verify that phone number was verified via OTP (only for existing incomplete users)
    if (existingUser) {
      if (!existingUser.isPhoneVerified) {
        throw new BadRequestException('يجب التحقق من رقم الهاتف أولاً عبر OTP');
      }
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
        isPhoneVerified: true, // Auto-verified upon successful registration
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
   * Vendors live in their own table with their own id sequence, so a vendor
   * token must never be resolved against the users table: vendor 1 and user 1
   * are different accounts.
   */
  async validateVendorById(vendorId: number): Promise<Vendor> {
    const vendor = await this.vendorRepository.findOne({
      where: { id: vendorId, isActive: true },
    });

    if (!vendor) {
      throw new UnauthorizedException('التاجر غير موجود أو غير نشط');
    }

    return vendor;
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

    try {
      // 1. Create the store. It waits for an admin: no sales, no API keys and
      // no listing in the customer app until it is approved, which is also
      // when updateStoreStatus issues its keys.
      const store = this.storeRepository.create({
        name: storeName,
        nameAr: storeName,
        isActive: false,
        status: 'pending',
        commissionRate: 2.5,
        bankCommissionRate: 1.5,
        platformCommissionRate: 1.0,
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

      const savedVendor = await this.vendorRepository.save(vendor);

      // 3. Link vendor back to store
      savedStore.vendorId = savedVendor.id;
      await this.storeRepository.save(savedStore);

      await this.notifyAdminsOfNewStore(savedStore, name);

      const token = this.generateToken(savedVendor, 'vendor');

      return {
        success: true,
        message: 'تم إنشاء الحساب، ومتجرك الآن قيد مراجعة الإدارة',
        data: {
          token,
          user: this.sanitizeVendor(savedVendor),
        },
      };
    } catch (error) {
      console.error('Vendor registration error:', error);
      throw new BadRequestException(
        `فشل إنشاء حساب المورد: ${error.message || 'خطأ غير معروف'}`,
      );
    }
  }

  /** The vendor edits their own name, email or phone; both must stay unique. */
  async updateVendorProfile(vendorId: number, dto: { name?: string; email?: string; phone?: string }) {
    const vendor = await this.validateVendorById(vendorId);
    const email = dto.email?.trim();
    const phone = dto.phone?.replace(/[\s-]/g, '');
    if (phone !== undefined && !/^\+?\d{9,15}$/.test(phone)) {
      throw new BadRequestException('رقم الهاتف غير صحيح');
    }

    const clash = [
      email && email !== vendor.email ? { email } : null,
      phone && phone !== vendor.phone ? { phone } : null,
    ].filter(Boolean);
    if (clash.length) {
      const taken = await this.vendorRepository.findOne({ where: clash as any[] });
      if (taken && taken.id !== vendor.id) {
        throw new ConflictException(
          taken.phone === phone ? 'رقم الهاتف مستخدم لحساب تاجر آخر' : 'البريد الإلكتروني مستخدم لحساب تاجر آخر',
        );
      }
    }

    if (dto.name !== undefined) vendor.name = dto.name.trim();
    if (email) vendor.email = email;
    if (phone) vendor.phone = phone;
    const saved = await this.vendorRepository.save(vendor);
    return { success: true, message: 'تم حفظ بياناتك', data: this.sanitizeVendor(saved) };
  }

  /** Needs the current password, so a session left open cannot lock the owner out. */
  async changeVendorPassword(vendorId: number, currentPassword: string, newPassword: string) {
    const vendor = await this.validateVendorById(vendorId);
    if (!(await bcrypt.compare(currentPassword, vendor.passwordHash))) {
      throw new BadRequestException('كلمة المرور الحالية غير صحيحة');
    }
    if (currentPassword === newPassword) {
      throw new BadRequestException('اختر كلمة مرور مختلفة عن الحالية');
    }
    vendor.passwordHash = await bcrypt.hash(newPassword, 10);
    await this.vendorRepository.save(vendor);
    return { success: true, message: 'تم تغيير كلمة المرور' };
  }

  /**
   * The merchant closes their account from the app or website (the stores
   * require this). Sign-in stops at once: the name, email and phone are
   * replaced so they can be used again, the store leaves the customer app and
   * its API keys stop working. Sales and settlements stay, as the law requires
   * for financial records.
   */
  async deleteVendorAccount(vendorId: number, password: string) {
    const vendor = await this.validateVendorById(vendorId);
    if (!(await bcrypt.compare(password || '', vendor.passwordHash))) {
      throw new BadRequestException('كلمة المرور غير صحيحة');
    }

    const formerName = vendor.name;
    vendor.isActive = false;
    vendor.name = 'حساب محذوف';
    vendor.email = `deleted-${vendor.id}-${Date.now()}@deleted.shahedapp.com`;
    vendor.phone = `deleted-${vendor.id}`.slice(0, 20);
    vendor.passwordHash = await bcrypt.hash(uuidv4() + uuidv4(), 10);
    await this.vendorRepository.save(vendor);

    const store = vendor.storeId
      ? await this.storeRepository.findOne({ where: { id: vendor.storeId } })
      : null;
    const othersActive = store
      ? await this.vendorRepository.count({ where: { storeId: store.id, isActive: true } })
      : 0;
    if (store && othersActive === 0) {
      store.isActive = false;
      store.apiKey = null as any;
      store.apiSecret = null as any;
      // Off the admin's waiting list too.
      store.status = store.status === 'approved' ? 'suspended' : 'rejected';
      store.reviewNote = 'أغلق التاجر حسابه';
      await this.storeRepository.save(store);
    }

    try {
      const admins = await this.usersService.findAllAdmins();
      for (const admin of admins) {
        await this.notificationsService.sendToUser(
          admin.id,
          'تاجر أغلق حسابه',
          `${formerName} أغلق حسابه${store ? ` ومتجر «${store.nameAr || store.name}» لم يعد ظاهراً` : ''}`,
          { type: 'vendor_account_deleted', storeId: String(store?.id ?? ''), vendorId: String(vendor.id) },
          'normal',
        );
      }
    } catch (err) {
      this.logger.warn(`Could not notify admins of deleted vendor ${vendor.id}: ${err.message}`);
    }

    return { success: true, message: 'تم حذف حسابك' };
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

    // Checked after the password, so a wrong guess learns nothing about the
    // account. A store still under review may sign in to see its status; a
    // suspended account may not.
    if (!vendor.isActive) {
      throw new ForbiddenException('تم إيقاف هذا الحساب. تواصل مع إدارة شهد.');
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
   * Login to the admin dashboard with email and password. Only users whose
   * role is 'admin' are accepted; everyone else gets the same generic error so
   * the response cannot be used to discover which emails exist.
   */
  async adminLogin(adminLoginDto: AdminLoginDto) {
    const { email, password } = adminLoginDto;
    const invalid = new UnauthorizedException(
      'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    );

    const user = await this.userRepository.findOne({ where: { email } });

    if (!user || !user.passwordHash) {
      throw invalid;
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      throw invalid;
    }

    if (user.role !== 'admin') {
      throw invalid;
    }

    if (user.isActive === false) {
      throw new UnauthorizedException('هذا الحساب معطّل');
    }

    return {
      success: true,
      message: 'تم تسجيل الدخول بنجاح',
      data: {
        token: this.generateToken(user, 'admin'),
        user: this.sanitizeUser(user),
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
  /**
   * The signed-in vendor's account and store review state, so the apps know
   * whether to open the dashboard or the "under review" screen.
   */
  async getVendorAccount(vendorId: number) {
    const vendor = await this.validateVendorById(vendorId);
    const store = await this.storeRepository.findOne({ where: { id: vendor.storeId } });
    if (!store) {
      throw new NotFoundException('المتجر غير موجود');
    }
    return {
      success: true,
      data: {
        user: this.sanitizeVendor(vendor),
        store: {
          id: store.id,
          name: store.name,
          nameAr: store.nameAr,
          status: store.status,
          isActive: store.isActive,
        },
        application: {
          submittedAt: store.applicationSubmittedAt,
          missing: applicationMissing(store),
          reviewNote: store.reviewNote,
          termsVersion: TERMS_VERSION,
        },
      },
    };
  }

  /** Tells every admin a store is waiting. A failure here must not undo the sign-up. */
  private async notifyAdminsOfNewStore(store: Store, vendorName: string) {
    try {
      const admins = await this.usersService.findAllAdmins();
      for (const admin of admins) {
        await this.notificationsService.sendToUser(
          admin.id,
          'طلب انضمام تاجر جديد',
          `${vendorName} سجّل متجر «${store.nameAr || store.name}» وينتظر المراجعة`,
          { type: 'new_store_request', storeId: String(store.id), storeName: store.name },
          'urgent',
        );
      }
    } catch (err) {
      this.logger.warn(`Could not notify admins of store ${store.id}: ${err.message}`);
    }
  }

  private sanitizeVendor(vendor: Vendor) {
    const { passwordHash, ...sanitized } = vendor;
    return sanitized;
  }

  /**
   * Private helper to generate API credentials for new stores
   */
  private generateApiCredentials(): { apiKey: string; apiSecret: string } {
    const apiKey = `sh_pk_${uuidv4().replace(/-/g, '').substring(0, 24)}`;
    const apiSecret = `sh_sk_${uuidv4().replace(/-/g, '')}${uuidv4().replace(/-/g, '')}`;
    return { apiKey, apiSecret };
  }

  /**
   * Verify Firebase ID Token and sign in / create incomplete user
   */
  async verifyFirebaseToken(firebaseToken: string) {
    try {
      // Ensure Firebase admin is initialized before verifying the token
      if (admin.apps.length === 0) {
        const projectId = process.env.FIREBASE_PROJECT_ID;
        const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
        let privateKey = process.env.FIREBASE_PRIVATE_KEY;
        if (privateKey) {
          // Remove surrounding quotes if present
          privateKey = privateKey.replace(/^["']|["']$/g, '');
          // Replace all forms of escaped newlines with actual newlines
          privateKey = privateKey.replace(/\\\\n/g, '\n');
          privateKey = privateKey.replace(/\\n/g, '\n');
          privateKey = privateKey.trim();
        }

        if (projectId && clientEmail && privateKey) {
          admin.initializeApp({
            credential: admin.credential.cert({
              projectId,
              privateKey,
              clientEmail,
            }),
          });
        } else {
          throw new UnauthorizedException('إعدادات Firebase غير مكتملة في السيرفر');
        }
      }

      const decodedToken = await admin.auth().verifyIdToken(firebaseToken);
      const phone = this.normalizePhone(decodedToken.phone_number);
      const firebaseUid = decodedToken.uid;

      if (!phone) {
        throw new BadRequestException('رقم الهاتف غير موجود في رمز تحقق Firebase');
      }

      // Check if user already exists
      let user = await this.userRepository.findOne({ where: { phone } });

      if (!user) {
        // Create incomplete user
        // Generate temporary password
        const tempPassword = Math.random().toString(36).slice(-10);
        const passwordHash = await bcrypt.hash(tempPassword, 10);

        user = this.userRepository.create({
          name: '',
          phone,
          passwordHash,
          firebaseUid,
          isPhoneVerified: true,
          isActive: true,
          role: 'user',
        });
        await this.userRepository.save(user);
      } else {
        // Update firebaseUid and isPhoneVerified if not set
        let needsSave = false;
        if (!user.firebaseUid) {
          user.firebaseUid = firebaseUid;
          needsSave = true;
        }
        if (!user.isPhoneVerified) {
          user.isPhoneVerified = true;
          needsSave = true;
        }
        if (needsSave) {
          await this.userRepository.save(user);
        }
      }

      // Check if user profile is complete (has name)
      const userExists = !!(user.name && user.name.trim() !== '');
      const token = this.generateToken(user);

      return {
        success: true,
        message: 'تم التحقق من رمز Firebase بنجاح',
        data: {
          userExists,
          token,
          user: this.sanitizeUser(user),
          requiresProfileCompletion: !userExists,
        },
      };
    } catch (error) {
      throw new UnauthorizedException('فشل التحقق من رمز Firebase: ' + error.message);
    }
  }
}

