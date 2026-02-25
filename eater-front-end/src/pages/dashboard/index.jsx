import React, { useEffect, useState } from 'react';
import { ShoppingCart, MessageSquare, Users, Eye } from 'lucide-react';
import {
    AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

// Import component con vừa tạo ở Bước 1
// Lưu ý: Kiểm tra kỹ đường dẫn import này cho đúng với folder của bạn
import StatsWidget from '../../features/dashboard/components/StatsWidget';
import MacroDistributionCard from '../../features/dashboard/components/MacroDistributionCard';
import axiosClient from '../../api/axiosClient';

// Dữ liệu giả lập cho biểu đồ
const data = [
    { name: 'Jan', traffic: 4000 },
    { name: 'Feb', traffic: 3000 },
    { name: 'Mar', traffic: 2000 },
    { name: 'Apr', traffic: 2780 },
    { name: 'May', traffic: 1890 },
    { name: 'Jun', traffic: 2390 },
    { name: 'Jul', traffic: 3490 },
    { name: 'Aug', traffic: 4200 },
    { name: 'Sep', traffic: 5100 },
];

const DashboardPage = () => {
    const [macroSummary, setMacroSummary] = useState(null);
    const [macroLoading, setMacroLoading] = useState(true);

    useEffect(() => {
        let isMounted = true;

        const fetchMacroDistribution = async () => {
            try {
                setMacroLoading(true);
                const res = await axiosClient.get('/ai/meal-plans/latest');
                const summary = res?.data?.data?.summary?.macroDistribution || null;
                if (isMounted) {
                    setMacroSummary(summary);
                }
            } catch (error) {
                console.error('Failed to load macro distribution', error);
                if (isMounted) {
                    setMacroSummary(null);
                }
            } finally {
                if (isMounted) {
                    setMacroLoading(false);
                }
            }
        };

        fetchMacroDistribution();

        return () => {
            isMounted = false;
        };
    }, []);

    return (
        <div>
            <h2 style={{ fontSize: '24px', marginBottom: '25px', color: '#30a5ff', fontWeight: '600' }}>
                Dashboard Overview
            </h2>

            {/* --- PHẦN 1: 4 Ô WIDGETS --- */}
            <div style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', marginBottom: '30px' }}>
                <StatsWidget
                    title="New Orders"
                    count="120"
                    color="#30a5ff" // Xanh dương
                    icon={<ShoppingCart size={24}/>}
                />
                <StatsWidget
                    title="Comments"
                    count="52"
                    color="#ffb53e" // Cam
                    icon={<MessageSquare size={24}/>}
                />
                <StatsWidget
                    title="New Users"
                    count="24"
                    color="#1ebfae" // Xanh ngọc
                    icon={<Users size={24}/>}
                />
                <StatsWidget
                    title="Page Views"
                    count="25.2k"
                    color="#f9243f" // Đỏ
                    icon={<Eye size={24}/>}
                />
            </div>

            {/* --- PHẦN 2: BIỂU ĐỒ (ANALYTICS) --- */}
            <div style={{
                background: 'white',
                padding: '25px',
                borderRadius: '8px',
                boxShadow: '0 2px 10px rgba(0,0,0,0.05)'
            }}>
                <h3 style={{ margin: '0 0 20px 0', color: '#5f6468', fontSize: '18px' }}>Site Traffic Overview</h3>

                <div style={{ width: '100%', height: 400 }}>
                    <ResponsiveContainer>
                        <AreaChart data={data} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
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
                                dataKey="traffic"
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
