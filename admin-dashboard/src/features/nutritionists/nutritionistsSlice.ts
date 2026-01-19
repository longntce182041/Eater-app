import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { nutritionistsService } from '@services/nutritionistsService';
import type { Nutritionist, NutritionistsState, VerificationStatus } from '@types/nutritionist';

const initialState: NutritionistsState = {
  nutritionists: [],
  pendingVerifications: [],
  selectedNutritionist: null,
  totalCount: 0,
  currentPage: 1,
  pageSize: 20,
  isLoading: false,
  error: null,
};

// Async thunks
export const fetchNutritionists = createAsyncThunk(
  'nutritionists/fetchNutritionists',
  async (params: { page?: number; status?: string }, { rejectWithValue }) => {
    try {
      const response = await nutritionistsService.getNutritionists(params);
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch nutritionists');
    }
  }
);

export const fetchPendingVerifications = createAsyncThunk(
  'nutritionists/fetchPendingVerifications',
  async (_, { rejectWithValue }) => {
    try {
      const response = await nutritionistsService.getPendingVerifications();
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch pending verifications');
    }
  }
);

export const verifyNutritionist = createAsyncThunk(
  'nutritionists/verifyNutritionist',
  async (
    { id, status, notes }: { id: string; status: VerificationStatus; notes?: string },
    { rejectWithValue }
  ) => {
    try {
      const result = await nutritionistsService.verifyCredentials(id, status, notes);
      return result;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Verification failed');
    }
  }
);

export const fetchNutritionistById = createAsyncThunk(
  'nutritionists/fetchNutritionistById',
  async (id: string, { rejectWithValue }) => {
    try {
      const nutritionist = await nutritionistsService.getNutritionistById(id);
      return nutritionist;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch nutritionist');
    }
  }
);

const nutritionistsSlice = createSlice({
  name: 'nutritionists',
  initialState,
  reducers: {
    clearSelectedNutritionist: (state) => {
      state.selectedNutritionist = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch nutritionists
      .addCase(fetchNutritionists.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchNutritionists.fulfilled, (state, action) => {
        state.isLoading = false;
        state.nutritionists = action.payload.nutritionists;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchNutritionists.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Fetch pending verifications
      .addCase(fetchPendingVerifications.fulfilled, (state, action) => {
        state.pendingVerifications = action.payload;
      })
      // Verify nutritionist
      .addCase(verifyNutritionist.fulfilled, (state, action) => {
        state.pendingVerifications = state.pendingVerifications.filter(
          (n) => n.id !== action.payload.id
        );
      })
      // Fetch by ID
      .addCase(fetchNutritionistById.fulfilled, (state, action) => {
        state.selectedNutritionist = action.payload;
      });
  },
});

export const { clearSelectedNutritionist, clearError } = nutritionistsSlice.actions;
export default nutritionistsSlice.reducer;
