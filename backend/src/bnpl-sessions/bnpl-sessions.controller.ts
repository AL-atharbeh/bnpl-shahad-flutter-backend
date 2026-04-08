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
    Headers,
    Res,
} from '@nestjs/common';
import { Response } from 'express';
import { BnplSessionsService } from './bnpl-sessions.service';
import * as fs from 'fs';
import * as path from 'path';
import { CreateSessionDto } from './dto/create-session.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Request as ExpressRequest } from 'express';

@Controller('sessions')
export class BnplSessionsController {
    constructor(private readonly sessionsService: BnplSessionsService) { }

    @Post('create')
    @HttpCode(HttpStatus.CREATED)
    async createSession(
        @Body() createSessionDto: CreateSessionDto,
        @Headers('x-api-key') apiKey: string,
    ) {
        return this.sessionsService.createSession(createSessionDto, apiKey);
    }

    @Get('store/:storeId/recent')
    async getRecentStoreSessions(@Param('storeId') storeId: string) {
        return this.sessionsService.getRecentSessionsByStoreId(parseInt(storeId));
    }

    @Get('view/:sessionId')
    async getSessionView(@Param('sessionId') sessionId: string, @Res() res: Response) {
        const viewPath = path.join(__dirname, 'views', 'session-approval.html');
        // Check if file exists, if not try parent dir (depending on build structure)
        let htmlContent = '';
        if (fs.existsSync(viewPath)) {
            htmlContent = fs.readFileSync(viewPath, 'utf8');
        } else {
            const fallbackPath = path.join(process.cwd(), 'src', 'bnpl-sessions', 'views', 'session-approval.html');
            if (fs.existsSync(fallbackPath)) {
                htmlContent = fs.readFileSync(fallbackPath, 'utf8');
            } else {
                return res.status(404).send('Approval page not found');
            }
        }
        res.setHeader('Content-Type', 'text/html');
        return res.send(htmlContent);
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
