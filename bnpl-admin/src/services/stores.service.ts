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
    bankCommissionRate?: number;
    platformCommissionRate?: number;
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

export interface Vendor {
    id: number;
    name: string;
    email: string;
    phone: string;
    storeId: number;
    isActive: boolean;
    createdAt: string;
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

    updateStatus: async (id: number, status: string) => {
        const response = await api.put<{ success: boolean; data: Store }>(`/stores/admin/${id}/status`, { status });
        return response.data;
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
};

