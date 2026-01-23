import { configureStore } from "@reduxjs/toolkit";
import authReducer from "./slices/authSlice.js";
import usersReducer from "./slices/usersSlice.js/index.js";
import nutritionistsReducer from "./slices/nutritionistsSlice.js/index.js";
import recipesReducer from "./slices/recipesSlice.js/index.js";
import ingredientsReducer from "./slices/ingredientsSlice.js/index.js";
import micronutrientsReducer from "./slices/micronutrientsSlice.js/index.js";
import knowledgeBaseReducer from "./slices/knowledgeBaseSlice.js/index.js";
import moderationReducer from "./slices/moderationSlice.js/index.js";
import analyticsReducer from "./slices/analyticsSlice.js/index.js";

export const store = configureStore({
  reducer: {
    auth: authReducer,
    users: usersReducer,
    nutritionists: nutritionistsReducer,
    recipes: recipesReducer,
    ingredients: ingredientsReducer,
    micronutrients: micronutrientsReducer,
    knowledgeBase: knowledgeBaseReducer,
    moderation: moderationReducer,
    analytics: analyticsReducer,
  },
});
