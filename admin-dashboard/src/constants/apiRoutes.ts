/**
 * API route constants
 */
export const API_ROUTES = {
  // Auth
  LOGIN: '/auth/login',
  LOGOUT: '/auth/logout',
  REFRESH: '/auth/refresh',
  ME: '/auth/me',

  // Users
  USERS: '/admin/users',
  USER_BY_ID: (id: string) => `/admin/users/${id}`,
  BAN_USER: (id: string) => `/admin/users/${id}/ban`,

  // Nutritionists
  NUTRITIONISTS: '/admin/nutritionists',
  NUTRITIONIST_BY_ID: (id: string) => `/admin/nutritionists/${id}`,
  PENDING_VERIFICATIONS: '/admin/nutritionists/pending-verifications',
  VERIFY_NUTRITIONIST: (id: string) => `/admin/nutritionists/${id}/verify`,

  // Recipes
  RECIPES: '/admin/recipes',
  RECIPE_BY_ID: (id: string) => `/admin/recipes/${id}`,
  APPROVE_RECIPE: (id: string) => `/admin/recipes/${id}/approve`,

  // Ingredients
  INGREDIENTS: '/admin/ingredients',
  INGREDIENT_BY_ID: (id: string) => `/admin/ingredients/${id}`,

  // Micronutrients
  MICRONUTRIENTS: '/admin/micronutrients',
  MICRONUTRIENT_BY_ID: (id: string) => `/admin/micronutrients/${id}`,

  // Knowledge Base
  KNOWLEDGE_BASE: '/admin/knowledge-base',
  KNOWLEDGE_CATEGORIES: '/admin/knowledge-base/categories',
  ARTICLE_BY_ID: (id: string) => `/admin/knowledge-base/${id}`,

  // Reviews
  REVIEWS: '/admin/reviews',
  FLAGGED_REVIEWS: '/admin/reviews/flagged',
  MODERATE_REVIEW: (id: string) => `/admin/reviews/${id}/moderate`,

  // Analytics
  DASHBOARD_METRICS: '/admin/analytics/dashboard',
  USER_ANALYTICS: '/admin/analytics/users',
  CONTENT_ANALYTICS: '/admin/analytics/content',
} as const;
