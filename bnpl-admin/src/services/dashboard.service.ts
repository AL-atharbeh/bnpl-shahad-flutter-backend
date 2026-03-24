import api from './api';
import { User } from './users.service';
import { Store } from './stores.service';

export interface DashboardStats {
    totalUsers: number;
    activeUsers: number;
    totalStores: number;
    activeStores: number;
    totalSales: number;
    totalProfits: number;
    overduePayments: number;
    blockedUsers: number;
    verifiedUsers: number;
    newUsersThisMonth: number;
    avgCreditScore: number;
    totalCreditLimit: number;
    totalCreditUsed: number;
    totalDelays: number;
    avgTransactionValue: number;
}

export interface RecentUser {
    id: number;
    name: string;
    phone: string;
    isActive: boolean;
    createdAt: string;
}

export interface RecentStore {
    id: number;
    name: string;
    category?: string;
    createdAt: string;
}

export const dashboardService = {
    getStats: async (): Promise<DashboardStats> => {
        try {
            // Get users stats
            const usersStatsResponse = await api.get<{ success: boolean; data: any }>('/users/stats');
            const usersStats = usersStatsResponse.data?.data || {};
            console.log('Users stats:', usersStats);

            // Get stores
            const storesResponse = await api.get<{ success: boolean; data: Store[] }>('/stores');
            const stores = storesResponse.data?.data || [];
            console.log('Stores:', stores.length, 'stores found');
            const activeStores = stores.filter(s => s.isActive).length;

            // Calculate total sales and profits from payments (if available)
            // For now, we'll use placeholder values until we have a payments stats endpoint
            const totalSales = 0; // TODO: Get from payments API
            const totalProfits = 0; // TODO: Calculate from commission
            const overduePayments = 0; // TODO: Get from payments API

            const stats = {
                totalUsers: usersStats.totalUsers || 0,
                activeUsers: usersStats.activeUsers || 0,
                totalStores: stores.length,
                activeStores,
                totalSales,
                totalProfits,
                overduePayments: usersStats.totalDelays || 0,
                blockedUsers: usersStats.blockedUsers || 0,
                verifiedUsers: usersStats.verifiedUsers || 0,
                newUsersThisMonth: usersStats.newUsersThisMonth || 0,
                avgCreditScore: usersStats.avgCreditScore || 0,
                totalCreditLimit: usersStats.totalCreditLimit || 0,
                totalCreditUsed: usersStats.totalCreditUsed || 0,
                totalDelays: usersStats.totalDelays || 0,
                avgTransactionValue: usersStats.avgTransactionValue || 0,
            };
            console.log('Dashboard stats:', stats);
            return stats;
        } catch (error) {
            console.error('Failed to fetch dashboard stats from API', error);
            return {
                totalUsers: 0,
                activeUsers: 0,
                totalStores: 0,
                activeStores: 0,
                totalSales: 0,
                totalProfits: 0,
                overduePayments: 0,
                blockedUsers: 0,
                verifiedUsers: 0,
                newUsersThisMonth: 0,
                avgCreditScore: 0,
                totalCreditLimit: 0,
                totalCreditUsed: 0,
                totalDelays: 0,
                avgTransactionValue: 0,
            };
        }
    },

    getRecentUsers: async (limit: number = 5): Promise<RecentUser[]> => {
        try {
            const response = await api.get<{
                success: boolean;
                data: { users: User[]; total: number };
            }>('/users', {
                params: {
                    limit,
                    page: 1,
                },
            });

            const users = response.data?.data?.users || [];
            console.log('Recent users:', users.length, 'users found');
            const sortedUsers = users
                .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
                .slice(0, limit)
                .map((user) => ({
                    id: user.id,
                    name: user.name,
                    phone: user.phone,
                    isActive: user.isActive,
                    createdAt: user.createdAt,
                }));
            console.log('Sorted recent users:', sortedUsers);
            return sortedUsers;
        } catch (error) {
            console.error('Failed to fetch recent users', error);
            return [];
        }
    },

    getRecentStores: async (limit: number = 5): Promise<RecentStore[]> => {
        try {
            const response = await api.get<{ success: boolean; data: Store[] }>('/stores');
            const stores = response.data?.data || [];
            console.log('Recent stores:', stores.length, 'stores found');
            const sortedStores = stores
                .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
                .slice(0, limit)
                .map((store) => ({
                    id: store.id,
                    name: store.name,
                    category: store.category,
                    createdAt: store.createdAt,
                }));
            console.log('Sorted recent stores:', sortedStores);
            return sortedStores;
        } catch (error) {
            console.error('Failed to fetch recent stores', error);
            return [];
        }
    },
};

