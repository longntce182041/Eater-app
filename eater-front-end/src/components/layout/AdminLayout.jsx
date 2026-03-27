import React from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, Utensils, Pill, LogOut, CloudUpload, BookOpen, MessageCircle, Star, Stethoscope, CalendarDays, RefreshCcw, UserCog } from 'lucide-react';
import './AdminLayout.css';
import React from "react";
import { Outlet, NavLink, useNavigate } from "react-router-dom";
import {
  LayoutDashboard,
  Users,
  Utensils,
  Pill,
  LogOut,
  CloudUpload,
  BookOpen,
  MessageCircle,
  Star,
  Stethoscope,
} from "lucide-react";
import "./AdminLayout.css";

const AdminLayout = () => {
  const navigate = useNavigate();
  const userRole = localStorage.getItem("userRole");
  const isNutritionist = userRole === "nutritionist";

  const handleLogout = () => {
    localStorage.clear(); // Xóa sạch token
    navigate("/login");
  };

    const adminMenuItems = [
        { name: 'Dashboard', path: '/dashboard', icon: <LayoutDashboard size={20} /> },
        { name: 'Manage Users', path: '/users', icon: <Users size={20} /> },
        { name: 'Manage Ingredients', path: '/ingredients', icon: <Utensils size={20} /> },
        { name: 'Manage Micronutrients', path: '/micronutrients', icon: <Pill size={20} /> },
        { name: 'Manage Recipes', path: '/recipes', icon: <BookOpen size={20} /> },
        { name: 'Manage Reviews', path: '/reviews', icon: <Star size={20} /> },
        { name: 'System Backups', path: '/backups', icon: <CloudUpload size={20} /> },
        { name: 'Manage Nutritionists', path: '/admin/nutritionists', icon: <UserCog size={20} /> },
        
    ];

    const nutritionistMenuItems = [
        { name: 'Live Chat', path: '/chat', icon: <MessageCircle size={20} /> },
        { name: 'Consultations', path: '/consultations', icon: <Stethoscope size={20}/>, roles: ['nutritionist'] },
        { name: 'Professional Profile', path: '/nutritionist/profile', icon: <UserCog size={20} /> },
        { name: 'View Work Schedule', path: '/nutritionist/my-schedule?tab=schedule', icon: <CalendarDays size={20} /> },
        
    ];
  const adminMenuItems = [
    {
      name: "Dashboard",
      path: "/dashboard",
      icon: <LayoutDashboard size={20} />,
    },
    { name: "Manage Users", path: "/users", icon: <Users size={20} /> },
    {
      name: "Manage Ingredients",
      path: "/ingredients",
      icon: <Utensils size={20} />,
    },
    {
      name: "Manage Micronutrients",
      path: "/micronutrients",
      icon: <Pill size={20} />,
    },
    { name: "Manage Recipes", path: "/recipes", icon: <BookOpen size={20} /> },
    { name: "Manage Reviews", path: "/reviews", icon: <Star size={20} /> },
    {
      name: "System Backups",
      path: "/backups",
      icon: <CloudUpload size={20} />,
    },
  ];

  const nutritionistMenuItems = [
    { name: "Live Chat", path: "/chat", icon: <MessageCircle size={20} /> },
    {
      name: "Consultations",
      path: "/consultations",
      icon: <Stethoscope size={20} />,
      roles: ["nutritionist"],
    },
  ];

  const menuItems = isNutritionist ? nutritionistMenuItems : adminMenuItems;

  return (
    <div className="admin-container">
      {/* SIDEBAR */}
      <aside className="sidebar">
        <div className="sidebar-header">
          EATER <span>{isNutritionist ? "PORTAL" : "ADMIN"}</span>
        </div>
        <div className="profile-section">
          <div className="profile-img"></div>
          <div className="profile-name">
            {isNutritionist ? "Nutritionist" : "Admin"}
          </div>
        </div>
        <ul className="nav-menu">
          {menuItems.map((item, index) => (
            <li key={index}>
              <NavLink
                to={item.path}
                className={({ isActive }) =>
                  isActive ? "nav-item active" : "nav-item"
                }
              >
                <span className="nav-icon">{item.icon}</span>
                {item.name}
              </NavLink>
            </li>
          ))}
          <li onClick={handleLogout} className="nav-item logout-btn">
            <span className="nav-icon">
              <LogOut size={20} />
            </span>{" "}
            Logout
          </li>
        </ul>
      </aside>

      {/* CONTENT Ở GIỮA */}
      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
};

export default AdminLayout;
