import api from './api';

export interface User {
    id: number;
    name: string;
    phone: string;
    email: string | null;
    civilIdNumber: string | null;
    address: string | null;
    monthlyIncome: number | null;
    employer: string | null;
    isActive: boolean;
    isPhoneVerified: boolean;
    isEmailVerified: boolean;
    role: string;
    createdAt: string;
    updatedAt: string;
    // Relations
    payments?: any[];
}

export interface UserStats {
    totalUsers: number;
    activeUsers: number;
    blockedUsers: number;
    verifiedUsers: number;
    newUsersThisMonth: number;
}

export interface UpdateUserDto {
    name?: string;
    email?: string;
    phone?: string;
    address?: string;
    monthlyIncome?: number;
    employer?: string;
    isActive?: boolean;
    role?: string;
}

export const usersService = {
    getAll: async (params?: {
        search?: string;
        status?: string;
        page?: number;
        limit?: number;
    }) => {
        const response = await api.get<{
            success: boolean;
            data: { users: User[]; total: number; page: number; limit: number };
        }>('/users', { params });
        return response.data;
    },

    getOne: async (id: number) => {
        const response = await api.get<{ success: boolean; data: { user: User } }>(
            `/users/${id}`
        );
        return response.data;
    },

    update: async (id: number, data: UpdateUserDto) => {
        const response = await api.put<{
            success: boolean;
            message: string;
            data: { user: User };
        }>(`/users/${id}`, data);
        return response.data;
    },

    updateStatus: async (id: number, isActive: boolean) => {
        const response = await api.put<{
            success: boolean;
            message: string;
            data: { user: User };
        }>(`/users/${id}/status`, { isActive });
        return response.data;
    },

    getStats: async () => {
        const response = await api.get<{ success: boolean; data: UserStats }>(
            '/users/stats'
        );
        return response.data;
    },

    create: async (data: {
        name: string;
        phone: string;
        email?: string;
        password: string;
        civilIdNumber?: string;
        address?: string;
        monthlyIncome?: number;
        employer?: string;
    }) => {
        const response = await api.post<{
            success: boolean;
            message: string;
            data: { user: User };
        }>('/users', data);
        return response.data;
    },
};
