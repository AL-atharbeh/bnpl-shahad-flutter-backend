export class SessionResponseDto {
    success: boolean;
    session_id: string;
    redirect_url: string;
    web_redirect_url: string;
    expires_at: Date;
    message?: string;
}

export class SessionDetailsDto {
    session_id: string;
    store: {
        id: number;
        name: string;
        nameAr: string;
        logoUrl: string;
    };
    total_amount: number;
    currency: string;
    installments_count: number;
    items: any[];
    status: string;
    created_at: Date;
    expires_at: Date;
}
