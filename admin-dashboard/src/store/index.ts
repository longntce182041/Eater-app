import { configureStore } from '@reduxjs/toolkit';

import authReducer from '@features/auth/authSlice';
import usersReducer from '@features/users/usersSlice';
import nutritionistsReducer from '@features/nutritionists/nutritionistsSlice';
import recipesReducer from '@features/recipes/recipesSlice';
import ingredientsReducer from '@features/ingredients/ingredientsSlice';
import micronutrientsReducer from '@features/micronutrients/micronutrientsSlice';
import knowledgeBaseReducer from '@features/knowledge-base/knowledgeBaseSlice';
import reviewsReducer from '@features/reviews/reviewsSlice';
import analyticsReducer from '@features/analytics/analyticsSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    users: usersReducer,
    nutritionists: nutritionistsReducer,
    recipes: recipesReducer,
    ingredients: ingredientsReducer,
    micronutrients: micronutrientsReducer,
    knowledgeBase: knowledgeBaseReducer,
    reviews: reviewsReducer,
    analytics: analyticsReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        // Ignore these action types
        ignoredActions: ['persist/PERSIST', 'persist/REHYDRATE'],
      },
    }),
  devTools: process.env.NODE_ENV !== 'production',
});

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
