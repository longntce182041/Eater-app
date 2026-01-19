/**
 * Ingredient management types
 */

export interface Ingredient {
  id: string;
  name: string;
  category: string;
  description?: string;
  imageUrl?: string;
  aliases?: string[];
  isCommon: boolean;
  nutrition: IngredientNutrition;
  allergens?: string[];
  seasonality?: string[];
  storageInstructions?: string;
  createdAt: string;
  updatedAt: string;
}

export interface IngredientNutrition {
  servingSize: number;
  servingUnit: string;
  calories: number;
  protein: number;
  carbohydrates: number;
  fat: number;
  fiber: number;
  sugar: number;
  sodium: number;
  micronutrients: Record<string, number>;
}

export interface IngredientsResponse {
  ingredients: Ingredient[];
  totalCount: number;
  page: number;
  pageSize: number;
}

export interface IngredientsState {
  ingredients: Ingredient[];
  selectedIngredient: Ingredient | null;
  totalCount: number;
  currentPage: number;
  pageSize: number;
  isLoading: boolean;
  error: string | null;
  searchQuery: string;
}
