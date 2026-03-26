import api from './api';

export interface Store {
    id: number;
    name: string;
    nameAr?: string;
    description?: string;
    logoUrl?: string;
    category?: string;
    categoryId?: number;
    isActive: boolean;
    topStore: boolean;
    rating: number;
    commissionRate: number;
    minOrderAmount: number;
    maxOrderAmount: number;
    websiteUrl?: string;
    storeUrl?: string;
    productsCount: number;
    createdAt: string;
    descriptionAr?: string;
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
    topProducts?: string[];
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
        const response = await api.get<{ success: boolean; data: Store[] }>('/stores/admin/all');
        return response.data;
    },

    getStats: async (): Promise<StoreStats | null> => {
        // Return null to force frontend calculation until backend API is ready
        return null;
    },

    toggleTopStore: async (id: number) => {
        const response = await api.put<{ success: boolean; data: Store }>(`/stores/${id}/top-store`);
        return response.data;
    },

    updateStatus: async (id: number, status: string) => {
        const response = await api.put<{ success: boolean; data: Store }>(`/stores/admin/${id}/status`, { status });
        return response.data;
    },

    createStore: async (data: Partial<Store>) => {
        const response = await api.post<{ success: boolean; data: Store }>('/stores', data);
        return response.data;
    },
};

