import { apiClient } from './apiClient';
import type { KnowledgeArticle, KnowledgeCategory, KnowledgeBaseResponse } from '@types/knowledge-base';

/**
 * Nutrition knowledge base management service
 */
export const knowledgeBaseService = {
  /**
   * Get paginated list of articles
   */
  async getArticles(params: { page?: number; category?: string }): Promise<KnowledgeBaseResponse> {
    const queryParams = new URLSearchParams();
    if (params.page) queryParams.append('page', params.page.toString());
    if (params.category) queryParams.append('category', params.category);
    return apiClient.get<KnowledgeBaseResponse>(`/admin/knowledge-base?${queryParams.toString()}`);
  },

  /**
   * Get all categories
   */
  async getCategories(): Promise<KnowledgeCategory[]> {
    return apiClient.get<KnowledgeCategory[]>('/admin/knowledge-base/categories');
  },

  /**
   * Get article by ID
   */
  async getArticleById(id: string): Promise<KnowledgeArticle> {
    return apiClient.get<KnowledgeArticle>(`/admin/knowledge-base/${id}`);
  },

  /**
   * Create new article
   */
  async createArticle(data: Omit<KnowledgeArticle, 'id'>): Promise<KnowledgeArticle> {
    return apiClient.post<KnowledgeArticle>('/admin/knowledge-base', data);
  },

  /**
   * Update article
   */
  async updateArticle(id: string, data: Partial<KnowledgeArticle>): Promise<KnowledgeArticle> {
    return apiClient.patch<KnowledgeArticle>(`/admin/knowledge-base/${id}`, data);
  },

  /**
   * Delete article
   */
  async deleteArticle(id: string): Promise<void> {
    return apiClient.delete(`/admin/knowledge-base/${id}`);
  },

  /**
   * Publish article
   */
  async publishArticle(id: string): Promise<KnowledgeArticle> {
    return apiClient.post<KnowledgeArticle>(`/admin/knowledge-base/${id}/publish`);
  },

  /**
   * Create category
   */
  async createCategory(data: Omit<KnowledgeCategory, 'id'>): Promise<KnowledgeCategory> {
    return apiClient.post<KnowledgeCategory>('/admin/knowledge-base/categories', data);
  },
};
