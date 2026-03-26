import React, { useEffect, useMemo, useState } from "react";
import {
    Users,
    Crown,
    Utensils,
    Wallet,
    MessageCircle,
    Activity,
} from "lucide-react";
import {
    AreaChart,
    Area,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
    Line,
} from "recharts";
import StatsWidget from "../../features/dashboard/components/StatsWidget";
import { getAnalyticsOverview } from "../../services/analyticsApi";

const formatCurrency = (value) =>
    new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(
        Number(value || 0),
    );

const DashboardPage = () => {
    const userRole = localStorage.getItem("userRole");
    const isAdmin = userRole === "admin";

    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [overview, setOverview] = useState(null);

    useEffect(() => {
        let isMounted = true;

        const fetchOverview = async () => {
            if (!isAdmin) {
                if (isMounted) {
                    setLoading(false);
                }
                return;
            }

            try {
                if (isMounted) {
                    setLoading(true);
                    setError("");
                }

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
    }, [isAdmin]);

    const userActivity = overview?.userActivity || {};
    const recipePopularity = overview?.recipePopularity || {};
    const financialPerformance = overview?.financialPerformance || {};
    const trends = overview?.trends || {};

    const statCards = useMemo(
        () => [
            {
                title: "Total Users",
                count: userActivity.totalUsers || 0,
                color: "#30a5ff",
                icon: <Users size={24} />,
            },
            {
                title: "New Users (30d)",
                count: userActivity.newUsersLast30Days || 0,
                color: "#1ebfae",
                icon: <Activity size={24} />,
            },
            {
                title: "Active Pro Users",
                count: userActivity.activeProUsers || 0,
                color: "#ffb53e",
                icon: <Crown size={24} />,
            },
            {
                title: "Published Recipes",
                count: recipePopularity.publishedRecipes || 0,
                color: "#8e44ad",
                icon: <Utensils size={24} />,
            },
            {
                title: "Total Revenue",
                count: formatCurrency(financialPerformance.totalRevenue),
                color: "#f9243f",
                icon: <Wallet size={24} />,
            },
            {
                title: "Chat Msgs (30d)",
                count: userActivity.chatMessagesLast30Days || 0,
                color: "#3b82f6",
                icon: <MessageCircle size={24} />,
            },
        ],
        [financialPerformance.totalRevenue, recipePopularity.publishedRecipes, userActivity],
    );

    const combinedTrend = (trends.monthlyRegistrations || []).map((item, index) => ({
        month: item.month,
        registrations: item.value,
        revenue: trends.monthlyRevenue?.[index]?.value || 0,
    }));

    if (!isAdmin) {
        return (
            <div>
                <h2 style={{ fontSize: "24px", marginBottom: "14px", color: "#30a5ff", fontWeight: 600 }}>
                    Dashboard
                </h2>
                <p style={{ color: "#666", fontSize: "14px" }}>
                    Advanced analytics is available for admin accounts.
                </p>
            </div>
        );
    }

    return (
        <div>
            <h2 style={{ fontSize: "24px", marginBottom: "25px", color: "#30a5ff", fontWeight: 600 }}>
                Admin Analytics Overview
            </h2>

            <p style={{ marginTop: "-10px", marginBottom: "20px", color: "#666", fontSize: "14px" }}>
                Monitor user activity, recipe popularity and financial performance right after login.
            </p>

            {error && (
                <div
                    style={{
                        background: "#fff1f2",
                        color: "#be123c",
                        border: "1px solid #fecdd3",
                        padding: "12px 16px",
                        borderRadius: "8px",
                        marginBottom: "16px",
                    }}
                >
                    {error}
                </div>
            )}

            <div style={{ display: "flex", gap: "20px", flexWrap: "wrap", marginBottom: "30px" }}>
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

            <div
                style={{
                    background: "white",
                    padding: "25px",
                    borderRadius: "8px",
                    boxShadow: "0 2px 10px rgba(0,0,0,0.05)",
                    marginBottom: "30px",
                }}
            >
                <h3 style={{ margin: "0 0 20px 0", color: "#5f6468", fontSize: "18px" }}>
                    Registration & Revenue Trend (Last 6 Months)
                </h3>

                <div style={{ width: "100%", height: 360 }}>
                    <ResponsiveContainer>
                        <AreaChart data={combinedTrend} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                            <defs>
                                <linearGradient id="colorRegistration" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="5%" stopColor="#30a5ff" stopOpacity={0.8} />
                                    <stop offset="95%" stopColor="#30a5ff" stopOpacity={0.05} />
                                </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eee" />
                            <XAxis dataKey="month" axisLine={false} tickLine={false} tick={{ fill: "#999" }} />
                            <YAxis yAxisId="left" axisLine={false} tickLine={false} tick={{ fill: "#999" }} />
                            <YAxis yAxisId="right" orientation="right" axisLine={false} tickLine={false} tick={{ fill: "#999" }} />
                            <Tooltip
                                formatter={(value, name) =>
                                    name === "Revenue" ? formatCurrency(value) : Number(value).toLocaleString("en-US")
                                }
                                contentStyle={{ borderRadius: "5px", border: "none", boxShadow: "0 2px 10px rgba(0,0,0,0.1)" }}
                            />
                            <Area
                                yAxisId="left"
                                type="monotone"
                                dataKey="registrations"
                                name="Registrations"
                                stroke="#30a5ff"
                                fillOpacity={1}
                                fill="url(#colorRegistration)"
                                strokeWidth={3}
                            />
                            <Line
                                yAxisId="right"
                                type="monotone"
                                dataKey="revenue"
                                name="Revenue"
                                stroke="#f9243f"
                                strokeWidth={3}
                                dot={{ r: 3 }}
                            />
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
