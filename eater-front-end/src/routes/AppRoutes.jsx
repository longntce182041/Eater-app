import React from "react";
import { Routes, Route, Navigate, Outlet } from "react-router-dom";

// Import các trang
import DashboardPage from "../pages/dashboard";
import UsersPage from "../pages/users/index.jsx";
import IngredientsPage from "../pages/ingredients/index.jsx";
import MicronutrientsPage from "../pages/micronutrients/index.jsx";
import RecipesPage from "../pages/recipes/index.jsx";
import BackupsPage from "../pages/backups/index.jsx";
import ChatPage from "../pages/chat/index.jsx";
import LoginPage from "../pages/auth/index.jsx";
import ReviewsPage from "../pages/reviews/index.jsx";
import ConsultationsPage from "../pages/consultations/index.jsx";

import AdminLayout from "../components/layout/AdminLayout.jsx"; 
import NutritionistsPage from "../pages/nutritionists/index.jsx";

// Import Layout (Cái khung sidebar)
import AdminLayout from "../components/layout/AdminLayout";

// --- Component Bảo Vệ Nâng Cao (Check Token + Check Role) ---
const RoleProtectedRoute = ({ allowedRoles }) => {
    const token = localStorage.getItem("token");
    const userRole = localStorage.getItem("userRole"); 
// --- 1. Tạo Component Bảo Vệ (Chặn người chưa login) ---
const PrivateRoute = () => {
  // Kiểm tra token trong localStorage (lúc login xong đã lưu)
  const token = localStorage.getItem("token");

  if (!token) {
      return <Navigate to="/login" replace />;
    }

    // Nếu Role của user KHÔNG CÓ trong danh sách cho phép -> Đá về trang chủ của họ
    if (!allowedRoles.includes(userRole)) {
        return <Navigate to="/dashboard" replace />;
    }

    return <Outlet />;
};

export function AppRoutes() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />
  return (
    <Routes>
      {/* Route Login (Ai cũng vào được) */}
      <Route path="/login" element={<LoginPage />} />

            {/* --- 2. Khu vực Admin (Phải Login mới vào được) --- */}
            <Route element={<PrivateRoute />}>

                {/* Bọc trong AdminLayout để có Sidebar */}
                <Route path="/" element={<AdminLayout />}>

                    {/* Mặc định vào / thì nhảy sang dashboard */}
                    <Route index element={<Navigate to="/dashboard" replace />} />

                    {/* Các trang con sẽ hiện ở giữa màn hình */}
                    <Route path="dashboard" element={<DashboardPage />} />
                    <Route path="users" element={<UsersPage />} />
                    <Route path="ingredients" element={<IngredientsPage />} />
                    <Route path="micronutrients" element={<MicronutrientsPage />} />
                    <Route path="recipes" element={<RecipesPage />} />
                    <Route path="reviews" element={<ReviewsPage />} />
                    <Route path="backups" element={<BackupsPage />} />
                    <Route path="chat" element={<ChatPage />} />

                    {/* Các route khác thêm vào đây */}
                </Route>

            </Route>

      {/* Route sai -> Về Login */}
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}
