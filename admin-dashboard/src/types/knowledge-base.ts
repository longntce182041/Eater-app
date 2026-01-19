/**
 * Knowledge base types
 */

export interface KnowledgeArticle {
  id: string;
  title: string;
  slug: string;
  content: string;
  excerpt?: string;
  categoryId: string;
  categoryName: string;
  author: string;
  status: 'draft' | 'published' | 'archived';
  tags: string[];
  featuredImage?: string;
  viewCount: number;
  helpfulCount: number;
  notHelpfulCount: number;
  relatedArticles?: string[];
  createdAt: string;
  updatedAt: string;
  publishedAt?: string;
}

export interface KnowledgeCategory {
  id: string;
  name: string;
  slug: string;
  description?: string;
  parentId?: string;
  order: number;
  articleCount: number;
  icon?: string;
}

export interface KnowledgeBaseResponse {
  articles: KnowledgeArticle[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface KnowledgeBaseState {
  articles: KnowledgeArticle[];
  categories: KnowledgeCategory[];
  selectedArticle: KnowledgeArticle | null;
  totalCount: number;
  currentPage: number;
  pageSize: number;
  isLoading: boolean;
  error: string | null;
}
