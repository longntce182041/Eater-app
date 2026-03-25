import React, { useEffect, useState } from 'react';
import { Users, Crown, Stethoscope, Utensils, MessageCircle } from 'lucide-react';
import {
    AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

// Import component con vừa tạo ở Bước 1
// Lưu ý: Kiểm tra kỹ đường dẫn import này cho đúng với folder của bạn
import StatsWidget from '../../features/dashboard/components/StatsWidget';
import MacroDistributionCard from '../../features/dashboard/components/MacroDistributionCard';
import axiosClient from '../../api/axiosClient';

const buildMonthlyRegistrationData = (users = [], months = 6) => {
    const now = new Date();
    const monthKeys = [];
    const monthLabelMap = new Map();

    for (let i = months - 1; i >= 0; i -= 1) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        const key = `${d.getFullYear()}-${d.getMonth()}`;
        monthKeys.push(key);
        monthLabelMap.set(key, d.toLocaleDateString('en-US', { month: 'short' }));
    }

    const counts = monthKeys.reduce((acc, key) => {
        acc[key] = 0;
        return acc;
    }, {});

    users.forEach((user) => {
        if (!user?.createdAt) return;
        const createdAt = new Date(user.createdAt);
        if (Number.isNaN(createdAt.getTime())) return;

        const key = `${createdAt.getFullYear()}-${createdAt.getMonth()}`;
        if (counts[key] !== undefined) {
            counts[key] += 1;
        }
    });

    return monthKeys.map((key) => ({
        name: monthLabelMap.get(key),
        registrations: counts[key],
    }));
};

const DashboardPage = () => {
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
            if (isMounted) {
                setStatsLoading(true);
                setMacroLoading(true);
            }

            const requests = [
                axiosClient.get('/users', { params: { role: 'user', limit: 1000 } }),
                axiosClient.get('/users', { params: { role: 'user', proOnly: true, limit: 1 } }),
                axiosClient.get('/users', { params: { role: 'nutritionist', limit: 1 } }),
                axiosClient.get('/recipes', { params: { limit: 1 } }),
                axiosClient.get('/chat/contacts'),
                axiosClient.get('/ai/meal-plans/latest'),
            ];

            const [
                usersRes,
                proUsersRes,
                nutritionistsRes,
                recipesRes,
                contactsRes,
                macroRes,
            ] = await Promise.allSettled(requests);

            if (!isMounted) return;

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
                    : null,
            );

            setStatsLoading(false);
            setMacroLoading(false);
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
            <h2 style={{ fontSize: '24px', marginBottom: '25px', color: '#30a5ff', fontWeight: '600' }}>
                Eater Dashboard Overview
            </h2>

            <p style={{ marginTop: '-10px', marginBottom: '20px', color: '#666', fontSize: '14px' }}>
                Centralized overview for users, Pro subscriptions, consultations, recipes and nutrition workflow.
            </p>

            {/* --- PHẦN 1: 4 Ô WIDGETS --- */}
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

            {/* --- PHẦN 2: BIỂU ĐỒ (ANALYTICS) --- */}
            <div style={{
                background: 'white',
                padding: '25px',
                borderRadius: '8px',
                boxShadow: '0 2px 10px rgba(0,0,0,0.05)'
            }}>
                <h3 style={{ margin: '0 0 20px 0', color: '#5f6468', fontSize: '18px' }}>User Registrations (Last 6 Months)</h3>

                <div style={{ width: '100%', height: 400 }}>
                    <ResponsiveContainer>
                        <AreaChart data={registrationTrend} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                            <defs>
                                <linearGradient id="colorTraffic" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="5%" stopColor="#30a5ff" stopOpacity={0.8}/>
                                    <stop offset="95%" stopColor="#30a5ff" stopOpacity={0}/>
                                </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eee" />
                            <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#999'}} />
                            <YAxis axisLine={false} tickLine={false} tick={{fill: '#999'}} />
                            <Tooltip
                                contentStyle={{ borderRadius: '5px', border: 'none', boxShadow: '0 2px 10px rgba(0,0,0,0.1)' }}
                            />
                            <Area
                                type="monotone"
                                dataKey="registrations"
                                stroke="#30a5ff"
                                fillOpacity={1}
                                fill="url(#colorTraffic)"
                                strokeWidth={3}
                            />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>

            <div style={{ marginTop: '30px' }}>
                <MacroDistributionCard data={macroSummary} loading={macroLoading} />
            </div>
        </div>
    );
};

// QUAN TRỌNG: Phải export default
export default DashboardPage;
