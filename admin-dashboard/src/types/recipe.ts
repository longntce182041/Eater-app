/**
 * Recipe management types
 */

export interface Recipe {
  id: string;
  name: string;
  description: string;
  imageUrl?: string;
  authorId: string;
  authorName: string;
  authorType: 'user' | 'nutritionist' | 'admin';
  status: 'draft' | 'pending' | 'approved' | 'rejected';
  featured: boolean;
  categories: string[];
  cuisineTypes: string[];
  dietaryLabels: string[];
  prepTimeMinutes: number;
  cookTimeMinutes: number;
  servings: number;
  difficulty: 'easy' | 'medium' | 'hard';
  ingredients: RecipeIngredient[];
  instructions: string[];
  nutrition: NutritionInfo;
  tags: string[];
  viewCount: number;
  saveCount: number;
  averageRating?: number;
  reviewCount: number;
  createdAt: string;
  updatedAt: string;
  approvedAt?: string;
  approvedBy?: string;
  rejectionReason?: string;
}

export interface RecipeIngredient {
  ingredientId: string;
  name: string;
  amount: number;
  unit: string;
  optional: boolean;
}

export interface NutritionInfo {
  calories: number;
  protein: number;
  carbohydrates: number;
  fat: number;
  fiber: number;
  sugar: number;
  sodium: number;
}

export interface RecipeFilters {
  status?: string;
  category?: string;
  cuisineType?: string;
  difficulty?: string;
  authorType?: string;
  featured?: boolean;
  search?: string;
}

export interface RecipesResponse {
  recipes: Recipe[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface RecipesState {
  recipes: Recipe[];
  selectedRecipe: Recipe | null;
  totalCount: number;
  currentPage: number;
  pageSize: number;
  isLoading: boolean;
  error: string | null;
  filters: RecipeFilters;
}
