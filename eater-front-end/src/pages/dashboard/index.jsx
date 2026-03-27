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

    for (let i = months - 1; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        const key = `${d.getFullYear()}-${d.getMonth()}`;
        monthKeys.push(key);
        monthLabelMap.set(key, d.toLocaleDateString('en-US', { month: 'short' }));
    }

const formatCurrency = (value) =>
    new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(
        Number(value || 0),
    );

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
    const [macroSummary, setMacroSummary] = useState(null);
    const [macroLoading, setMacroLoading] = useState(true);

    useEffect(() => {
        let isMounted = true;

        const fetchDashboardData = async () => {
            setStatsLoading(true);
            setMacroLoading(true);

            const requests = [
                axiosClient.get('/users', { params: { role: 'user', limit: 1000 } }),
                axiosClient.get('/users', { params: { role: 'user', proOnly: true, limit: 1 } }),
                axiosClient.get('/users', { params: { role: 'nutritionist', limit: 1 } }),
                axiosClient.get('/recipes', { params: { limit: 1 } }),
                axiosClient.get('/chat/contacts'),
                axiosClient.get('/ai/meal-plans/latest'),
            ];

            const results = await Promise.allSettled(requests);
            if (!isMounted) return;

            const [usersRes, proUsersRes, nutritionistsRes, recipesRes, contactsRes, macroRes] = results;

            const allUsersPayload = usersRes.status === 'fulfilled' ? usersRes.value?.data?.data : null;
            const allUsers = Array.isArray(allUsersPayload?.users) ? allUsersPayload.users : [];

            setStats({
                totalUsers: allUsersPayload?.total || 0,
                proUsers: proUsersRes.status === 'fulfilled' ? (proUsersRes.value?.data?.data?.total || 0) : 0,
                nutritionists: nutritionistsRes.status === 'fulfilled' ? (nutritionistsRes.value?.data?.data?.total || 0) : 0,
                recipes: recipesRes.status === 'fulfilled' ? (recipesRes.value?.data?.data?.total || 0) : 0,
                chatContacts: contactsRes.status === 'fulfilled' ? (contactsRes.value?.data?.data?.length || 0) : 0,
            });

            setRegistrationTrend(buildMonthlyRegistrationData(allUsers, 6));

            setMacroSummary(
                macroRes.status === 'fulfilled'
                    ? (macroRes.value?.data?.data?.summary?.macroDistribution || null)
                    : null
            );

            setStatsLoading(false);
            setMacroLoading(false);
        };

                const data = await getAnalyticsOverview();
                if (isMounted) {
                    setOverview(data);
                }
            } catch (fetchError) {
                if (isMounted) {
                    setError(fetchError?.response?.data?.message || "Failed to load analytics overview");
                }
            } finally {
                if (isMounted) {
                    setLoading(false);
                }
            }
        };

        fetchOverview();
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
    ].filter(card => card.show);

    return (
        <div>
            <h2 style={{ fontSize: "24px", marginBottom: "25px", color: "#30a5ff", fontWeight: 600 }}>
                Admin Analytics Overview
            </h2>

            <p style={{ marginBottom: '20px', color: '#666', fontSize: '14px' }}>
                Centralized overview for users, subscriptions, consultations and nutrition workflow.
            </p>

            {/* WIDGETS */}
            <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', marginBottom: '30px' }}>
                {statCards.map((card) => (
                    <StatsWidget
                        key={card.title}
                        title={card.title}
                        count={loading ? "..." : card.count}
                        color={card.color}
                        icon={card.icon}
                    />
                ))}
            </div>

            {/* NUTRITIONIST MANAGEMENT (MERGED) */}
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
                                color: 'white'
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
                                color: 'white'
                            }}
                        >
                            <Clock size={28} />
                            <h4>Change Requests</h4>
                        </div>
                    </div>
                </div>
            )}

            {/* CHART */}
            <div style={{ background: 'white', padding: '25px', borderRadius: '8px' }}>
                <h3>User Registrations (Last 6 Months)</h3>

                <div style={{ width: "100%", height: 360 }}>
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

            <div
                style={{
                    background: "white",
                    padding: "25px",
                    borderRadius: "8px",
                    boxShadow: "0 2px 10px rgba(0,0,0,0.05)",
                }}
            >
                <h3 style={{ margin: "0 0 16px 0", color: "#5f6468", fontSize: "18px" }}>
                    Top Recipes by Popularity
                </h3>

                <div style={{ overflowX: "auto" }}>
                    <table style={{ width: "100%", borderCollapse: "collapse" }}>
                        <thead>
                            <tr style={{ textAlign: "left", borderBottom: "1px solid #eee", color: "#667085" }}>
                                <th style={{ padding: "10px 8px" }}>Recipe</th>
                                <th style={{ padding: "10px 8px" }}>Favorites</th>
                                <th style={{ padding: "10px 8px" }}>Reviews</th>
                                <th style={{ padding: "10px 8px" }}>Avg Rating</th>
                            </tr>
                        </thead>
                        <tbody>
                            {(recipePopularity.topRecipes || []).length === 0 && !loading ? (
                                <tr>
                                    <td style={{ padding: "14px 8px", color: "#667085" }} colSpan={4}>
                                        No popularity data available yet.
                                    </td>
                                </tr>
                            ) : (
                                (recipePopularity.topRecipes || []).map((item) => (
                                    <tr key={item.recipeId} style={{ borderBottom: "1px solid #f2f4f7" }}>
                                        <td style={{ padding: "12px 8px", color: "#344054" }}>{item.name}</td>
                                        <td style={{ padding: "12px 8px", color: "#344054" }}>{item.favorites}</td>
                                        <td style={{ padding: "12px 8px", color: "#344054" }}>{item.reviewCount}</td>
                                        <td style={{ padding: "12px 8px", color: "#344054" }}>{item.avgRating}</td>
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
