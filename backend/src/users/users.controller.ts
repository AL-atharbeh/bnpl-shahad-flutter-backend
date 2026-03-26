import { Controller, Get, Put, Post, Body, UseGuards, Request, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('users')
@Controller('users')
// @UseGuards(JwtAuthGuard) // Removed global guard - will apply to specific endpoints
// @ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) { }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  async getMyProfile(@Request() req) {
    const user = await this.usersService.findById(req.user.id);
    const { passwordHash, ...sanitizedUser } = user;
    return {
      success: true,
      data: { user: sanitizedUser },
    };
  }

  @Put('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user profile' })
  async updateProfile(@Request() req, @Body() updateData: any) {
    const user = await this.usersService.updateProfile(req.user.id, updateData);
    const { passwordHash, ...sanitizedUser } = user;
    return {
      success: true,
      message: 'تم تحديث الملف الشخصي بنجاح',
      data: { user: sanitizedUser },
    };
  }

  // Admin endpoints (should be protected with AdminGuard in production)
  @Get()
  @ApiOperation({ summary: 'Get all users (Admin)' })
  async getAllUsers(
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const { users, total } = await this.usersService.findAll({
      search,
      status,
      page: page ? parseInt(page) : undefined,
      limit: limit ? parseInt(limit) : undefined,
    });

    const sanitizedUsers = users.map(user => {
      const { passwordHash, ...sanitizedUser } = user;
      return sanitizedUser;
    });

    return {
      success: true,
      data: {
        users: sanitizedUsers,
        total,
        page: page ? parseInt(page) : 1,
        limit: limit ? parseInt(limit) : 10,
      },
    };
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get users statistics (Admin)' })
  async getStats() {
    const stats = await this.usersService.getStats();
    return {
      success: true,
      data: stats,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID (Admin)' })
  async getUserById(@Param('id') id: string) {
    const user = await this.usersService.findById(parseInt(id));
    const { passwordHash, ...sanitizedUser } = user;
    return {
      success: true,
      data: { user: sanitizedUser },
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update user (Admin)' })
  async updateUser(@Param('id') id: string, @Body() updateData: any) {
    const user = await this.usersService.adminUpdateUser(parseInt(id), updateData);
    const { passwordHash, ...sanitizedUser } = user;
    return {
      success: true,
      message: 'تم تحديث المستخدم بنجاح',
      data: { user: sanitizedUser },
    };
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Update user status (Admin)' })
  async updateUserStatus(
    @Param('id') id: string,
    @Body('isActive') isActive: boolean,
  ) {
    const user = await this.usersService.updateUserStatus(parseInt(id), isActive);
    const { passwordHash, ...sanitizedUser } = user;
    return {
      success: true,
      message: isActive ? 'تم تفعيل المستخدم' : 'تم حظر المستخدم',
      data: { user: sanitizedUser },
    };
  }

  @Post()
  @ApiOperation({ summary: 'Create new user (Admin)' })
  async createUser(@Body() createData: any) {
    const user = await this.usersService.createUser(createData);
    const { passwordHash, ...sanitizedUser } = user;
    return {
      success: true,
      message: 'تم إضافة المستخدم بنجاح',
      data: { user: sanitizedUser },
    };
  }

  @Put('fcm-token')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update FCM token for push notifications' })
  async updateFcmToken(@Request() req, @Body('token') token: string) {
    await this.usersService.updateProfile(req.user.id, {
      fcmToken: token,
    });
    return {
      success: true,
      message: 'تم تحديث رمز الإشعارات بنجاح',
    };
  }

  @Get('find-by-phone')
  @ApiOperation({ summary: 'Find user by phone (for POS)' })
  async findByPhone(@Query('phone') phone: string) {
    const user = await this.usersService.findByPhone(phone);
    if (!user) {
      return {
        success: false,
        message: 'المستخدم غير موجود',
      };
    }
    return {
      success: true,
      data: {
        id: user.id,
        name: user.name,
        isVerified: user.isPhoneVerified,
      },
    };
  }
}


