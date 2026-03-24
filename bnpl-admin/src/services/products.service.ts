import api from './api';

export interface Product {
    id: number;
    name: string;
    nameAr: string;
    storeId: number;
    price: string;
}

export const productsService = {
    getAll: async (storeId?: number) => {
        let url = '/products';
        if (storeId) {
            url = `/products/store/${storeId}`;
        }
        const response = await api.get<{ success: boolean; data: Product[] }>(url);
        return response.data;
    },
};
