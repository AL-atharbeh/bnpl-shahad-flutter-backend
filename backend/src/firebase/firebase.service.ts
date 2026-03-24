import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { Message, MulticastMessage } from 'firebase-admin/messaging';

@Injectable()
export class FirebaseService implements OnModuleInit {
    private readonly logger = new Logger(FirebaseService.name);
    private messaging: admin.messaging.Messaging;

    constructor(private configService: ConfigService) { }

    async onModuleInit() {
        try {
            // Initialize Firebase Admin SDK
            const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
            const privateKey = this.configService
                .get<string>('FIREBASE_PRIVATE_KEY')
                ?.replace(/\\n/g, '\n');
            const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');

            if (!projectId || !privateKey || !clientEmail) {
                this.logger.warn('Firebase credentials not configured. Notifications will be disabled.');
                return;
            }

            admin.initializeApp({
                credential: admin.credential.cert({
                    projectId,
                    privateKey,
                    clientEmail,
                }),
            });

            this.messaging = admin.messaging();
            this.logger.log('Firebase Admin SDK initialized successfully');
        } catch (error) {
            this.logger.error('Failed to initialize Firebase Admin SDK', error);
        }
    }

    /**
     * Send notification to a single device
     */
    async sendToDevice(token: string, notification: { title: string; body: string }, data?: Record<string, string>) {
        if (!this.messaging) {
            this.logger.warn('Firebase messaging not initialized');
            return null;
        }

        try {
            const message: Message = {
                token,
                notification: {
                    title: notification.title,
                    body: notification.body,
                },
                data: data || {},
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                        channelId: 'default',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
            };

            const response = await this.messaging.send(message);
            this.logger.log(`Notification sent successfully: ${response}`);
            return response;
        } catch (error) {
            this.logger.error(`Failed to send notification to device: ${error.message}`);
            throw error;
        }
    }

    /**
     * Send notification to multiple devices
     */
    async sendToMultipleDevices(
        tokens: string[],
        notification: { title: string; body: string },
        data?: Record<string, string>,
    ) {
        if (!this.messaging) {
            this.logger.warn('Firebase messaging not initialized');
            return null;
        }

        try {
            const message: MulticastMessage = {
                tokens,
                notification: {
                    title: notification.title,
                    body: notification.body,
                },
                data: data || {},
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                        channelId: 'default',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
            };

            const response = await this.messaging.sendEachForMulticast(message);
            this.logger.log(
                `Notifications sent: ${response.successCount} successful, ${response.failureCount} failed`,
            );
            return response;
        } catch (error) {
            this.logger.error(`Failed to send notifications to multiple devices: ${error.message}`);
            throw error;
        }
    }

    /**
     * Send notification to a topic
     */
    async sendToTopic(topic: string, notification: { title: string; body: string }, data?: Record<string, string>) {
        if (!this.messaging) {
            this.logger.warn('Firebase messaging not initialized');
            return null;
        }

        try {
            const message: Message = {
                topic,
                notification: {
                    title: notification.title,
                    body: notification.body,
                },
                data: data || {},
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                        channelId: 'default',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
            };

            const response = await this.messaging.send(message);
            this.logger.log(`Notification sent to topic ${topic}: ${response}`);
            return response;
        } catch (error) {
            this.logger.error(`Failed to send notification to topic: ${error.message}`);
            throw error;
        }
    }

    /**
     * Subscribe device to a topic
     */
    async subscribeToTopic(tokens: string[], topic: string) {
        if (!this.messaging) {
            this.logger.warn('Firebase messaging not initialized');
            return null;
        }

        try {
            const response = await this.messaging.subscribeToTopic(tokens, topic);
            this.logger.log(`Subscribed ${response.successCount} devices to topic ${topic}`);
            return response;
        } catch (error) {
            this.logger.error(`Failed to subscribe to topic: ${error.message}`);
            throw error;
        }
    }

    /**
     * Unsubscribe device from a topic
     */
    async unsubscribeFromTopic(tokens: string[], topic: string) {
        if (!this.messaging) {
            this.logger.warn('Firebase messaging not initialized');
            return null;
        }

        try {
            const response = await this.messaging.unsubscribeFromTopic(tokens, topic);
            this.logger.log(`Unsubscribed ${response.successCount} devices from topic ${topic}`);
            return response;
        } catch (error) {
            this.logger.error(`Failed to unsubscribe from topic: ${error.message}`);
            throw error;
        }
    }
}
