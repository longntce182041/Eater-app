/**
 * Analytics types
 */

export interface DashboardMetrics {
  totalUsers: number;
  newUsersToday: number;
  activeUsers: number;
  totalNutritionists: number;
  pendingVerifications: number;
  totalRecipes: number;
  pendingRecipes: number;
  totalReviews: number;
  flaggedReviews: number;
  userGrowthPercent: number;
  recipeGrowthPercent: number;
}

export interface UserAnalytics {
  totalUsers: number;
  newUsers: number;
  activeUsers: number;
  churnRate: number;
  averageSessionDuration: number;
  usersByPlan: {
    free: number;
    premium: number;
  };
  userGrowthChart: ChartDataPoint[];
  usersByRegion: { region: string; count: number }[];
  usersByAgeGroup: { ageGroup: string; count: number }[];
  topRetentionFactors: string[];
}

export interface ContentAnalytics {
  totalRecipes: number;
  newRecipes: number;
  approvedRecipes: number;
  rejectedRecipes: number;
  averageRecipeRating: number;
  topRatedRecipes: { id: string; name: string; rating: number }[];
  topViewedRecipes: { id: string; name: string; views: number }[];
  recipesByCategory: { category: string; count: number }[];
  contentGrowthChart: ChartDataPoint[];
  moderationStats: {
    reviewed: number;
    pending: number;
    removed: number;
  };
}

export interface ChartDataPoint {
  date: string;
  value: number;
  label?: string;
}

export interface AnalyticsState {
  dashboardMetrics: DashboardMetrics | null;
  userAnalytics: UserAnalytics | null;
  contentAnalytics: ContentAnalytics | null;
  isLoading: boolean;
  error: string | null;
  dateRange: {
    startDate: string;
    endDate: string;
  };
}
