/**
 * 📊 ADMIN DASHBOARD PAGE
 *
 * Main dashboard for admin analytics overview
 * Displays KPIs, user registration trends, and top recipes
 *
 * Features:
 * - ✅ User statistics (total, pro, nutritionists)
 * - ✅ Content metrics (recipes in library)
 * - ✅ User registration trend chart (6-month history)
 * - ✅ Top recipes by popularity ranking
 * - ✅ Nutritionist management shortcuts
 * - ✅ Loading states and error handling
 * - ✅ Role-based content visibility (admin/nutritionist)
 *
 * Data Sources:
 * 1. Users API - GET /users (all users, pro users, nutritionists)
 * 2. Recipes API - GET /recipes (all recipes)
 * 3. Chat API - GET /chat/contacts (conversation count)
 * 4. Analytics API - GET /analytics/overview (trends and top recipes)
 *
 * State:
 * - statsLoading: Loading indicator for KPI cards
 * - stats: {totalUsers, proUsers, nutritionists, recipes, chatContacts}
 * - registrationTrend: Array of {name, registrations} for 6-month chart
 * - registrationSource: Where trend data comes from (API or fallback)
 * - topRecipes: Array of {name, favorites, reviewCount, avgRating}
 * - topRecipesSource: Where recipe data comes from
 *
 * Layout:
 * ```
 * ┌─────────────────────────────────────────────┐
 * │ Admin Analytics Overview                    │
 * │                                             │
 * │ ┌──────────┐ ┌──────────┐ ┌──────────┐    │
 * │ │ 1,234    │ │ 456      │ │ 890      │    │ Stats Cards
 * │ │ USERS    │ │ PRO      │ │ RECIPES  │    │
 * │ └──────────┘ └──────────┘ └──────────┘    │
 * │                                             │
 * │ [Schedule Management] [Change Requests]    │ Nutrition mgmt
 * │                                             │
 * │ ┌─────────────────────────────────────┐   │
 * │ │ User Registrations (Last 6 Months)  │   │ Trend chart
 * │ │ [Area Chart with 6 month bars]      │   │
 * │ └─────────────────────────────────────┘   │
 * │                                             │
 * │ ┌─────────────────────────────────────┐   │
 * │ │ Top Recipes by Popularity           │   │ Top recipes table
 * │ │ [Recipe | Favorites | Reviews]      │   │
 * │ └─────────────────────────────────────┘   │
 * └─────────────────────────────────────────────┘
 * ```
 */

import React, { useEffect, useState } from 'react';
import { Users, Crown, Stethoscope, Utensils, MessageCircle, Calendar, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import {
    AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

import StatsWidget from '../../features/dashboard/components/StatsWidget';
import axiosClient from '../../api/axiosClient';

/**
 * 📈 BUILD MONTHLY REGISTRATION DATA
 *
 * Converts user list to monthly registration trend
 * Aggregates user creation dates into monthly buckets
 *
 * Process:
 * 1. Generate array of previous N months
 * 2. Initialize count for each month to 0
 * 3. Parse each user's createdAt date
 * 4. Increment month bucket for that user
 * 5. Return array of {month, registrations}
 *
 * @param {Array} users - List of user objects with createdAt/created_at
 * @param {number} months - Number of months to go back (default: 6)
 * @returns {Array} - Array of {name: "Jan", registrations: 45}
 *
 * Example:
 * ```javascript
 * const users = [
 *   { _id: 1, createdAt: '2024-01-15' },
 *   { _id: 2, createdAt: '2024-01-20' },
 *   { _id: 3, createdAt: '2024-02-05' },
 * ];
 * const trend = buildMonthlyRegistrationData(users, 3);
 * // Result: [
 * //   { name: "Dec", registrations: 0 },
 * //   { name: "Jan", registrations: 2 },
 * //   { name: "Feb", registrations: 1 }
 * // ]
 * ```
 */
const buildMonthlyRegistrationData = (users = [], months = 6) => {
    const now = new Date();
    const monthKeys = [];           // Array like ["2024-0", "2024-1", ...]
    const monthLabelMap = new Map(); // Map {"2024-0" → "Jan"}
    const monthCounts = {};          // {2024-0: 0, 2024-1: 0, ...}

    /**
     * 📅 Generate month buckets
     *
     * Goes back N months from today
     * Creates keys and human-readable labels
     */
    for (let i = months - 1; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        const key = `${d.getFullYear()}-${d.getMonth()}`;
        monthKeys.push(key);
        monthLabelMap.set(key, d.toLocaleDateString('en-US', { month: 'short' }));  // "Jan", "Feb", ...
        monthCounts[key] = 0;
    }

    /**
     * 📊 Aggregate users into months
     *
     * For each user, parse their createdAt date
     * Increment the corresponding month bucket
     */
    users.forEach((user) => {
        const createdAt = user?.createdAt || user?.created_at;
        if (!createdAt) return;  // Skip users without date

        const createdDate = new Date(createdAt);
        if (Number.isNaN(createdDate.getTime())) return;  // Skip invalid dates

        const key = `${createdDate.getFullYear()}-${createdDate.getMonth()}`;
        if (Object.prototype.hasOwnProperty.call(monthCounts, key)) {
            monthCounts[key] += 1;  // Increment this month's count
        }
    });

    /**
     * 🔄 Format for chart display
     *
     * Convert {month-count} pairs to recharts format
     * Returns array of {name: "Jan", registrations: 45}
     */
    return monthKeys.map((key) => ({
        name: monthLabelMap.get(key),
        registrations: monthCounts[key],
    }));
};

/**
 * 🏆 GET TOP RECIPES FROM LIST
 *
 * Sorts recipes by rating and returns top N
 * Extracts format for display in table
 *
 * @param {Array} recipes - Recipe objects with rating/reviews data
 * @param {number} limit - Max recipes to return (default: 5)
 * @returns {Array} - Sorted recipes with extracted fields
 *
 * Example:
 * ```javascript
 * const recipes = [
 *   { _id: 1, name: "Salad", rating: 4.2 },
 *   { _id: 2, name: "Pasta", rating: 4.8 },
 * ];
 * const top = pickTopRecipesFromList(recipes, 2);
 * // All sorted by rating descending
 * ```
 */
const pickTopRecipesFromList = (recipes = [], limit = 5) => {
    if (!Array.isArray(recipes)) return [];

    return recipes
        .slice()  // Copy array
        .sort((a, b) => (Number(b?.rating) || 0) - (Number(a?.rating) || 0))  // Sort by rating DESC
        .slice(0, limit)  // Take top N
        .map((recipe) => ({
            recipeId: recipe?._id,
            name: recipe?.name || '-',
            favorites: Number(recipe?.favorites || recipe?.favoriteCount || recipe?.totalFavorites || 0),
            reviewCount: Number(recipe?.reviewCount || recipe?.reviewsCount || recipe?.totalReviews || 0),
            avgRating: Number(recipe?.avgRating || recipe?.rating || 0),
        }));
};

/**
 * 📡 EXTRACT TOP RECIPES FROM ANALYTICS API
 *
 * Safely extract recipe data from API response
 * Handles nested response structure variations
 *
 * @param {Object} response - API response object
 * @returns {Array} - Top recipes array or empty array
 */
const extractTopRecipesFromAnalytics = (response) => {
    const payload = response?.data?.data || response?.data || null;
    const recipes = payload?.recipePopularity?.topRecipes || payload?.topRecipes || null;
    return Array.isArray(recipes) ? recipes : [];
};

/**
 * 👥 EXTRACT USERS FROM API RESPONSE
 *
 * Safely parse users array and total count
 * Handles multiple response format variations
 *
 * @param {Object} response - API response object
 * @returns {Object} - {users: [], total: 0}
 */
const extractUsersPayload = (response) => {
    const payload = response?.data?.data || response?.data || {};
    const users = Array.isArray(payload?.users)
        ? payload.users
        : Array.isArray(payload)
            ? payload
            : [];

    const total = Number(payload?.total ?? payload?.count ?? users.length) || 0;

    return { users, total };
};

/**
 * 🍽️ EXTRACT RECIPES FROM API RESPONSE
 *
 * Safely parse recipes array and total count
 *
 * @param {Object} response - API response object
 * @returns {Object} - {recipes: [], total: 0}
 */
const extractRecipesPayload = (response) => {
    const payload = response?.data?.data || response?.data || {};
    const recipes = Array.isArray(payload?.recipes)
        ? payload.recipes
        : Array.isArray(payload)
            ? payload
            : [];

    const total = Number(payload?.total ?? payload?.count ?? recipes.length) || 0;

    return { recipes, total };
};

/**
 * 📊 EXTRACT REGISTRATION TREND FROM ANALYTICS API
 *
 * Safely extract monthly registration trend data
 * Handles API response variations
 *
 * @param {Object} response - API response object
 * @returns {Array} - Array of {name: "Jan", registrations: 45}
 */
const extractRegistrationTrendFromAnalytics = (response) => {
    const payload = response?.data?.data || response?.data || {};
    const points = payload?.trends?.monthlyRegistrations || payload?.monthlyRegistrations || [];

    if (!Array.isArray(points)) return [];

    return points.map((item) => ({
        name: item?.month || item?.name || '-',
        registrations: Number(item?.value ?? item?.registrations ?? 0) || 0,
    }));
};

/**
 * 📊 DASHBOARD PAGE COMPONENT
 *
 * Main admin dashboard with analytics overview
 */
const DashboardPage = () => {
    const navigate = useNavigate();

    /**
     * 🔐 CHECK USER ROLE
     *
     * Determine what content to show based on role
     */
    const userRole = localStorage.getItem('userRole');
    const isAdmin = userRole === 'admin';
    const isNutritionist = userRole === 'nutritionist';

    /**
     * 📊 STATE: STATISTICS
     *
     * Tracks KPI card data and loading state
     */
    const [statsLoading, setStatsLoading] = useState(true);
    const [stats, setStats] = useState({
        totalUsers: 0,        // All registered users
        proUsers: 0,          // Users with pro subscription
        nutritionists: 0,     // Registered nutritionists
        recipes: 0,           // Total recipes in library
        chatContacts: 0,      // Total conversations
    });

    /**
     * 📈 STATE: REGISTRATION TREND
     *
     * Tracks 6-month user registration trend
     * Format: [{name: "Jan", registrations: 45}, ...]
     */
    const [registrationTrend, setRegistrationTrend] = useState([]);
    const [registrationSource, setRegistrationSource] = useState('N/A');  // Where data came from

    /**
     * 🏆 STATE: TOP RECIPES
     *
     * Tracks top rated/popular recipes
     * Format: [{name, favorites, reviewCount, avgRating}, ...]
     */
    const [topRecipes, setTopRecipes] = useState([]);
    const [topRecipesSource, setTopRecipesSource] = useState('N/A');  // Where data came from

    /**
     * 🔄 FETCH DASHBOARD DATA
     *
     * Runs on component mount
     * Fetches all dashboard data in parallel with Promise.allSettled
     * (continues even if some requests fail)
     *
     * Requests:
     * 1. All users (limit 1000)
     * 2. Pro users only
     * 3. Nutritionists
     * 4. All recipes
     * 5. Chat contacts
     * 6. Analytics overview
     *
     * Data Flow:
     * 1. Parallel requests for all data
     * 2. Extract/parse responses (handle errors gracefully)
     * 3. Build registration trend (use API data or fallback)
     * 4. Get top recipes (use API data or fallback)
     * 5. Update state with results
     */
    useEffect(() => {
        let isMounted = true;  // Prevent state updates if component unmounts

        const fetchDashboardData = async () => {
            setStatsLoading(true);

            try {
                /**
                 * 🚀 PARALLEL API REQUESTS
                 *
                 * Fetch all data simultaneously
                 * Use allSettled so one failure doesn't block others
                 */
                const requests = [
                    axiosClient.get('/users', { params: { role: 'user', limit: 1000 } }),
                    axiosClient.get('/users', { params: { role: 'user', proOnly: true, limit: 1 } }),
                    axiosClient.get('/users', { params: { role: 'nutritionist', limit: 1 } }),
                    axiosClient.get('/recipes', { params: { limit: 100 } }),
                    axiosClient.get('/chat/contacts'),
                    axiosClient.get('/analytics/overview'),
                ];

                const results = await Promise.allSettled(requests);
                if (!isMounted) return;

                /**
                 * 📦 DESTRUCTURE RESULTS
                 *
                 * Results are promises - check status before using
                 */
                const [
                    usersRes,
                    proUsersRes,
                    nutritionistsRes,
                    recipesRes,
                    contactsRes,
                    analyticsRes,
                ] = results;

                /**
                 * 👥 PROCESS USERS DATA
                 *
                 * Extract user list and count from API response
                 */
                const usersPayload = usersRes.status === 'fulfilled'
                    ? extractUsersPayload(usersRes.value)
                    : { users: [], total: 0 };
                const allUsers = usersPayload.users;

                /**
                 * 🍽️ PROCESS RECIPES DATA
                 *
                 * Extract recipe list and count
                 */
                const recipesPayload = recipesRes.status === 'fulfilled'
                    ? extractRecipesPayload(recipesRes.value)
                    : { recipes: [], total: 0 };

                /**
                 * 📈 PROCESS ANALYTICS DATA
                 *
                 * Extract registration trend from analytics API
                 */
                const analyticsRegistrationTrend = analyticsRes.status === 'fulfilled'
                    ? extractRegistrationTrendFromAnalytics(analyticsRes.value)
                    : [];

                /**
                 * 📊 UPDATE KPI STATS
                 *
                 * Set all metric cards
                 */
                setStats({
                    totalUsers: usersPayload.total,
                    proUsers: proUsersRes.status === 'fulfilled' ? (proUsersRes.value?.data?.data?.total || 0) : 0,
                    nutritionists: nutritionistsRes.status === 'fulfilled' ? (nutritionistsRes.value?.data?.data?.total || 0) : 0,
                    recipes: recipesPayload.total,
                    chatContacts: contactsRes.status === 'fulfilled' ? (contactsRes.value?.data?.data?.length || 0) : 0,
                });

                /**
                 * 📈 UPDATE REGISTRATION TREND
                 *
                 * Use analytics API data if available
                 * Otherwise build from user creation dates
                 */
                setRegistrationTrend(
                    analyticsRegistrationTrend.length > 0
                        ? analyticsRegistrationTrend
                        : buildMonthlyRegistrationData(allUsers, 6),
                );
                setRegistrationSource(
                    analyticsRegistrationTrend.length > 0
                        ? 'Analytics Overview API'
                        : 'Users API (createdAt rollup)',
                );

                /**
                 * 🏆 UPDATE TOP RECIPES
                 *
                 * Use analytics API data if available
                 * Otherwise use recipes API data sorted by rating
                 */
                const analyticsTopRecipes = analyticsRes.status === 'fulfilled'
                    ? extractTopRecipesFromAnalytics(analyticsRes.value)
                    : [];

                const resolvedTopRecipes = analyticsTopRecipes.length > 0
                    ? analyticsTopRecipes
                    : pickTopRecipesFromList(recipesPayload.recipes, 5);

                setTopRecipes(resolvedTopRecipes);
                setTopRecipesSource(
                    analyticsTopRecipes.length > 0
                        ? 'Analytics Overview API'
                        : 'Recipes API (rating sort)',
                );
            } catch {
                // Error handling - continue with empty data
                if (!isMounted) return;
                setTopRecipes([]);
                setTopRecipesSource('N/A');
                setRegistrationSource('N/A');
            } finally {
                // Stop loading spinner
                if (!isMounted) return;
                setStatsLoading(false);
            }
        };

        fetchDashboardData();

        /**
         * 🧹 CLEANUP
         *
         * Prevent memory leak if component unmounts
         */
        return () => {
            isMounted = false;
        };
    }, []);  // Run once on mount

    /**
     * 🎴 STAT CARD CONFIGURATION
     *
     * List of KPI cards to display
     * Each card has: title, count, icon, color, visibility flag
     */
    const statCards = [
        {
            title: 'Registered Users',
            count: stats.totalUsers,
            color: '#30a5ff',
            icon: <Users size={24} />,
            show: true,  // Always show
        },
        {
            title: 'Active Pro Users',
            count: stats.proUsers,
            color: '#ffb53e',
            icon: <Crown size={24} />,
            show: true,
        },
        {
            title: 'Nutritionists',
            count: stats.nutritionists,
            color: '#1ebfae',
            icon: <Stethoscope size={24} />,
            show: isAdmin,  // Only admins see nutritionist count
        },
        {
            title: 'Recipes in Library',
            count: stats.recipes,
            color: '#8e44ad',
            icon: <Utensils size={24} />,
            show: true,
        },

    ].filter((card) => card.show);  // Filter out hidden cards based on role

    return (
        <div>
            {/* ═══ PAGE HEADER ═══ */}
            <h2 style={{ fontSize: '24px', marginBottom: '25px', color: '#30a5ff', fontWeight: 600 }}>
                Admin Analytics Overview
            </h2>

            <p style={{ marginBottom: '20px', color: '#666', fontSize: '14px' }}>
                Centralized overview for users, subscriptions, consultations and nutrition workflow.
            </p>

            {/* ═══ KPI STAT CARDS ═══ */}
            <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', marginBottom: '30px' }}>
                {statCards.map((card) => (
                    <StatsWidget
                        key={card.title}
                        title={card.title}
                        count={statsLoading ? '...' : card.count}  // Show loading spinner while fetching
                        color={card.color}
                        icon={card.icon}
                    />
                ))}
            </div>

            {/* ═══ NUTRITION MANAGEMENT SECTION ═══ */}
            {(isAdmin || isNutritionist) && (
                <div style={{ marginBottom: '30px' }}>
                    <h3 style={{ marginBottom: '15px' }}>Nutritionist Management</h3>

                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '15px' }}>
                        {/* Navigate to nutritionist schedules */}
                        <div
                            onClick={() => navigate('/admin/nutritionist-schedules')}
                            style={{
                                background: 'linear-gradient(135deg, #667eea, #764ba2)',
                                padding: '20px',
                                borderRadius: '8px',
                                cursor: 'pointer',
                                color: 'white',
                            }}
                        >
                            <Calendar size={28} />
                            <h4>Schedule Management</h4>
                        </div>

                        {/* Navigate to schedule change requests */}
                        <div
                            onClick={() => navigate('/admin/schedule-requests')}
                            style={{
                                background: 'linear-gradient(135deg, #f093fb, #f5576c)',
                                padding: '20px',
                                borderRadius: '8px',
                                cursor: 'pointer',
                                color: 'white',
                            }}
                        >
                            <Clock size={28} />
                            <h4>Change Requests</h4>
                        </div>
                    </div>
                </div>
            )}

            {/* ═══ USER REGISTRATION TREND CHART ═══ */}
            <div style={{ background: 'white', padding: '25px', borderRadius: '8px', marginBottom: '24px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <h3 style={{ margin: 0 }}>User Registrations (Last 6 Months)</h3>
                    <span style={{ color: '#667085', fontSize: '12px' }}>
                        Source: {registrationSource}  {/* Show where data came from */}
                    </span>
                </div>

                {/* Area chart showing registration trend */}
                <div style={{ width: '100%', height: 360 }}>
                    <ResponsiveContainer>
                        <AreaChart data={registrationTrend}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="name" />  {/* Month names: Jan, Feb, ... */}
                            <YAxis />                 {/* Registration count */}
                            <Tooltip />
                            <Area
                                type="monotone"
                                dataKey="registrations"  {/* Data to visualize */}
                                stroke="#30a5ff"         {/* Line color */}
                                fill="#30a5ff"          {/* Fill color */}
                            />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>

            {/* ═══ TOP RECIPES TABLE ═══ */}
            <div
                style={{
                    background: 'white',
                    padding: '25px',
                    borderRadius: '8px',
                    boxShadow: '0 2px 10px rgba(0,0,0,0.05)',
                }}
            >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                    <h3 style={{ margin: 0, color: '#5f6468', fontSize: '18px' }}>
                        Top Recipes by Popularity
                    </h3>
                    <span style={{ color: '#667085', fontSize: '12px' }}>
                        Source: {topRecipesSource}  {/* Show where data came from */}
                    </span>
                </div>

                {/* Recipes table */}
                <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        {/* Table header */}
                        <thead>
                            <tr style={{ textAlign: 'left', borderBottom: '1px solid #eee', color: '#667085' }}>
                                <th style={{ padding: '10px 8px' }}>Recipe</th>
                                <th style={{ padding: '10px 8px' }}>Favorites</th>
                                <th style={{ padding: '10px 8px' }}>Reviews</th>
                                <th style={{ padding: '10px 8px' }}>Avg Rating</th>
                            </tr>
                        </thead>

                        {/* Table body */}
                        <tbody>
                            {topRecipes.length === 0 && !statsLoading ? (
                                <tr>
                                    <td style={{ padding: '14px 8px', color: '#667085' }} colSpan={4}>
                                        No popularity data available yet.
                                    </td>
                                </tr>
                            ) : (
                                topRecipes.map((item) => (
                                    <tr key={item.recipeId || item._id || item.name} style={{ borderBottom: '1px solid #f2f4f7' }}>
                                        <td style={{ padding: '12px 8px', color: '#344054' }}>{item.name || '-'}</td>
                                        <td style={{ padding: '12px 8px', color: '#344054' }}>{item.favorites || 0}</td>
                                        <td style={{ padding: '12px 8px', color: '#344054' }}>{item.reviewCount || 0}</td>
                                        <td style={{ padding: '12px 8px', color: '#344054' }}>{item.avgRating || 0}</td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default DashboardPage;