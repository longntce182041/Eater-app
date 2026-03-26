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
import { NutritionistScheduleManagement, ScheduleChangeRequests, MySchedule } from "../pages/nutritionist-schedules";
import ConsultationsPage from "../pages/consultations/index.jsx";
import NutritionistProfilePage from "../pages/nutritionists/index.jsx";

import AdminLayout from "../components/layout/AdminLayout.jsx"; 

// --- Component Bảo Vệ Nâng Cao (Check Token + Check Role) ---
const RoleProtectedRoute = ({ allowedRoles }) => {
    const token = localStorage.getItem("token");
    const userRole = localStorage.getItem("userRole"); 

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

            {/* --- KHU VỰC CHUNG (Admin & Nutritionist đều vào được Layout và Dashboard) --- */}
            <Route element={<RoleProtectedRoute allowedRoles={['admin', 'nutritionist']} />}>
                
                <Route path="/" element={<AdminLayout />}>
                    <Route index element={<Navigate to="/dashboard" replace />} />
                    <Route path="dashboard" element={<DashboardPage />} />

                    {/* --- KHU VỰC 1: CHỈ DÀNH CHO ADMIN --- */}
                    <Route element={<RoleProtectedRoute allowedRoles={['admin']} />}>
                        <Route path="users" element={<UsersPage />} />
                        <Route path="ingredients" element={<IngredientsPage />} />
                        <Route path="micronutrients" element={<MicronutrientsPage />} />
                        <Route path="recipes" element={<RecipesPage />} />
                        <Route path="reviews" element={<ReviewsPage />} />
                        <Route path="backups" element={<BackupsPage />} />
                        <Route path="admin/nutritionist-schedules" element={<NutritionistScheduleManagement />} />
                        <Route path="admin/schedule-requests" element={<ScheduleChangeRequests />} />
                    </Route>

                    {/* --- KHU VỰC 2: CHỈ DÀNH CHO NUTRITIONIST --- */}
                    {/* 👇 ĐÃ XÓA 'admin' KHỎI MẢNG NÀY */}
                    <Route element={<RoleProtectedRoute allowedRoles={['nutritionist']} />}>
                        <Route path="chat" element={<ChatPage />} />
                        <Route path="consultations" element={<ConsultationsPage />} />
                        <Route path="nutritionist/profile" element={<NutritionistProfilePage />} />
                        <Route path="nutritionist/my-schedule" element={<MySchedule />} />

                    </Route>
                </Route>
            </Route>

            <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
    );
}