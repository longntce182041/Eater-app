import { Routes, Route, Navigate } from 'react-router-dom';

import { MainLayout } from '@components/layout/MainLayout';
import { AuthLayout } from '@components/layout/AuthLayout';

// Auth pages
import { LoginPage } from '@pages/auth/LoginPage';

// Dashboard pages
import { DashboardPage } from '@pages/DashboardPage';

// User management pages
import { UsersListPage } from '@pages/users/UsersListPage';
import { UserDetailPage } from '@pages/users/UserDetailPage';

// Nutritionist management pages
import { NutritionistsListPage } from '@pages/nutritionists/NutritionistsListPage';
import { NutritionistDetailPage } from '@pages/nutritionists/NutritionistDetailPage';
import { NutritionistVerificationPage } from '@pages/nutritionists/NutritionistVerificationPage';

// Recipe management pages
import { RecipesListPage } from '@pages/recipes/RecipesListPage';
import { RecipeDetailPage } from '@pages/recipes/RecipeDetailPage';
import { RecipeFormPage } from '@pages/recipes/RecipeFormPage';

// Ingredient management pages
import { IngredientsListPage } from '@pages/ingredients/IngredientsListPage';
import { IngredientDetailPage } from '@pages/ingredients/IngredientDetailPage';

// Micronutrient management pages
import { MicronutrientsListPage } from '@pages/micronutrients/MicronutrientsListPage';
import { MicronutrientDetailPage } from '@pages/micronutrients/MicronutrientDetailPage';

// Knowledge base pages
import { KnowledgeBaseListPage } from '@pages/knowledge-base/KnowledgeBaseListPage';
import { KnowledgeBaseDetailPage } from '@pages/knowledge-base/KnowledgeBaseDetailPage';

// Reviews & moderation pages
import { ReviewsListPage } from '@pages/reviews/ReviewsListPage';
import { ReviewModerationPage } from '@pages/reviews/ReviewModerationPage';

// Analytics pages
import { AnalyticsOverviewPage } from '@pages/analytics/AnalyticsOverviewPage';
import { UserAnalyticsPage } from '@pages/analytics/UserAnalyticsPage';
import { ContentAnalyticsPage } from '@pages/analytics/ContentAnalyticsPage';

function App() {
  return (
    <Routes>
      {/* Auth routes */}
      <Route element={<AuthLayout />}>
        <Route path="/login" element={<LoginPage />} />
      </Route>

      {/* Protected admin routes */}
      <Route element={<MainLayout />}>
        {/* Dashboard */}
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={<DashboardPage />} />

        {/* User Management */}
        <Route path="/users" element={<UsersListPage />} />
        <Route path="/users/:id" element={<UserDetailPage />} />

        {/* Nutritionist Management */}
        <Route path="/nutritionists" element={<NutritionistsListPage />} />
        <Route path="/nutritionists/:id" element={<NutritionistDetailPage />} />
        <Route path="/nutritionists/verification" element={<NutritionistVerificationPage />} />

        {/* Recipe Management */}
        <Route path="/recipes" element={<RecipesListPage />} />
        <Route path="/recipes/new" element={<RecipeFormPage />} />
        <Route path="/recipes/:id" element={<RecipeDetailPage />} />
        <Route path="/recipes/:id/edit" element={<RecipeFormPage />} />

        {/* Ingredient Management */}
        <Route path="/ingredients" element={<IngredientsListPage />} />
        <Route path="/ingredients/:id" element={<IngredientDetailPage />} />

        {/* Micronutrient Management */}
        <Route path="/micronutrients" element={<MicronutrientsListPage />} />
        <Route path="/micronutrients/:id" element={<MicronutrientDetailPage />} />

        {/* Knowledge Base */}
        <Route path="/knowledge-base" element={<KnowledgeBaseListPage />} />
        <Route path="/knowledge-base/:id" element={<KnowledgeBaseDetailPage />} />

        {/* Reviews & Moderation */}
        <Route path="/reviews" element={<ReviewsListPage />} />
        <Route path="/reviews/moderation" element={<ReviewModerationPage />} />

        {/* Analytics */}
        <Route path="/analytics" element={<AnalyticsOverviewPage />} />
        <Route path="/analytics/users" element={<UserAnalyticsPage />} />
        <Route path="/analytics/content" element={<ContentAnalyticsPage />} />
      </Route>

      {/* 404 */}
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}

export default App;
