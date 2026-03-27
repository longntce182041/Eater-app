import React, { useEffect, useState } from 'react';
import { Users, Crown, Stethoscope, Utensils, MessageCircle, Calendar, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import {
    AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

import StatsWidget from '../../features/dashboard/components/StatsWidget';
import MacroDistributionCard from '../../features/dashboard/components/MacroDistributionCard';
import axiosClient from '../../api/axiosClient';

const buildMonthlyRegistrationData = (users = [], months = 6) => {
    const now = new Date();
    const monthKeys = [];
    const monthLabelMap = new Map();
    const monthCounts = {};

    for (let i = months - 1; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        const key = `${d.getFullYear()}-${d.getMonth()}`;
        monthKeys.push(key);
        monthLabelMap.set(key, d.toLocaleDateString('en-US', { month: 'short' }));
        monthCounts[key] = 0;
    }

    users.forEach((user) => {
        const createdAt = user?.createdAt || user?.created_at;
        if (!createdAt) return;

        const createdDate = new Date(createdAt);
        if (Number.isNaN(createdDate.getTime())) return;

        const key = `${createdDate.getFullYear()}-${createdDate.getMonth()}`;
        if (Object.prototype.hasOwnProperty.call(monthCounts, key)) {
            monthCounts[key] += 1;
        }
    });

    return monthKeys.map((key) => ({
        name: monthLabelMap.get(key),
        registrations: monthCounts[key],
    }));
};

const pickTopRecipesFromList = (recipes = [], limit = 5) => {
    if (!Array.isArray(recipes)) return [];

    return recipes
        .slice()
        .sort((a, b) => (Number(b?.rating) || 0) - (Number(a?.rating) || 0))
        .slice(0, limit)
        .map((recipe) => ({
            recipeId: recipe?._id,
            name: recipe?.name || '-',
            favorites: Number(recipe?.favorites || recipe?.favoriteCount || recipe?.totalFavorites || 0),
            reviewCount: Number(recipe?.reviewCount || recipe?.reviewsCount || recipe?.totalReviews || 0),
            avgRating: Number(recipe?.avgRating || recipe?.rating || 0),
        }));
};

const extractMacroDistribution = (response) => (
    response?.data?.data?.summary?.macroDistribution
    || response?.data?.summary?.macroDistribution
    || null
);

const extractTopRecipesFromAnalytics = (response) => {
    const payload = response?.data?.data || response?.data || null;
    const recipes = payload?.recipePopularity?.topRecipes || payload?.topRecipes || null;
    return Array.isArray(recipes) ? recipes : [];
};

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

const extractRegistrationTrendFromAnalytics = (response) => {
    const payload = response?.data?.data || response?.data || {};
    const points = payload?.trends?.monthlyRegistrations || payload?.monthlyRegistrations || [];

    if (!Array.isArray(points)) return [];

    return points.map((item) => ({
        name: item?.month || item?.name || '-',
        registrations: Number(item?.value ?? item?.registrations ?? 0) || 0,
    }));
};

const buildMacroFromNutritionEntries = (entries = []) => {
    if (!Array.isArray(entries) || entries.length === 0) return null;

    const totals = entries.reduce(
        (acc, nutrition) => {
            acc.protein += Number(nutrition?.protein) || 0;
            acc.carbs += Number(nutrition?.carbs ?? nutrition?.carbohydrates) || 0;
            acc.fat += Number(nutrition?.fat) || 0;
            return acc;
        },
        { protein: 0, carbs: 0, fat: 0 },
    );

    const count = entries.length;
    const protein_g = totals.protein / count;
    const carbs_g = totals.carbs / count;
    const fat_g = totals.fat / count;

    const proteinCalories = protein_g * 4;
    const carbsCalories = carbs_g * 4;
    const fatCalories = fat_g * 9;
    const totalMacroCalories = proteinCalories + carbsCalories + fatCalories;

    if (totalMacroCalories <= 0) return null;

    return {
        protein_g,
        carbs_g,
        fat_g,
        protein_percent: (proteinCalories / totalMacroCalories) * 100,
        carbs_percent: (carbsCalories / totalMacroCalories) * 100,
        fat_percent: (fatCalories / totalMacroCalories) * 100,
        total_macro_calories: totalMacroCalories,
    };
};

const buildMacroFromRecipeNutritionApi = async (recipeIds = []) => {
    if (!Array.isArray(recipeIds) || recipeIds.length === 0) return null;

    const uniqueIds = [...new Set(recipeIds.filter(Boolean))].slice(0, 20);
    if (uniqueIds.length === 0) return null;

    const responses = await Promise.allSettled(
        uniqueIds.map((recipeId) => axiosClient.get(`/recipes/${recipeId}/nutrition`)),
    );

    const nutritions = responses
        .filter((result) => result.status === 'fulfilled')
        .map((result) => result.value?.data?.data || result.value?.data)
        .filter(Boolean);

    return buildMacroFromNutritionEntries(nutritions);
};

const buildMacroFromRecipes = (recipes = []) => {
    if (!Array.isArray(recipes) || recipes.length === 0) return null;

    const totals = recipes.reduce(
        (acc, recipe) => {
            const nutrition = recipe?.nutritionInfo || recipe?.nutrition || {};
            acc.protein += Number(nutrition.protein) || 0;
            acc.carbs += Number(nutrition.carbs ?? nutrition.carbohydrates) || 0;
            acc.fat += Number(nutrition.fat) || 0;
            return acc;
        },
        { protein: 0, carbs: 0, fat: 0 },
    );

    const count = recipes.length;
    const protein_g = totals.protein / count;
    const carbs_g = totals.carbs / count;
    const fat_g = totals.fat / count;

    const proteinCalories = protein_g * 4;
    const carbsCalories = carbs_g * 4;
    const fatCalories = fat_g * 9;
    const totalMacroCalories = proteinCalories + carbsCalories + fatCalories;

    if (totalMacroCalories <= 0) return null;

    return {
        protein_g,
        carbs_g,
        fat_g,
        protein_percent: (proteinCalories / totalMacroCalories) * 100,
        carbs_percent: (carbsCalories / totalMacroCalories) * 100,
        fat_percent: (fatCalories / totalMacroCalories) * 100,
        total_macro_calories: totalMacroCalories,
    };
};

const buildEstimatedMacroSummary = (recipes = []) => {
    if (!Array.isArray(recipes) || recipes.length === 0) return null;

    const caloriesList = recipes
        .map((recipe) => Number(recipe?.calories || recipe?.nutrition?.calories || recipe?.nutritionInfo?.calories))
        .filter((value) => Number.isFinite(value) && value > 0);

    const avgCalories = caloriesList.length > 0
        ? caloriesList.reduce((sum, value) => sum + value, 0) / caloriesList.length
        : 2000;

    const proteinCalories = avgCalories * 0.3;
    const carbsCalories = avgCalories * 0.4;
    const fatCalories = avgCalories * 0.3;

    return {
        protein_g: proteinCalories / 4,
        carbs_g: carbsCalories / 4,
        fat_g: fatCalories / 9,
        protein_percent: 30,
        carbs_percent: 40,
        fat_percent: 30,
        total_macro_calories: avgCalories,
        source: 'estimated',
    };
};

const DashboardPage = () => {
    const navigate = useNavigate();

    const userRole = localStorage.getItem('userRole');
    const isAdmin = userRole === 'admin';
    const isNutritionist = userRole === 'nutritionist';

    const [statsLoading, setStatsLoading] = useState(true);
    const [stats, setStats] = useState({
        totalUsers: 0,
        proUsers: 0,
        nutritionists: 0,
        recipes: 0,
        chatContacts: 0,
    });

    const [registrationTrend, setRegistrationTrend] = useState([]);
    const [registrationSource, setRegistrationSource] = useState('N/A');
    const [macroSummary, setMacroSummary] = useState(null);
    const [macroLoading, setMacroLoading] = useState(true);
    const [macroSource, setMacroSource] = useState('N/A');
    const [topRecipes, setTopRecipes] = useState([]);
    const [topRecipesSource, setTopRecipesSource] = useState('N/A');

    useEffect(() => {
        let isMounted = true;

        const fetchDashboardData = async () => {
            setStatsLoading(true);
            setMacroLoading(true);

            try {
                const requests = [
                    axiosClient.get('/users', { params: { role: 'user', limit: 1000 } }),
                    axiosClient.get('/users', { params: { role: 'user', proOnly: true, limit: 1 } }),
                    axiosClient.get('/users', { params: { role: 'nutritionist', limit: 1 } }),
                    axiosClient.get('/recipes', { params: { limit: 100 } }),
                    axiosClient.get('/chat/contacts'),
                    axiosClient.get('/ai/meal-plans/latest'),
                    axiosClient.get('/analytics/overview'),
                ];

                const results = await Promise.allSettled(requests);
                if (!isMounted) return;

                const [
                    usersRes,
                    proUsersRes,
                    nutritionistsRes,
                    recipesRes,
                    contactsRes,
                    macroRes,
                    analyticsRes,
                ] = results;

                const usersPayload = usersRes.status === 'fulfilled'
                    ? extractUsersPayload(usersRes.value)
                    : { users: [], total: 0 };
                const allUsers = usersPayload.users;

                const recipesPayload = recipesRes.status === 'fulfilled'
                    ? extractRecipesPayload(recipesRes.value)
                    : { recipes: [], total: 0 };

                const analyticsRegistrationTrend = analyticsRes.status === 'fulfilled'
                    ? extractRegistrationTrendFromAnalytics(analyticsRes.value)
                    : [];

                setStats({
                    totalUsers: usersPayload.total,
                    proUsers: proUsersRes.status === 'fulfilled' ? (proUsersRes.value?.data?.data?.total || 0) : 0,
                    nutritionists: nutritionistsRes.status === 'fulfilled' ? (nutritionistsRes.value?.data?.data?.total || 0) : 0,
                    recipes: recipesPayload.total,
                    chatContacts: contactsRes.status === 'fulfilled' ? (contactsRes.value?.data?.data?.length || 0) : 0,
                });

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

                let resolvedMacroSummary = macroRes.status === 'fulfilled'
                    ? extractMacroDistribution(macroRes.value)
                    : null;
                let resolvedMacroSource = resolvedMacroSummary ? 'Meal Plans Latest API' : '';

                if (!resolvedMacroSummary && allUsers.length > 0) {
                    const candidateUserIds = allUsers
                        .map((user) => user?._id)
                        .filter(Boolean)
                        .slice(0, 12);

                    for (const userId of candidateUserIds) {
                        try {
                            const candidateMacroRes = await axiosClient.get('/ai/meal-plans/latest', {
                                params: { userId },
                            });
                            const candidateSummary = extractMacroDistribution(candidateMacroRes);
                            if (candidateSummary) {
                                resolvedMacroSummary = candidateSummary;
                                resolvedMacroSource = 'Meal Plans Latest API (candidate users)';
                                break;
                            }
                        } catch (e) {
                            // Ignore candidate failures and continue trying the next user.
                        }
                    }
                }

                const analyticsTopRecipes = analyticsRes.status === 'fulfilled'
                    ? extractTopRecipesFromAnalytics(analyticsRes.value)
                    : [];

                const fallbackRecipeList = recipesPayload.recipes;
                const candidateRecipeIds = [
                    ...analyticsTopRecipes.map((item) => item?.recipeId || item?._id),
                    ...fallbackRecipeList.map((item) => item?._id),
                ];

                if (!resolvedMacroSummary) {
                    resolvedMacroSummary = buildMacroFromRecipes(fallbackRecipeList);
                    if (resolvedMacroSummary) {
                        resolvedMacroSource = 'Recipes API (embedded nutrition)';
                    }
                }

                if (!resolvedMacroSummary) {
                    resolvedMacroSummary = await buildMacroFromRecipeNutritionApi(candidateRecipeIds);
                    if (resolvedMacroSummary) {
                        resolvedMacroSource = 'Recipe Nutrition API';
                    }
                }

                if (!resolvedMacroSummary) {
                    resolvedMacroSummary = buildEstimatedMacroSummary(fallbackRecipeList);
                    if (resolvedMacroSummary) {
                        resolvedMacroSource = 'Estimated fallback';
                    }
                }

                setMacroSummary(resolvedMacroSummary);
                setMacroSource(resolvedMacroSource || 'N/A');

                const resolvedTopRecipes = analyticsTopRecipes.length > 0
                    ? analyticsTopRecipes
                    : pickTopRecipesFromList(fallbackRecipeList, 5);

                setTopRecipes(resolvedTopRecipes);
                setTopRecipesSource(
                    analyticsTopRecipes.length > 0
                        ? 'Analytics Overview API'
                        : 'Recipes API (rating sort)',
                );
            } catch (error) {
                if (!isMounted) return;
                setTopRecipes([]);
                setTopRecipesSource('N/A');
                setMacroSummary(null);
                setMacroSource('N/A');
                setRegistrationSource('N/A');
            } finally {
                if (!isMounted) return;
                setStatsLoading(false);
                setMacroLoading(false);
            }
        };

        fetchDashboardData();

        return () => {
            isMounted = false;
        };
    }, []);

    const statCards = [
        {
            title: 'Registered Users',
            count: stats.totalUsers,
            color: '#30a5ff',
            icon: <Users size={24} />,
            show: true,
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
            show: isAdmin,
        },
        {
            title: 'Recipes in Library',
            count: stats.recipes,
            color: '#8e44ad',
            icon: <Utensils size={24} />,
            show: true,
        },
        {
            title: 'Private Chat Contacts',
            count: stats.chatContacts,
            color: '#f9243f',
            icon: <MessageCircle size={24} />,
            show: isNutritionist || isAdmin,
        },
    ].filter((card) => card.show);

    return (
        <div>
            <h2 style={{ fontSize: '24px', marginBottom: '25px', color: '#30a5ff', fontWeight: 600 }}>
                Admin Analytics Overview
            </h2>

            <p style={{ marginBottom: '20px', color: '#666', fontSize: '14px' }}>
                Centralized overview for users, subscriptions, consultations and nutrition workflow.
            </p>

            <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', marginBottom: '30px' }}>
                {statCards.map((card) => (
                    <StatsWidget
                        key={card.title}
                        title={card.title}
                        count={statsLoading ? '...' : card.count}
                        color={card.color}
                        icon={card.icon}
                    />
                ))}
            </div>

            {(isAdmin || isNutritionist) && (
                <div style={{ marginBottom: '30px' }}>
                    <h3 style={{ marginBottom: '15px' }}>Nutritionist Management</h3>

                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '15px' }}>
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

            <div style={{ background: 'white', padding: '25px', borderRadius: '8px', marginBottom: '24px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <h3 style={{ margin: 0 }}>User Registrations (Last 6 Months)</h3>
                    <span style={{ color: '#667085', fontSize: '12px' }}>
                        Source: {registrationSource}
                    </span>
                </div>

                <div style={{ width: '100%', height: 360 }}>
                    <ResponsiveContainer>
                        <AreaChart data={registrationTrend}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="name" />
                            <YAxis />
                            <Tooltip />
                            <Area type="monotone" dataKey="registrations" stroke="#30a5ff" fill="#30a5ff" />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>

            <div style={{ marginBottom: '24px' }}>
                <MacroDistributionCard data={macroSummary} loading={macroLoading} sourceLabel={macroSource} />
            </div>

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
                        Source: {topRecipesSource}
                    </span>
                </div>

                <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                            <tr style={{ textAlign: 'left', borderBottom: '1px solid #eee', color: '#667085' }}>
                                <th style={{ padding: '10px 8px' }}>Recipe</th>
                                <th style={{ padding: '10px 8px' }}>Favorites</th>
                                <th style={{ padding: '10px 8px' }}>Reviews</th>
                                <th style={{ padding: '10px 8px' }}>Avg Rating</th>
                            </tr>
                        </thead>
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
