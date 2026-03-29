import React from "react";
import { Routes, Route, Navigate, Outlet } from "react-router-dom";

import DashboardPage from "../pages/dashboard";
import UsersPage from "../pages/users/index.jsx";
import IngredientsPage from "../pages/ingredients/index.jsx";
import MicronutrientsPage from "../pages/micronutrients/index.jsx";
import RecipesPage from "../pages/recipes/index.jsx";
import BackupsPage from "../pages/backups/index.jsx";
import ChatPage from "../pages/chat/index.jsx";
import LoginPage from "../pages/auth/index.jsx";
import ReviewsPage from "../pages/reviews/index.jsx";
import { NutritionistScheduleManagement, ScheduleChangeRequests, MySchedule } from "../pages/nutritionist-schedules";
import ConsultationsPage from "../pages/consultations/index.jsx";
import NutritionistsManagementPage from "../pages/nutritionists/index.jsx";
import NutritionistProfessionalProfilePage from "../pages/nutritionists/profile.jsx";
import NutritionistDashboardPage from "../pages/nutritionist-dashboard/index.jsx";

import AdminLayout from "../components/layout/AdminLayout.jsx";

const PrivateRoute = () => {
  const token = localStorage.getItem("token");

  if (!token) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
};

const RoleProtectedRoute = ({ allowedRoles }) => {
  const userRole = localStorage.getItem("userRole");

  if (!allowedRoles.includes(userRole)) {
    return <Navigate to="/dashboard" replace />;
  }

  return <Outlet />;
};

const RoleBasedHomeRedirect = () => {
  const userRole = localStorage.getItem("userRole");
  return (
    <Navigate
      to={userRole === "nutritionist" ? "/nutritionist/dashboard" : "/dashboard"}
      replace
    />
  );
};

export function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />

      <Route element={<PrivateRoute />}>
        <Route path="/" element={<AdminLayout />}>
          <Route index element={<RoleBasedHomeRedirect />} />

          {/* Dashboard tổng quan. Admin sẽ thấy block quản trị Nutritionist tại đây. */}
          <Route path="dashboard" element={<DashboardPage />} />

                    {/* --- KHU VỰC 1: CHỈ DÀNH CHO ADMIN --- */}
                    <Route element={<RoleProtectedRoute allowedRoles={['admin']} />}>
                        <Route path="users" element={<UsersPage />} />
                        <Route path="ingredients" element={<IngredientsPage />} />
                        <Route path="micronutrients" element={<MicronutrientsPage />} />
                        <Route path="recipes" element={<RecipesPage />} />
                        <Route path="reviews" element={<ReviewsPage />} />
                        <Route path="backups" element={<BackupsPage />} />
                      <Route path="admin/nutritionists" element={<NutritionistsManagementPage />} />
                        <Route path="admin/nutritionist-schedules" element={<NutritionistScheduleManagement />} />
                        <Route path="admin/schedule-requests" element={<ScheduleChangeRequests />} />
                    </Route>

                    {/* --- KHU VỰC 2: CHỈ DÀNH CHO NUTRITIONIST --- */}
                    {/* 👇 ĐÃ XÓA 'admin' KHỎI MẢNG NÀY */}
                    <Route element={<RoleProtectedRoute allowedRoles={['nutritionist']} />}>
                        {/* Dashboard hồ sơ cho nutritionist tự quản lý thông tin chuyên môn */}
                        <Route path="nutritionist/dashboard" element={<NutritionistDashboardPage />} />
                        <Route path="chat" element={<ChatPage />} />
                        <Route path="consultations" element={<ConsultationsPage />} />
                      <Route path="nutritionist/profile" element={<NutritionistProfessionalProfilePage />} />
                        <Route path="nutritionist/my-schedule" element={<MySchedule />} />

                    </Route>
                </Route>
            </Route>

      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}
