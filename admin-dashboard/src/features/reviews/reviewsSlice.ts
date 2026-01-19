import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { reviewsService } from '@services/reviewsService';
import type { Review, ReviewsState, ModerationAction } from '@types/review';

const initialState: ReviewsState = {
  reviews: [],
  flaggedReviews: [],
  selectedReview: null,
  totalCount: 0,
  flaggedCount: 0,
  currentPage: 1,
  pageSize: 20,
  isLoading: false,
  error: null,
};

// Async thunks
export const fetchReviews = createAsyncThunk(
  'reviews/fetchReviews',
  async (params: { page?: number; status?: string }, { rejectWithValue }) => {
    try {
      const response = await reviewsService.getReviews(params);
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch reviews');
    }
  }
);

export const fetchFlaggedReviews = createAsyncThunk(
  'reviews/fetchFlaggedReviews',
  async (_, { rejectWithValue }) => {
    try {
      const response = await reviewsService.getFlaggedReviews();
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch flagged reviews');
    }
  }
);

export const moderateReview = createAsyncThunk(
  'reviews/moderateReview',
  async (
    { id, action, reason }: { id: string; action: ModerationAction; reason?: string },
    { rejectWithValue }
  ) => {
    try {
      const result = await reviewsService.moderateReview(id, action, reason);
      return result;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Moderation failed');
    }
  }
);

export const deleteReview = createAsyncThunk(
  'reviews/deleteReview',
  async (id: string, { rejectWithValue }) => {
    try {
      await reviewsService.deleteReview(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete review');
    }
  }
);

const reviewsSlice = createSlice({
  name: 'reviews',
  initialState,
  reducers: {
    clearSelectedReview: (state) => {
      state.selectedReview = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch reviews
      .addCase(fetchReviews.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchReviews.fulfilled, (state, action) => {
        state.isLoading = false;
        state.reviews = action.payload.reviews;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchReviews.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Fetch flagged reviews
      .addCase(fetchFlaggedReviews.fulfilled, (state, action) => {
        state.flaggedReviews = action.payload.reviews;
        state.flaggedCount = action.payload.totalCount;
      })
      // Moderate review
      .addCase(moderateReview.fulfilled, (state, action) => {
        // Remove from flagged list
        state.flaggedReviews = state.flaggedReviews.filter(
          (r) => r.id !== action.payload.id
        );
        // Update in main list
        const index = state.reviews.findIndex((r) => r.id === action.payload.id);
        if (index !== -1) {
          state.reviews[index] = action.payload;
        }
      })
      // Delete review
      .addCase(deleteReview.fulfilled, (state, action) => {
        state.reviews = state.reviews.filter((r) => r.id !== action.payload);
        state.flaggedReviews = state.flaggedReviews.filter((r) => r.id !== action.payload);
      });
  },
});

export const { clearSelectedReview, clearError } = reviewsSlice.actions;
export default reviewsSlice.reducer;
