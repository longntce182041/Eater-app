import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { micronutrientsService } from '@services/micronutrientsService';
import type { Micronutrient, MicronutrientsState } from '@types/micronutrient';

const initialState: MicronutrientsState = {
  micronutrients: [],
  selectedMicronutrient: null,
  totalCount: 0,
  isLoading: false,
  error: null,
};

// Async thunks
export const fetchMicronutrients = createAsyncThunk(
  'micronutrients/fetchMicronutrients',
  async (_, { rejectWithValue }) => {
    try {
      const response = await micronutrientsService.getMicronutrients();
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch micronutrients');
    }
  }
);

export const fetchMicronutrientById = createAsyncThunk(
  'micronutrients/fetchMicronutrientById',
  async (id: string, { rejectWithValue }) => {
    try {
      const micronutrient = await micronutrientsService.getMicronutrientById(id);
      return micronutrient;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch micronutrient');
    }
  }
);

export const createMicronutrient = createAsyncThunk(
  'micronutrients/createMicronutrient',
  async (data: Omit<Micronutrient, 'id'>, { rejectWithValue }) => {
    try {
      const micronutrient = await micronutrientsService.createMicronutrient(data);
      return micronutrient;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create micronutrient');
    }
  }
);

export const updateMicronutrient = createAsyncThunk(
  'micronutrients/updateMicronutrient',
  async ({ id, data }: { id: string; data: Partial<Micronutrient> }, { rejectWithValue }) => {
    try {
      const micronutrient = await micronutrientsService.updateMicronutrient(id, data);
      return micronutrient;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update micronutrient');
    }
  }
);

export const deleteMicronutrient = createAsyncThunk(
  'micronutrients/deleteMicronutrient',
  async (id: string, { rejectWithValue }) => {
    try {
      await micronutrientsService.deleteMicronutrient(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete micronutrient');
    }
  }
);

const micronutrientsSlice = createSlice({
  name: 'micronutrients',
  initialState,
  reducers: {
    clearSelectedMicronutrient: (state) => {
      state.selectedMicronutrient = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch all
      .addCase(fetchMicronutrients.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchMicronutrients.fulfilled, (state, action) => {
        state.isLoading = false;
        state.micronutrients = action.payload;
        state.totalCount = action.payload.length;
      })
      .addCase(fetchMicronutrients.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Fetch by ID
      .addCase(fetchMicronutrientById.fulfilled, (state, action) => {
        state.selectedMicronutrient = action.payload;
      })
      // Create
      .addCase(createMicronutrient.fulfilled, (state, action) => {
        state.micronutrients.push(action.payload);
      })
      // Update
      .addCase(updateMicronutrient.fulfilled, (state, action) => {
        const index = state.micronutrients.findIndex((m) => m.id === action.payload.id);
        if (index !== -1) {
          state.micronutrients[index] = action.payload;
        }
      })
      // Delete
      .addCase(deleteMicronutrient.fulfilled, (state, action) => {
        state.micronutrients = state.micronutrients.filter((m) => m.id !== action.payload);
      });
  },
});

export const { clearSelectedMicronutrient, clearError } = micronutrientsSlice.actions;
export default micronutrientsSlice.reducer;
