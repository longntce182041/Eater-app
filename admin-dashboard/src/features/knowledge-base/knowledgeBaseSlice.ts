import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { knowledgeBaseService } from '@services/knowledgeBaseService';
import type { KnowledgeArticle, KnowledgeBaseState } from '@types/knowledge-base';

const initialState: KnowledgeBaseState = {
  articles: [],
  categories: [],
  selectedArticle: null,
  totalCount: 0,
  currentPage: 1,
  pageSize: 20,
  isLoading: false,
  error: null,
};

// Async thunks
export const fetchArticles = createAsyncThunk(
  'knowledgeBase/fetchArticles',
  async (params: { page?: number; category?: string }, { rejectWithValue }) => {
    try {
      const response = await knowledgeBaseService.getArticles(params);
      return response;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch articles');
    }
  }
);

export const fetchCategories = createAsyncThunk(
  'knowledgeBase/fetchCategories',
  async (_, { rejectWithValue }) => {
    try {
      const categories = await knowledgeBaseService.getCategories();
      return categories;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch categories');
    }
  }
);

export const fetchArticleById = createAsyncThunk(
  'knowledgeBase/fetchArticleById',
  async (id: string, { rejectWithValue }) => {
    try {
      const article = await knowledgeBaseService.getArticleById(id);
      return article;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to fetch article');
    }
  }
);

export const createArticle = createAsyncThunk(
  'knowledgeBase/createArticle',
  async (data: Omit<KnowledgeArticle, 'id'>, { rejectWithValue }) => {
    try {
      const article = await knowledgeBaseService.createArticle(data);
      return article;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create article');
    }
  }
);

export const updateArticle = createAsyncThunk(
  'knowledgeBase/updateArticle',
  async ({ id, data }: { id: string; data: Partial<KnowledgeArticle> }, { rejectWithValue }) => {
    try {
      const article = await knowledgeBaseService.updateArticle(id, data);
      return article;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update article');
    }
  }
);

export const deleteArticle = createAsyncThunk(
  'knowledgeBase/deleteArticle',
  async (id: string, { rejectWithValue }) => {
    try {
      await knowledgeBaseService.deleteArticle(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete article');
    }
  }
);

const knowledgeBaseSlice = createSlice({
  name: 'knowledgeBase',
  initialState,
  reducers: {
    clearSelectedArticle: (state) => {
      state.selectedArticle = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch articles
      .addCase(fetchArticles.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchArticles.fulfilled, (state, action) => {
        state.isLoading = false;
        state.articles = action.payload.articles;
        state.totalCount = action.payload.totalCount;
      })
      .addCase(fetchArticles.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Fetch categories
      .addCase(fetchCategories.fulfilled, (state, action) => {
        state.categories = action.payload;
      })
      // Fetch by ID
      .addCase(fetchArticleById.fulfilled, (state, action) => {
        state.selectedArticle = action.payload;
      })
      // Create
      .addCase(createArticle.fulfilled, (state, action) => {
        state.articles.unshift(action.payload);
      })
      // Update
      .addCase(updateArticle.fulfilled, (state, action) => {
        const index = state.articles.findIndex((a) => a.id === action.payload.id);
        if (index !== -1) {
          state.articles[index] = action.payload;
        }
      })
      // Delete
      .addCase(deleteArticle.fulfilled, (state, action) => {
        state.articles = state.articles.filter((a) => a.id !== action.payload);
      });
  },
});

export const { clearSelectedArticle, clearError } = knowledgeBaseSlice.actions;
export default knowledgeBaseSlice.reducer;
