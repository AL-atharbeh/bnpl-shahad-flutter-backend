import api from './api';

export interface Store {
    id: number;
    legalName?: string;
    commercialRegistrationNo?: string;
    tradeLicenseNo?: string;
    city?: string;
    ownerNationalId?: string;
    bankName?: string;
    bankAccountHolder?: string;
    iban?: string;
    docCommercialRegistration?: string;
    docTradeLicense?: string;
    docOwnerId?: string;
    termsAcceptedAt?: string;
    termsVersion?: string;
    applicationSubmittedAt?: string;
    reviewNote?: string;
    name: string;
    nameAr?: string;
    description?: string;
    logoUrl?: string;
    category?: string;
    categoryId?: number;
    isActive: boolean;
    topStore: boolean;
    rating: number;
    commissionRate: number | null;
    bankCommissionRate?: number | null;
    platformCommissionRate?: number | null;
    minOrderAmount: number;
    maxOrderAmount: number;
    websiteUrl?: string;
    storeUrl?: string;
    productsCount: number;
    createdAt: string;
    descriptionAr?: string;
    vendorId?: number;
    // Additional fields for UI (might be computed or joined)
    location?: string;
    status?: string;
    totalSales?: string;
    customers?: number;
    avgOrder?: string;
    pendingPayouts?: string;
    contactPerson?: string;
    contactPhone?: string;
    contactEmail?: string;
    address?: string;
    riskLevel?: string;
    lastSettlement?: string;
    activationDate?: string;
    contractNumber?: string;
    complianceScore?: number;
    delayedOrders?: number;
    payoutCycle?: string;
    apiKey?: string;
    apiSecret?: string;
    topProducts?: string[];
}

export interface StoreReview {
    id: number;
    storeId: number;
    authorName: string;
    rating: number;
    comment: string;
    commentAr?: string;
    createdAt: string;
}

export interface Vendor {
    id: number;
    name: string;
    email: string;
    phone: string;
    storeId: number;
    isActive: boolean;
    createdAt: string;
    store?: {
        id: number;
        name: string;
        nameAr?: string;
        status?: string;
        isActive: boolean;
        applicationSubmittedAt?: string;
    } | null;
}

export interface StoreStats {
    totalStores: number;
    activeStores: number;
    highRiskStores: number;
    reviewStores: number;
    totalSalesValue: number;
    totalPendingPayouts: number;
}

export const storesService = {
    getAll: async () => {
        try {
            const response = await api.get<{ success: boolean; data: Store[] }>('/stores/admin/all');
            return response.data;
        } catch (error: any) {
            if (error.response?.status === 404) {
                console.warn("Admin endpoint 404, falling back to public stores endpoint during deployment...");
                const response = await api.get<{ success: boolean; data: Store[] }>('/stores');
                return response.data;
            }
            throw error;
        }
    },

    getStats: async (): Promise<StoreStats | null> => {
        return null;
    },

    toggleTopStore: async (id: number) => {
        const response = await api.put<{ success: boolean; data: Store }>(`/stores/${id}/top-store`);
        return response.data;
    },

    // A rejection or suspension carries a note the merchant sees in their app.
    updateStatus: async (id: number, status: string, note?: string) => {
        const response = await api.put<{ success: boolean; data: Store }>(`/stores/admin/${id}/status`, { status, note });
        return response.data;
    },

    // Merchant documents are private: fetched over the admin's session.
    getDocument: async (id: number, type: 'commercial-registration' | 'trade-license' | 'owner-id') => {
        const response = await api.get(`/stores/${id}/documents/${type}`, { responseType: 'blob' });
        return response.data as Blob;
    },

    createStore: async (data: Partial<Store>) => {
        const response = await api.post<{ success: boolean; data: Store }>('/stores', data);
        return response.data;
    },

    updateStore: async (id: number, data: Partial<Store>) => {
        const response = await api.put<{ success: boolean; data: Store }>(`/stores/${id}`, data);
        return response.data;
    },

    deleteStore: async (id: number) => {
        const response = await api.delete<{ success: boolean; message: string }>(`/stores/${id}`);
        return response.data;
    },

    getVendors: async () => {
        const response = await api.get<{ success: boolean; data: Vendor[] }>('/stores/admin/vendors');
        return response.data;
    },

    // A suspended merchant cannot sign in until restored.
    setVendorActive: async (id: number, isActive: boolean) => {
        const response = await api.put<{ success: boolean; data: Vendor }>(`/stores/admin/vendors/${id}/status`, { isActive });
        return response.data;
    },

    // Returns a one-time password the admin hands to the merchant.
    resetVendorPassword: async (id: number) => {
        const response = await api.post<{ success: boolean; data: { id: number; temporaryPassword: string } }>(`/stores/admin/vendors/${id}/reset-password`);
        return response.data;
    },

    // Review Methods
    getStoreReviews: async (storeId: number) => {
        const response = await api.get<{ success: boolean; data: StoreReview[] }>(`/reviews/store/${storeId}`);
        return response.data;
    },

    createReview: async (data: Partial<StoreReview>) => {
        const response = await api.post<{ success: boolean; data: StoreReview }>('/reviews', data);
        return response.data;
    },

    deleteReview: async (id: number) => {
        const response = await api.delete<{ success: boolean; message: string }>(`/reviews/${id}`);
        return response.data;
    },
};

