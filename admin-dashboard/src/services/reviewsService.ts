import { apiClient } from './apiClient';
import type { Review, ReviewsResponse, ModerationAction } from '@types/review';

/**
 * Reviews moderation service
 */
export const reviewsService = {
  /**
   * Get paginated list of reviews
   */
  async getReviews(params: { page?: number; status?: string }): Promise<ReviewsResponse> {
    const queryParams = new URLSearchParams();
    if (params.page) queryParams.append('page', params.page.toString());
    if (params.status) queryParams.append('status', params.status);
    return apiClient.get<ReviewsResponse>(`/admin/reviews?${queryParams.toString()}`);
  },

  /**
   * Get flagged/reported reviews
   */
  async getFlaggedReviews(): Promise<ReviewsResponse> {
    return apiClient.get<ReviewsResponse>('/admin/reviews/flagged');
  },

  /**
   * Moderate a review
   */
  async moderateReview(
    id: string,
    action: ModerationAction,
    reason?: string
  ): Promise<Review> {
    return apiClient.post<Review>(`/admin/reviews/${id}/moderate`, {
      action,
      reason,
    });
  },

  /**
   * Delete review
   */
  async deleteReview(id: string): Promise<void> {
    return apiClient.delete(`/admin/reviews/${id}`);
  },

  /**
   * Get review reports
   */
  async getReviewReports(id: string): Promise<unknown[]> {
    return apiClient.get(`/admin/reviews/${id}/reports`);
  },

  /**
   * Dismiss review reports
   */
  async dismissReports(id: string): Promise<void> {
    return apiClient.post(`/admin/reviews/${id}/dismiss-reports`);
  },
};
