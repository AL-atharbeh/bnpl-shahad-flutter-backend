import axios from 'axios';

const api = axios.create({
    baseURL: process.env.NEXT_PUBLIC_API_URL || 'https://bnpl-shahad-flutter-backend.onrender.com/api/v1',
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

// Vendor Auth APIs
export const vendorLogin = (data: any) => api.post('/auth/vendor/login', data);
export const vendorRegister = (data: any) => api.post('/auth/vendor/register', data);

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
    return api.post('/products/upload', formData);
};

export const getStoreSettings = (storeId: number) => api.get(`/stores/${storeId}`);
export const updateStoreSettings = (storeId: number, data: any) => api.put(`/stores/${storeId}`, data);
export const getCategories = () => api.get('/categories');

export default api;
