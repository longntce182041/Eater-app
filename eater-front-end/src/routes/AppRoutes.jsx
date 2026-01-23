import React from "react";
import { Routes, Route, Navigate } from "react-router-dom";

import { DashboardPage } from "../pages/dashboard/DashboardPage";
import { UsersPage } from "../pages/users/UsersPage";
import { NutritionistsPage } from "../pages/nutritionists/NutritionistsPage";
import { RecipesPage } from "../pages/recipes/RecipesPage";
import { IngredientsPage } from "../pages/ingredients/IngredientsPage";
import { MicronutrientsPage } from "../pages/micronutrients/MicronutrientsPage";
import { KnowledgeBasePage } from "../pages/knowledgeBase/KnowledgeBasePage";
import { ReviewsModerationPage } from "../pages/moderation/ReviewsModerationPage";
import { InappropriateContentPage } from "../pages/moderation/InappropriateContentPage";
import { AnalyticsPage } from "../pages/analytics/AnalyticsPage";
import { LoginPage } from "../pages/auth/LoginPage";

export function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />

      <Route path="/" element={<DashboardPage />} />
      <Route path="/users" element={<UsersPage />} />
      <Route path="/nutritionists" element={<NutritionistsPage />} />
      <Route path="/recipes" element={<RecipesPage />} />
      <Route path="/ingredients" element={<IngredientsPage />} />
      <Route path="/micronutrients" element={<MicronutrientsPage />} />
      <Route path="/knowledge-base" element={<KnowledgeBasePage />} />
      <Route path="/moderation/reviews" element={<ReviewsModerationPage />} />
      <Route
        path="/moderation/inappropriate"
        element={<InappropriateContentPage />}
      />
      <Route path="/analytics" element={<AnalyticsPage />} />

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
