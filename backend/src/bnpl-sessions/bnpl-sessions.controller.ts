import {
    Controller,
    Post,
    Get,
    Body,
    Param,
    UseGuards,
    Request,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { BnplSessionsService } from './bnpl-sessions.service';
import { CreateSessionDto } from './dto/create-session.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('sessions')
export class BnplSessionsController {
    constructor(private readonly sessionsService: BnplSessionsService) { }

    @Post('create')
    @HttpCode(HttpStatus.CREATED)
    async createSession(
        @Body() createSessionDto: CreateSessionDto,
    ) {
        return this.sessionsService.createSession(createSessionDto);
    }

    @Get('store/:storeId/recent')
    async getRecentStoreSessions(@Param('storeId') storeId: string) {
        return this.sessionsService.getRecentSessionsByStoreId(parseInt(storeId));
    }

    @Get(':sessionId')
    async getSession(@Param('sessionId') sessionId: string) {
        return this.sessionsService.getSession(sessionId);
    }

    @Post(':sessionId/verify-otp')
    @HttpCode(HttpStatus.OK)
    async verifyOtp(
        @Param('sessionId') sessionId: string,
        @Body('otp') otp: string,
    ) {
        return this.sessionsService.verifyOtp(sessionId, otp);
    }

    @Post(':sessionId/approve')
    @UseGuards(JwtAuthGuard)
    async approveSession(
        @Param('sessionId') sessionId: string,
        @Request() req,
    ) {
        // JWT payload has 'sub' field for userId
        const userId = req.user.sub || req.user.userId || req.user.id;
        console.log('Approve session - User from JWT:', req.user);
        console.log('Approve session - Extracted userId:', userId);
        return this.sessionsService.approveSession(sessionId, userId);
    }

    @Post(':sessionId/complete')
    @UseGuards(JwtAuthGuard)
    async completeSession(@Param('sessionId') sessionId: string) {
        return this.sessionsService.completeSession(sessionId);
    }

    @Post(':sessionId/reject')
    async rejectSession(@Param('sessionId') sessionId: string) {
        return this.sessionsService.rejectSession(sessionId);
    }

    // Admin endpoints
    @Get('admin/stats')
    async getAdminStats() {
        return this.sessionsService.getAdminStats();
    }

    @Get('admin/all')
    async getAllSessions(
        @Request() req,
    ) {
        const { page = 1, limit = 10, status, storeId, userId, startDate, endDate } = req.query;
        return this.sessionsService.getAllSessionsForAdmin({
            page: parseInt(page),
            limit: parseInt(limit),
            status,
            storeId: storeId ? parseInt(storeId) : undefined,
            userId: userId ? parseInt(userId) : undefined,
            startDate,
            endDate,
        });
    }

    @Get('admin/chart-data')
    async getChartData() {
        return this.sessionsService.getChartData();
    }
}
