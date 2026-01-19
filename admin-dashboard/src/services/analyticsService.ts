import { apiClient } from './apiClient';
import type { DashboardMetrics, UserAnalytics, ContentAnalytics } from '@types/analytics';

/**
 * Analytics service for dashboard metrics
 */
export const analyticsService = {
  /**
   * Get dashboard overview metrics
   */
  async getDashboardMetrics(): Promise<DashboardMetrics> {
    return apiClient.get<DashboardMetrics>('/admin/analytics/dashboard');
  },

  /**
   * Get user analytics
   */
  async getUserAnalytics(dateRange: { startDate: string; endDate: string }): Promise<UserAnalytics> {
    const queryParams = new URLSearchParams();
    queryParams.append('startDate', dateRange.startDate);
    queryParams.append('endDate', dateRange.endDate);
    return apiClient.get<UserAnalytics>(`/admin/analytics/users?${queryParams.toString()}`);
  },

  /**
   * Get content analytics
   */
  async getContentAnalytics(dateRange: { startDate: string; endDate: string }): Promise<ContentAnalytics> {
    const queryParams = new URLSearchParams();
    queryParams.append('startDate', dateRange.startDate);
    queryParams.append('endDate', dateRange.endDate);
    return apiClient.get<ContentAnalytics>(`/admin/analytics/content?${queryParams.toString()}`);
  },

  /**
   * Export analytics report
   */
  async exportReport(type: 'users' | 'content' | 'all', format: 'csv' | 'pdf'): Promise<Blob> {
    return apiClient.get(`/admin/analytics/export?type=${type}&format=${format}`, {
      responseType: 'blob',
    });
  },

  /**
   * Get real-time metrics
   */
  async getRealTimeMetrics(): Promise<{ activeUsers: number; activeSessions: number }> {
    return apiClient.get('/admin/analytics/realtime');
  },
};
