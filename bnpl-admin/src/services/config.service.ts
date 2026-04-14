import api from './api';

export interface AppConfig {
  id: number;
  splashImageUrl: string | null;
  maintenanceMode: boolean;
  updatedAt: string;
}

export const configService = {
  getSplash: async () => {
    const response = await api.get<{ success: boolean; data: { splashImageUrl: string; updatedAt: string } }>('/app-config/splash');
    return response.data;
  },

  updateSplash: async (imageUrl: string) => {
    const response = await api.post<{ success: boolean; data: AppConfig }>('/app-config/splash', { imageUrl });
    return response.data;
  },

  getAll: async () => {
    const response = await api.get<{ success: boolean; data: AppConfig }>('/app-config/all');
    return response.data;
  },
};
