import api from './api';

export enum LinkType {
  CATEGORY = 'category',
  STORE = 'store',
  PRODUCT = 'product',
  EXTERNAL = 'external',
  NONE = 'none',
}

export interface Banner {
  id: number;
  title?: string;
  titleAr?: string;
  imageUrl: string;
  linkUrl?: string;
  linkType: LinkType;
  linkId?: number;
  categoryId?: number;
  description?: string;
  descriptionAr?: string;
  isActive: boolean;
  sortOrder: number;
  clickCount: number;
  startDate?: string;
  endDate?: string;
  createdAt: string;
  updatedAt: string;
}

export const bannersService = {
  getAll: async () => {
    const response = await api.get<{ success: boolean; data: Banner[] }>('/banners/admin');
    return response.data;
  },

  getById: async (id: number) => {
    const response = await api.get<{ success: boolean; data: Banner }>(`/banners/${id}`);
    return response.data;
  },

  create: async (data: Partial<Banner>) => {
    const response = await api.post<{ success: boolean; data: Banner }>('/banners', data);
    return response.data;
  },

  update: async (id: number, data: Partial<Banner>) => {
    const response = await api.put<{ success: boolean; data: Banner }>(`/banners/${id}`, data);
    return response.data;
  },

  delete: async (id: number) => {
    const response = await api.delete<{ success: boolean; message: string }>(`/banners/${id}`);
    return response.data;
  },

  incrementClick: async (id: number) => {
    const response = await api.post<{ success: boolean; message: string }>(`/banners/${id}/click`, {});
    return response.data;
  },

  uploadImage: async (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await api.post<{ success: boolean; data: { url: string; filename: string } }>('/banners/upload', formData);
    return response.data;
  },
};
