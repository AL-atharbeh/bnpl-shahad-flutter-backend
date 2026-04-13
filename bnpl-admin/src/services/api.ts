import axios from 'axios';

const api = axios.create({
    baseURL: 'https://enthusiastic-stillness-production-5dce.up.railway.app/api/v1',
    headers: {
        'Content-Type': 'application/json',
    },
});

// Add request interceptor for authentication
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Add response interceptor for error handling
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // TODO: Handle unauthorized - redirect to login
            // For now, admin endpoints don't require auth
        }
        return Promise.reject(error);
    }
);

// Users API
export const getUsers = (params?: any) => api.get('/users', { params });

// Stores API
export const getStores = (params?: any) => api.get('/stores', { params });
export const getAdminStores = () => api.get('/stores/admin/all');
export const createStore = (data: any) => api.post('/stores', data);
export const updateStore = (id: number, data: any) => api.put(`/stores/${id}`, data);
export const updateStoreStatus = (id: number, status: string) => api.put(`/stores/admin/${id}/status`, { status });
export const deleteStore = (id: number) => api.delete(`/stores/${id}`);

// Sessions API
export const getSessionsStats = () => api.get('/sessions/admin/stats');
export const getAllSessions = (params?: any) => api.get('/sessions/admin/all', { params });
export const getSessionsChartData = () => api.get('/sessions/admin/chart-data');

// Postponements API
export const getPostponementsStats = () => api.get('/postponements/admin/stats');
export const getAllPostponements = (params?: any) => api.get('/postponements/admin/all', { params });
export const getPostponementsChartData = () => api.get('/postponements/admin/chart-data');
export const getExtensionOptions = () => api.get('/postponements/extension-options');
export const createExtensionOption = (data: any) => api.post('/postponements/admin/extension-options', data); // I'll need to add this to backend too if I want full CRUD
export const deleteExtensionOption = (id: number) => api.delete(`/postponements/admin/extension-options/${id}`);

// Payments API
export const getPaymentsStats = () => api.get('/payments/admin/stats');
export const getAllPayments = (params?: any) => api.get('/payments/admin/all', { params });
export const getUpcomingPayments = () => api.get('/payments/admin/upcoming');
export const manualCollectPayment = (id: number) => api.post(`/payments/admin/${id}/collect`);
export const sendPaymentReminder = (id: number) => api.post(`/payments/admin/${id}/send-reminder`);

// Bank Transfers API
export const getAllBankTransfers = (params?: any) => api.get('/bank-transfers/admin/all', { params });
export const createBankTransfer = (data: any) => api.post('/bank-transfers/admin/create', data);

// Commission Settings API
export const getCurrentCommissionSettings = () => api.get('/commission-settings/current');
export const updateCommissionSettings = (data: any) => api.post('/commission-settings/update', data);

// Settlements API
export const getAllSettlements = (params?: any) => api.get('/settlements/admin/all', { params });
export const createSettlement = (data: any) => api.post('/settlements/admin/create', data);

// Profit Distribution API
export const getProfitDistributionStats = () => api.get('/profit-distribution/stats');
export const getProfitDistributionChart = (days: number = 7) => api.get(`/profit-distribution/chart?days=${days}`);

// Reports API
export const getReportsStats = () => api.get('/reports/stats');
export const getReportsPerformance = () => api.get('/reports/performance');
export const getReportsRisks = () => api.get('/reports/risks');
export const getReportsTopStores = () => api.get('/reports/top-stores');

// Categories API
export const getCategories = (params?: any) => api.get('/categories', { params });
export const getCategoriesAdmin = () => api.get('/categories/admin');
export const createCategory = (data: any) => api.post('/categories', data);
export const updateCategory = (id: number, data: any) => api.put(`/categories/${id}`, data);
export const deleteCategory = (id: number) => api.delete(`/categories/${id}`);

export default api;
