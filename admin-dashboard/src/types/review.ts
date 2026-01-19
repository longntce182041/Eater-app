/**
 * Review moderation types
 */

export type ModerationAction = 'approve' | 'remove' | 'warn_user' | 'ban_user';

export interface Review {
  id: string;
  userId: string;
  userName: string;
  userAvatar?: string;
  targetType: 'recipe' | 'nutritionist';
  targetId: string;
  targetName: string;
  rating: number;
  content: string;
  status: 'active' | 'hidden' | 'removed';
  flagCount: number;
  flagReasons?: string[];
  moderationStatus: 'pending' | 'reviewed' | 'actioned';
  moderatedBy?: string;
  moderatedAt?: string;
  moderationNotes?: string;
  createdAt: string;
  updatedAt: string;
}

export interface ReviewReport {
  id: string;
  reviewId: string;
  reporterId: string;
  reporterName: string;
  reason: string;
  details?: string;
  status: 'pending' | 'reviewed' | 'dismissed';
  createdAt: string;
}

export interface ReviewsResponse {
  reviews: Review[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface ReviewsState {
  reviews: Review[];
  flaggedReviews: Review[];
  selectedReview: Review | null;
  totalCount: number;
  flaggedCount: number;
  currentPage: number;
  pageSize: number;
  isLoading: boolean;
  error: string | null;
}
