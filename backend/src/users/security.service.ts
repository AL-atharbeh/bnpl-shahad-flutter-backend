import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { randomBytes } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { UserSecuritySetting } from './entities/user-security-setting.entity';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { Payment } from '../payments/entities/payment.entity';

@Injectable()
export class SecurityService {
  constructor(
    @InjectRepository(UserSecuritySetting)
    private securityRepository: Repository<UserSecuritySetting>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    private usersService: UsersService,
  ) {}

  /**
   * Get or create security settings for user
   */
  async getSecuritySettings(userId: number): Promise<UserSecuritySetting> {
    let settings = await this.securityRepository.findOne({
      where: { userId },
      relations: ['user'],
    });

    if (!settings) {
      // Create default settings
      settings = this.securityRepository.create({
        userId,
        pinEnabled: false,
        biometricEnabled: false,
      });
      settings = await this.securityRepository.save(settings);
    }

    return settings;
  }

  /**
   * Set PIN code (4 digits)
   */
  async setPin(userId: number, pin: string): Promise<UserSecuritySetting> {
    // Trim and validate PIN - must be exactly 4 digits
    const trimmedPin = pin?.trim();
    
    if (!trimmedPin || trimmedPin.length !== 4 || !/^\d{4}$/.test(trimmedPin)) {
      throw new BadRequestException('رقم التعريف يجب أن يكون 4 أرقام بالضبط');
    }

    // Ensure PIN is exactly 4 digits (no more, no less)
    if (trimmedPin.length !== 4) {
      throw new BadRequestException('رقم التعريف يجب أن يكون 4 أرقام بالضبط');
    }

    let settings = await this.securityRepository.findOne({
      where: { userId },
    });

    if (!settings) {
      settings = this.securityRepository.create({
        userId,
        pin: trimmedPin, // Save PIN as plain text (exactly 4 digits, no spaces)
        pinEnabled: true,
      });
    } else {
      settings.pin = trimmedPin; // Save PIN as plain text (exactly 4 digits, no spaces)
      settings.pinEnabled = true;
    }

    console.log(`[SecurityService] Saving PIN for user ${userId}: "${trimmedPin}"`);
    const saved = await this.securityRepository.save(settings);
    console.log(`[SecurityService] PIN saved: "${saved.pin}" (length: ${saved.pin?.length})`);
    
    return saved;
  }

  /**
   * Verify PIN code
   */
  async verifyPin(userId: number, pin: string): Promise<boolean> {
    // Trim and validate PIN input
    const trimmedPin = pin?.trim();
    
    console.log(`[SecurityService] Verifying PIN for user ${userId}`);
    console.log(`[SecurityService] Input PIN: "${pin}" (length: ${pin?.length})`);
    console.log(`[SecurityService] Trimmed PIN: "${trimmedPin}" (length: ${trimmedPin?.length})`);
    
    if (!trimmedPin || trimmedPin.length !== 4 || !/^\d{4}$/.test(trimmedPin)) {
      console.log(`[SecurityService] PIN validation failed: invalid format`);
      return false;
    }

    const settings = await this.securityRepository.findOne({
      where: { userId },
    });

    if (!settings) {
      console.log(`[SecurityService] No security settings found for user ${userId}`);
      return false;
    }

    if (!settings.pin) {
      console.log(`[SecurityService] No PIN set for user ${userId}`);
      return false;
    }

    if (!settings.pinEnabled) {
      console.log(`[SecurityService] PIN is not enabled for user ${userId}`);
      return false;
    }

    // Trim stored PIN as well (in case it has spaces)
    const storedPin = settings.pin.trim();
    
    console.log(`[SecurityService] Stored PIN: "${settings.pin}" (length: ${settings.pin.length})`);
    console.log(`[SecurityService] Stored PIN (trimmed): "${storedPin}" (length: ${storedPin.length})`);
    console.log(`[SecurityService] Comparison: "${trimmedPin}" === "${storedPin}" = ${trimmedPin === storedPin}`);

    // Compare PIN directly (plain text) - both must be exactly 4 digits
    const isValid = storedPin === trimmedPin;
    console.log(`[SecurityService] PIN verification result: ${isValid}`);
    
    return isValid;
  }

  /**
   * Disable PIN
   */
  async disablePin(userId: number): Promise<UserSecuritySetting> {
    const settings = await this.getSecuritySettings(userId);
    settings.pinEnabled = false;
    settings.pin = null;
    return this.securityRepository.save(settings);
  }

  /**
   * Enable biometric authentication
   */
  async enableBiometric(userId: number): Promise<UserSecuritySetting> {
    const settings = await this.getSecuritySettings(userId);
    
    // Check if PIN is enabled (biometric requires PIN as backup)
    if (!settings.pinEnabled) {
      throw new BadRequestException('يجب تفعيل رقم التعريف أولاً قبل تفعيل البصمة');
    }

    settings.biometricEnabled = true;
    return this.securityRepository.save(settings);
  }

  /**
   * Disable biometric authentication
   */
  async disableBiometric(userId: number): Promise<UserSecuritySetting> {
    const settings = await this.getSecuritySettings(userId);
    settings.biometricEnabled = false;
    return this.securityRepository.save(settings);
  }

  /**
   * What the person still owes, if anything.
   *
   * Only pending instalments count. A settled payment is history, not a debt,
   * and the old check counted those too, which is why an account that had
   * paid everything off could never be deleted.
   *
   * The status comparison is case-insensitive because Postgres stores the
   * value as it was written and older rows are not consistent about it.
   */
  async getOutstanding(userId: number): Promise<{ count: number; amount: number }> {
    const row = await this.paymentRepository
      .createQueryBuilder('payment')
      .select('COUNT(*)', 'count')
      .addSelect('COALESCE(SUM(payment.amount), 0)', 'amount')
      .where('payment.user_id = :userId', { userId })
      .andWhere('LOWER(payment.status) = :status', { status: 'pending' })
      .getRawOne<{ count: string; amount: string }>();

    return {
      count: Number(row?.count ?? 0),
      amount: Number(row?.amount ?? 0),
    };
  }

  /**
   * Kept for callers that only need the yes/no.
   */
  async hasPayments(userId: number): Promise<boolean> {
    const { count } = await this.getOutstanding(userId);
    return count > 0;
  }

  /**
   * Removes the person from the system.
   *
   * The row itself stays, because every payment hangs off it and deleting it
   * would take the accounting record with it. What goes is the person: each
   * field that identifies them is overwritten, the password is replaced with
   * a value nobody holds, and the account can no longer be signed into.
   *
   * One exception. While money is still owed, the name, phone and civil ID
   * are kept, because the debt cannot be collected without them. Everything
   * else goes either way: the ID photographs, the income, the address, the
   * avatar, the push token, the Firebase link. The confirmation screen tells
   * the person this before they commit, and the privacy policy repeats it.
   *
   * Deletion is never refused. An outstanding balance changes what is kept,
   * not whether the account can go.
   */
  async deleteAccount(userId: number): Promise<void> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('المستخدم غير موجود');
    }

    const { count } = await this.getOutstanding(userId);

    await this.securityRepository.delete({ userId });

    const scrubbed: Partial<User> = {
      email: null,
      passwordHash: randomBytes(32).toString('hex'),
      civilIdFront: null,
      civilIdBack: null,
      dateOfBirth: null,
      address: null,
      monthlyIncome: null,
      employer: null,
      avatarUrl: null,
      otp: null,
      fcmToken: null,
      stripeCustomerId: null,
      firebaseUid: null,
      isPhoneVerified: false,
      isEmailVerified: false,
      isActive: false,
    };

    if (count === 0) {
      scrubbed.name = 'حساب محذوف';
      // phone is unique, so it needs a value no real number can collide with
      scrubbed.phone = `deleted-${userId}`;
      scrubbed.civilIdNumber = null;
    }

    await this.userRepository.update(userId, scrubbed);
  }
}
