import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { Payment } from '../payments/entities/payment.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
  ) { }

  async findById(id: number): Promise<User> {
    // Use QueryBuilder to completely bypass TypeORM cache (both query cache and entity manager cache)
    // This ensures we ALWAYS get fresh data from database
    // Critical for fields updated by other services (e.g., freePostponeUsed)
    const user = await this.userRepository
      .createQueryBuilder('user')
      .where('user.id = :id', { id })
      .getOne();

    if (!user) {
      throw new NotFoundException('المستخدم غير موجود');
    }

    return user;
  }

  async findByPhone(phone: string): Promise<User | null> {
    const phoneWithPlus = phone.startsWith('+') ? phone : `+${phone}`;
    const phoneWithoutPlus = phone.startsWith('+') ? phone.substring(1) : phone;

    return this.userRepository.findOne({
      where: [
        { phone: phoneWithPlus },
        { phone: phoneWithoutPlus }
      ]
    });
  }

  async updateProfile(userId: number, updateData: Partial<User>): Promise<User> {
    const user = await this.findById(userId);
    Object.assign(user, updateData);
    return this.userRepository.save(user);
  }

  // Admin methods
  async findAll(filters?: {
    search?: string;
    status?: string;
    page?: number;
    limit?: number;
  }): Promise<{ users: User[]; total: number }> {
    const query = this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.payments', 'payments');

    // Search filter
    if (filters?.search) {
      query.andWhere(
        '(user.name LIKE :search OR user.phone LIKE :search OR user.email LIKE :search)',
        { search: `%${filters.search}%` }
      );
    }

    // Status filter
    if (filters?.status) {
      if (filters.status === 'نشط') {
        query.andWhere('user.isActive = :isActive', { isActive: true });
      } else if (filters.status === 'محظور') {
        query.andWhere('user.isActive = :isActive', { isActive: false });
      }
    }

    // Pagination
    const page = filters?.page || 1;
    const limit = filters?.limit || 10;
    const skip = (page - 1) * limit;

    const [users, total] = await query
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return { users, total };
  }

  async adminUpdateUser(id: number, updateData: Partial<User>): Promise<User> {
    const user = await this.findById(id);
    Object.assign(user, updateData);
    return this.userRepository.save(user);
  }

  async updateUserStatus(id: number, isActive: boolean): Promise<User> {
    const user = await this.findById(id);
    user.isActive = isActive;
    return this.userRepository.save(user);
  }

  async getStats(): Promise<any> {
    const totalUsers = await this.userRepository.count();
    const activeUsers = await this.userRepository.count({ where: { isActive: true } });
    const blockedUsers = await this.userRepository.count({ where: { isActive: false } });
    const verifiedUsers = await this.userRepository.count({ where: { isPhoneVerified: true } });

    // Get users registered this month
    const now = new Date();
    const firstDayOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const newUsersThisMonth = await this.userRepository
      .createQueryBuilder('user')
      .where('user.createdAt >= :firstDay', { firstDay: firstDayOfMonth })
      .getCount();

    // Calculate payment statistics
    // Get all payments
    const allPayments = await this.paymentRepository.find();

    // Calculate total delays (overdue payments)
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const totalDelays = allPayments.filter(p => {
      const dueDate = p.dueDate || p.postponedDueDate;
      return dueDate && new Date(dueDate) < today && p.status === 'pending';
    }).length;

    // Calculate average transaction value
    const completedPayments = allPayments.filter(p => p.status === 'completed');
    const avgTransactionValue = completedPayments.length > 0
      ? completedPayments.reduce((sum, p) => sum + parseFloat(p.amount.toString()), 0) / completedPayments.length
      : 0;

    // Calculate total credit used (sum of all pending and completed payments)
    const totalCreditUsed = allPayments
      .filter(p => p.status === 'pending' || p.status === 'completed')
      .reduce((sum, p) => sum + parseFloat(p.amount.toString()), 0);

    // For now, credit limit and credit score are not in the database
    // These would need to be added to the User entity or calculated based on other factors
    const avgCreditScore = 0; // TODO: Calculate based on payment history
    const totalCreditLimit = 0; // TODO: Sum of all user credit limits

    return {
      totalUsers,
      activeUsers,
      blockedUsers,
      verifiedUsers,
      newUsersThisMonth,
      avgCreditScore,
      totalCreditLimit,
      totalCreditUsed,
      totalDelays,
      avgTransactionValue,
    };
  }

  async createUser(data: any): Promise<User> {
    const bcrypt = require('bcrypt');
    const hashedPassword = await bcrypt.hash(data.password, 10);

    const user = this.userRepository.create({
      name: data.name,
      phone: data.phone,
      email: data.email,
      passwordHash: hashedPassword,
      civilIdNumber: data.civilIdNumber,
      address: data.address,
      monthlyIncome: data.monthlyIncome,
      employer: data.employer,
      isActive: true,
      isPhoneVerified: false,
      isEmailVerified: false,
      role: 'user',
    });

    return this.userRepository.save(user);
  }

  async findAllAdmins(): Promise<User[]> {
    return this.userRepository.find({
      where: { role: 'admin' },
    });
  }
}


