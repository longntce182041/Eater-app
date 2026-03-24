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

// Import Layout (Cái khung sidebar)
import AdminLayout from "../components/layout/AdminLayout";


// --- 1. Tạo Component Bảo Vệ (Chặn người chưa login) ---
const PrivateRoute = () => {
    // Kiểm tra token trong localStorage (lúc login xong đã lưu)
    const token = localStorage.getItem("token");

    // Nếu có token -> Cho đi tiếp (Outlet), Nếu không -> Đá về /login
    return token ? <Outlet /> : <Navigate to="/login" replace />;
};

export function AppRoutes() {
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

                    {/* Nutritionist Schedule Management */}
                    <Route path="admin/nutritionist-schedules" element={<NutritionistScheduleManagement />} />
                    <Route path="admin/schedule-requests" element={<ScheduleChangeRequests />} />
                    <Route path="nutritionist/my-schedule" element={<MySchedule />} />

                    {/* Các route khác thêm vào đây */}
                </Route>

            </Route>

            {/* Route sai -> Về Login */}
            <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
    );
}