import api from './api';
import { Store } from './stores.service';

export interface FeaturedBrand {
  id: number;
  storeId: number;
  imageUrl: string;
  isActive: boolean;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
  store?: Store;
}

export const featuredBrandsService = {
  getAll: async () => {
    const response = await api.get<{ success: boolean; data: FeaturedBrand[] }>('/featured-brands/admin');
    return response.data;
  },

  create: async (data: Partial<FeaturedBrand>) => {
    const response = await api.post<{ success: boolean; data: FeaturedBrand }>('/featured-brands', data);
    return response.data;
  },

  update: async (id: number, data: Partial<FeaturedBrand>) => {
    const response = await api.put<{ success: boolean; data: FeaturedBrand }>(`/featured-brands/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await api.delete<{ success: boolean; message: string }>(`/featured-brands/${id}`);
    return response.data;
  },
};
