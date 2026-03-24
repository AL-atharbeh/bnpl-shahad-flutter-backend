import api from './api';

export interface Deal {
    id: number;
    storeId: number;
    productId: number;
    title: string;
    titleAr?: string;
    description?: string;
    descriptionAr?: string;
    discountLabel?: string;
    discountValue?: string;
    imageUrl?: string;
    storeUrl?: string;
    badgeColor?: string;
    accentColor?: string;
    startDate?: string;
    endDate?: string;
    isActive: boolean;
    showInHome: boolean;
    sortOrder: number;
    createdAt: string;
    updatedAt: string;
    store: {
        id: number;
        name: string;
        nameAr: string;
        logoUrl: string;
        category?: string; // These might not be in the API response directly depending on backend
        categoryAr?: string;
    };
    product?: {
        id: number;
        name: string;
        nameAr: string;
        price: string;
    };
    // Stats are not in the main deal entity, might need separate endpoint or computed
    views?: number;
    clicks?: number;
    conversions?: number;
}

export interface CreateDealDto {
    storeId: number;
    productId: number;
    title: string;
    titleAr?: string;
    description?: string;
    descriptionAr?: string;
    discountLabel?: string;
    discountValue?: string;
    imageUrl?: string;
    badgeColor?: string;
    accentColor?: string;
    startDate?: Date;
    endDate?: Date;
    isActive?: boolean;
    showInHome?: boolean;
    sortOrder?: number;
}

export interface UpdateDealDto extends Partial<CreateDealDto> { }

export const dealsService = {
    getAll: async (params?: {
        isActive?: boolean;
        storeId?: number;
        productId?: number;
        includeExpired?: boolean;
    }) => {
        const response = await api.get<{ success: boolean; data: Deal[] }>('/deals', { params });
        return response.data;
    },

    getOne: async (id: number) => {
        const response = await api.get<{ success: boolean; data: Deal }>(`/deals/${id}`);
        return response.data;
    },

    create: async (data: CreateDealDto) => {
        const response = await api.post<{ success: boolean; data: Deal }>('/deals', data);
        return response.data;
    },

    update: async (id: number, data: UpdateDealDto) => {
        const response = await api.put<{ success: boolean; data: Deal }>(`/deals/${id}`, data);
        return response.data;
    },

    delete: async (id: number) => {
        const response = await api.delete<{ success: boolean }>(`/deals/${id}`);
        return response.data;
    },
};
