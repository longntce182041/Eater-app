import React from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, Utensils, Pill, LogOut, CloudUpload } from 'lucide-react';
import './AdminLayout.css';

const AdminLayout = () => {
    const navigate = useNavigate();

    const handleLogout = () => {
        localStorage.clear(); // Xóa sạch token
        navigate('/login');
    };

    const menuItems = [
        { name: 'Dashboard', path: '/dashboard', icon: <LayoutDashboard size={20}/> },
        { name: 'Manage Users', path: '/users', icon: <Users size={20}/> },
        { name: 'Manage Ingredients', path: '/ingredients', icon: <Utensils size={20}/> },
        { name: 'Manage Micronutrients', path: '/micronutrients', icon: <Pill size={20}/> },
        { name: 'System Backups', path: '/backups', icon: <CloudUpload size={20}/> },
    ];

    return (
        <div className="admin-container">
            {/* SIDEBAR */}
            <aside className="sidebar">
                <div className="sidebar-header">EATER <span>ADMIN</span></div>
                <div className="profile-section">
                    <div className="profile-img"></div>
                    <div className="profile-name">Admin</div>
                </div>
                <ul className="nav-menu">
                    {menuItems.map((item, index) => (
                        <li key={index}>
                            <NavLink to={item.path} className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
                                <span className="nav-icon">{item.icon}</span>
                                {item.name}
                            </NavLink>
                        </li>
                    ))}
                    <li onClick={handleLogout} className="nav-item logout-btn">
                        <span className="nav-icon"><LogOut size={20}/></span> Logout
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