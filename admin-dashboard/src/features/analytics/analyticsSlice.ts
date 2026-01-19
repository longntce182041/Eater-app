import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { analyticsService } from '@services/analyticsService';
import type { AnalyticsState, DashboardMetrics, UserAnalytics, ContentAnalytics } from '@types/analytics';

const initialState: AnalyticsState = {
  dashboardMetrics: null,
  userAnalytics: null,
  contentAnalytics: null,
  isLoading: false,
  error: null,
  dateRange: {
    startDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days ago
    endDate: new Date().toISOString(),
  },
};

// Async thunks
export const fetchDashboardMetrics = createAsyncThunk(
  'analytics/fetchDashboardMetrics',
  async (_, { rejectWithValue }) => {
    try {
      const metrics = await analyticsService.getDashboardMetrics();
      return metrics;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch dashboard metrics');
    }
  }
);

export const fetchUserAnalytics = createAsyncThunk(
  'analytics/fetchUserAnalytics',
  async (dateRange: { startDate: string; endDate: string }, { rejectWithValue }) => {
    try {
      const analytics = await analyticsService.getUserAnalytics(dateRange);
      return analytics;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch user analytics');
    }
  }
);

export const fetchContentAnalytics = createAsyncThunk(
  'analytics/fetchContentAnalytics',
  async (dateRange: { startDate: string; endDate: string }, { rejectWithValue }) => {
    try {
      const analytics = await analyticsService.getContentAnalytics(dateRange);
      return analytics;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch content analytics');
    }
  }
);

const analyticsSlice = createSlice({
  name: 'analytics',
  initialState,
  reducers: {
    setDateRange: (state, action) => {
      state.dateRange = action.payload;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Dashboard metrics
      .addCase(fetchDashboardMetrics.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchDashboardMetrics.fulfilled, (state, action) => {
        state.isLoading = false;
        state.dashboardMetrics = action.payload;
      })
      .addCase(fetchDashboardMetrics.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // User analytics
      .addCase(fetchUserAnalytics.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchUserAnalytics.fulfilled, (state, action) => {
        state.isLoading = false;
        state.userAnalytics = action.payload;
      })
      .addCase(fetchUserAnalytics.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Content analytics
      .addCase(fetchContentAnalytics.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchContentAnalytics.fulfilled, (state, action) => {
        state.isLoading = false;
        state.contentAnalytics = action.payload;
      })
      .addCase(fetchContentAnalytics.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });
  },
});

export const { setDateRange, clearError } = analyticsSlice.actions;
export default analyticsSlice.reducer;
