import api from './api';

export interface SendNotificationDto {
    userId: string;
    title: string;
    body: string;
    imageUrl?: string;
    data?: Record<string, string>;
}

export interface SendBulkNotificationDto {
    userIds: string[];
    title: string;
    body: string;
    imageUrl?: string;
    data?: Record<string, string>;
}

export interface SendTopicNotificationDto {
    topic: string;
    title: string;
    body: string;
    imageUrl?: string;
    data?: Record<string, string>;
}

export const notificationsService = {
    sendToUser: async (data: SendNotificationDto) => {
        const response = await api.post<{ success: boolean; message: string; data: any }>(
            '/notifications/send',
            data
        );
        return response.data;
    },

    sendBulk: async (data: SendBulkNotificationDto) => {
        const response = await api.post<{ success: boolean; message: string; data: any }>(
            '/notifications/send-bulk',
            data
        );
        return response.data;
    },

    sendAll: async (data: { title: string; body: string; imageUrl?: string; data?: Record<string, string> }) => {
        const response = await api.post<{ success: boolean; message: string; data: any }>(
            '/notifications/send-all',
            data
        );
        return response.data;
    },

    sendTopic: async (data: SendTopicNotificationDto) => {
        const response = await api.post<{ success: boolean; message: string }>(
            '/notifications/send-topic',
            data
        );
        return response.data;
    },
};
