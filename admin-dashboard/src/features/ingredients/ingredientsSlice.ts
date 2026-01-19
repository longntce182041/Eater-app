import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { ingredientsService } from '@services/ingredientsService';
import type { Ingredient, IngredientsState } from '@types/ingredient';

const initialState: IngredientsState = {
  ingredients: [],
  selectedIngredient: null,
  totalCount: 0,
  currentPage: 1,
  pageSize: 50,
  isLoading: false,
  error: null,
  searchQuery: '',
};

// Async thunks
export const fetchIngredients = createAsyncThunk(
  'ingredients/fetchIngredients',
  async (params: { page?: number; search?: string }, { rejectWithValue }) => {
    try {
      const response = await ingredientsService.getIngredients(params);
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch ingredients');
    }
  }
);

export const fetchIngredientById = createAsyncThunk(
  'ingredients/fetchIngredientById',
  async (id: string, { rejectWithValue }) => {
    try {
      const ingredient = await ingredientsService.getIngredientById(id);
      return ingredient;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch ingredient');
    }
  }
);

export const createIngredient = createAsyncThunk(
  'ingredients/createIngredient',
  async (data: Omit<Ingredient, 'id'>, { rejectWithValue }) => {
    try {
      const ingredient = await ingredientsService.createIngredient(data);
      return ingredient;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create ingredient');
    }
  }
);

export const updateIngredient = createAsyncThunk(
  'ingredients/updateIngredient',
  async ({ id, data }: { id: string; data: Partial<Ingredient> }, { rejectWithValue }) => {
    try {
      const ingredient = await ingredientsService.updateIngredient(id, data);
      return ingredient;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update ingredient');
    }
  }
);

export const deleteIngredient = createAsyncThunk(
  'ingredients/deleteIngredient',
  async (id: string, { rejectWithValue }) => {
    try {
      await ingredientsService.deleteIngredient(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete ingredient');
    }
  }
);

const ingredientsSlice = createSlice({
  name: 'ingredients',
  initialState,
  reducers: {
    setSearchQuery: (state, action) => {
      state.searchQuery = action.payload;
      state.currentPage = 1;
    },
    clearSelectedIngredient: (state) => {
      state.selectedIngredient = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch ingredients
      .addCase(fetchIngredients.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchIngredients.fulfilled, (state, action) => {
        state.isLoading = false;
        state.ingredients = action.payload.ingredients;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchIngredients.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Fetch by ID
      .addCase(fetchIngredientById.fulfilled, (state, action) => {
        state.selectedIngredient = action.payload;
      })
      // Create
      .addCase(createIngredient.fulfilled, (state, action) => {
        state.ingredients.unshift(action.payload);
      })
      // Update
      .addCase(updateIngredient.fulfilled, (state, action) => {
        const index = state.ingredients.findIndex((i) => i.id === action.payload.id);
        if (index !== -1) {
          state.ingredients[index] = action.payload;
        }
      })
      // Delete
      .addCase(deleteIngredient.fulfilled, (state, action) => {
        state.ingredients = state.ingredients.filter((i) => i.id !== action.payload);
      });
  },
});

export const { setSearchQuery, clearSelectedIngredient, clearError } = ingredientsSlice.actions;
export default ingredientsSlice.reducer;
