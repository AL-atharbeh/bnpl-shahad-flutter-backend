import axios from 'axios';

const api = axios.create({
    baseURL: process.env.NEXT_PUBLIC_API_URL || 'https://api.shahedapp.com/api/v1',
    headers: {
        'Content-Type': 'application/json',
    },
});

// Add request interceptor for authentication
api.interceptors.request.use(
    (config) => {
        const token = typeof window !== 'undefined' ? localStorage.getItem('vendor_token') : null;
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
            if (typeof window !== 'undefined') {
                localStorage.removeItem('vendor_token');
                localStorage.removeItem('vendor_user');
                window.location.href = '/auth/login';
            }
        }
        return Promise.reject(error);
    }
);

// Vendor Auth APIs
export const vendorLogin = (data: any) => api.post('/auth/vendor/login', data);
export const vendorRegister = (data: any) => api.post('/auth/vendor/register', data);
export const getVendorAccount = () => api.get('/auth/vendor/me');
export const updateVendorProfile = (data: { name?: string; email?: string; phone?: string }) => api.put('/auth/vendor/me', data);
export const changeVendorPassword = (currentPassword: string, newPassword: string) =>
    api.put('/auth/vendor/password', { currentPassword, newPassword });
// Closes the merchant's account for good; needs their password.
export const deleteVendorAccount = (password: string) =>
    api.delete('/auth/vendor/me', { data: { password } });
export const getVendorNotifications = () => api.get('/auth/vendor/notifications', { params: { limit: 30 } });
// Without an id, marks every notification read.
export const markVendorNotificationsRead = (id?: number) => api.post('/auth/vendor/notifications/read', id ? { id } : {});
export const regenerateApiKeys = (storeId: number) => api.post(`/stores/${storeId}/api-keys/regenerate`);
export const getMySettlements = (page = 1) => api.get('/settlements/mine', { params: { page, limit: 20 } });

// Merchant application
export type DocumentType = 'commercial-registration' | 'trade-license' | 'owner-id';
export const uploadStoreDocument = (storeId: number, type: DocumentType, file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post(`/stores/${storeId}/documents/${type}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
    });
};
// Documents are private, so they come back as a blob over the signed-in session.
export const getStoreDocument = (storeId: number, type: DocumentType) =>
    api.get(`/stores/${storeId}/documents/${type}`, { responseType: 'blob' });
export const submitStoreApplication = (storeId: number) =>
    api.post(`/stores/${storeId}/application/submit`, { termsAccepted: true });

// Vendor Specific APIs
export const getVendorDashboardStats = (storeId: number) => api.get(`/reports/stats?storeId=${storeId}`);
export const getVendorPerformance = (storeId: number) => api.get(`/reports/performance?storeId=${storeId}`);
export const getVendorTransactions = (params: any, storeId: number) => api.get('/payments/admin/all', { params: { ...params, storeId } });
export const getVendorSettlements = (params: any, storeId: number) => api.get('/settlements/admin/all', { params: { ...params, storeId } });
export const getVendorSettlementStats = (storeId: number) => api.get(`/settlements/stats?storeId=${storeId}`);
export const getSalesDetailed = (storeId: number) => api.get(`/reports/sales-detailed?storeId=${storeId}`);

export const createBnplSession = (data: any) => api.post('/sessions/create', data);
export const getBnplSession = (sessionId: string) => api.get(`/sessions/${sessionId}`);
export const verifyBnplOtp = (sessionId: string, otp: string) => api.post(`/sessions/${sessionId}/verify-otp`, { otp });

export const getVendorProducts = (storeId: number, params?: any) => api.get(`/products/store/${storeId}`, { params });
export const createProduct = (data: any) => api.post('/products', data);
export const updateProduct = (id: number, data: any) => api.put(`/products/${id}`, data);
export const deleteProduct = (id: number) => api.delete(`/products/${id}`);

export const uploadProductImage = (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post('/products/upload', formData, {
        headers: {
            'Content-Type': 'multipart/form-data',
        },
    });
};

// Store & Commissions
export const getStoreSettings = (storeId: number) => api.get(`/stores/${storeId}`);
export const getCurrentCommissionSettings = () => api.get('/commission-settings/current');
export const updateStoreSettings = (storeId: number, data: any) => api.put(`/stores/${storeId}`, data);
export const createStore = (storeData: any) => api.post("/stores", storeData);

// Users & POS Enhancements
export const findUserByPhone = (phone: string) => api.get('/users/find-by-phone', { params: { phone } });
export const getRecentSessions = (storeId: number) => api.get(`/sessions/store/${storeId}/recent`);
export const requestSettlement = (storeId: number, vendorName: string) => api.post('/settlements/request', { storeId, vendorName });
export const getCategories = () => api.get('/categories');

export default api;
