import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BnplSession, SessionStatus } from '../bnpl-sessions/entities/bnpl-session.entity';

export interface PrepareSessionDto {
    sessionId: string;
    userId: number;
}

@Injectable()
export class SessionPreparationService {
    constructor(
        @InjectRepository(BnplSession)
        private sessionRepository: Repository<BnplSession>,
    ) { }

    /**
     * Prepare session for payment (add userId without approving)
     */
    async prepareSession(sessionId: string, userId: number): Promise<BnplSession> {
        const session = await this.sessionRepository.findOne({
            where: { sessionId },
        });

        if (!session) {
            throw new NotFoundException('الجلسة غير موجودة');
        }

        if (session.status !== SessionStatus.PENDING) {
            throw new BadRequestException('لا يمكن تجهيز هذه الجلسة');
        }

        // Add userId to session (but don't approve yet)
        session.userId = userId;
        await this.sessionRepository.save(session);

        console.log(`✅ Session ${sessionId} prepared for user ${userId}`);
        return session;
    }
}
