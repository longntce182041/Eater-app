import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { recipesService } from '@services/recipesService';
import type { Recipe, RecipesState, RecipeFilters } from '@types/recipe';

const initialState: RecipesState = {
  recipes: [],
  selectedRecipe: null,
  totalCount: 0,
  currentPage: 1,
  pageSize: 20,
  isLoading: false,
  error: null,
  filters: {},
};

// Async thunks
export const fetchRecipes = createAsyncThunk(
  'recipes/fetchRecipes',
  async (params: { page?: number; filters?: RecipeFilters }, { rejectWithValue }) => {
    try {
      const response = await recipesService.getRecipes(params);
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch recipes');
    }
  }
);

export const fetchRecipeById = createAsyncThunk(
  'recipes/fetchRecipeById',
  async (id: string, { rejectWithValue }) => {
    try {
      const recipe = await recipesService.getRecipeById(id);
      return recipe;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch recipe');
    }
  }
);

export const createRecipe = createAsyncThunk(
  'recipes/createRecipe',
  async (data: Omit<Recipe, 'id'>, { rejectWithValue }) => {
    try {
      const recipe = await recipesService.createRecipe(data);
      return recipe;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create recipe');
    }
  }
);

export const updateRecipe = createAsyncThunk(
  'recipes/updateRecipe',
  async ({ id, data }: { id: string; data: Partial<Recipe> }, { rejectWithValue }) => {
    try {
      const recipe = await recipesService.updateRecipe(id, data);
      return recipe;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update recipe');
    }
  }
);

export const deleteRecipe = createAsyncThunk(
  'recipes/deleteRecipe',
  async (id: string, { rejectWithValue }) => {
    try {
      await recipesService.deleteRecipe(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete recipe');
    }
  }
);

export const approveRecipe = createAsyncThunk(
  'recipes/approveRecipe',
  async (id: string, { rejectWithValue }) => {
    try {
      const recipe = await recipesService.approveRecipe(id);
      return recipe;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to approve recipe');
    }
  }
);

const recipesSlice = createSlice({
  name: 'recipes',
  initialState,
  reducers: {
    setFilters: (state, action) => {
      state.filters = action.payload;
      state.currentPage = 1;
    },
    clearSelectedRecipe: (state) => {
      state.selectedRecipe = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch recipes
      .addCase(fetchRecipes.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchRecipes.fulfilled, (state, action) => {
        state.isLoading = false;
        state.recipes = action.payload.recipes;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchRecipes.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Fetch by ID
      .addCase(fetchRecipeById.fulfilled, (state, action) => {
        state.selectedRecipe = action.payload;
      })
      // Create recipe
      .addCase(createRecipe.fulfilled, (state, action) => {
        state.recipes.unshift(action.payload);
      })
      // Update recipe
      .addCase(updateRecipe.fulfilled, (state, action) => {
        const index = state.recipes.findIndex((r) => r.id === action.payload.id);
        if (index !== -1) {
          state.recipes[index] = action.payload;
        }
        state.selectedRecipe = action.payload;
      })
      // Delete recipe
      .addCase(deleteRecipe.fulfilled, (state, action) => {
        state.recipes = state.recipes.filter((r) => r.id !== action.payload);
      })
      // Approve recipe
      .addCase(approveRecipe.fulfilled, (state, action) => {
        const index = state.recipes.findIndex((r) => r.id === action.payload.id);
        if (index !== -1) {
          state.recipes[index] = action.payload;
        }
      });
  },
});

export const { setFilters, clearSelectedRecipe, clearError } = recipesSlice.actions;
export default recipesSlice.reducer;
