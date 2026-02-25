import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';

const COLORS = [
    { name: 'Protein', color: '#1ea7a1' },
    { name: 'Carbs', color: '#f6b26b' },
    { name: 'Fat', color: '#6a9be6' },
];

const toNumber = (value) => {
    const num = Number(value);
    return Number.isFinite(num) ? num : 0;
};

const formatPercent = (value) => `${toNumber(value).toFixed(1)}%`;
const formatGrams = (value) => `${toNumber(value).toFixed(0)}g`;

const MacroDistributionCard = ({ data, loading = false, title = 'Macronutrient Distribution' }) => {
    if (loading) {
        return (
            <div style={{
                background: 'linear-gradient(135deg, #f7fafc 0%, #eef6ff 100%)',
                borderRadius: '10px',
                padding: '22px',
                border: '1px solid #d6e4ff',
                boxShadow: '0 8px 18px rgba(31, 61, 99, 0.08)',
                minHeight: '280px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#5f6468',
                fontFamily: '"Space Grotesk", "Segoe UI", sans-serif',
            }}>
                Loading macro distribution...
            </div>
        );
    }

    if (!data) {
        return (
            <div style={{
                background: 'linear-gradient(135deg, #f7fafc 0%, #eef6ff 100%)',
                borderRadius: '10px',
                padding: '22px',
                border: '1px solid #d6e4ff',
                boxShadow: '0 8px 18px rgba(31, 61, 99, 0.08)',
                minHeight: '280px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#5f6468',
                fontFamily: '"Space Grotesk", "Segoe UI", sans-serif',
            }}>
                No macro data available yet.
            </div>
        );
    }

    const proteinG = toNumber(data.protein_g);
    const carbsG = toNumber(data.carbs_g ?? data.carbohydrates_g);
    const fatG = toNumber(data.fat_g);

    const proteinCalories = proteinG * 4;
    const carbsCalories = carbsG * 4;
    const fatCalories = fatG * 9;
    const totalMacroCalories = proteinCalories + carbsCalories + fatCalories;

    const proteinPercent = data.protein_percent ?? (totalMacroCalories ? (proteinCalories / totalMacroCalories) * 100 : 0);
    const carbsPercent = data.carbs_percent ?? (totalMacroCalories ? (carbsCalories / totalMacroCalories) * 100 : 0);
    const fatPercent = data.fat_percent ?? (totalMacroCalories ? (fatCalories / totalMacroCalories) * 100 : 0);

    const chartData = [
        {
            name: 'Protein',
            value: toNumber(proteinPercent),
            grams: proteinG,
            calories: proteinCalories,
            color: COLORS[0].color,
        },
        {
            name: 'Carbs',
            value: toNumber(carbsPercent),
            grams: carbsG,
            calories: carbsCalories,
            color: COLORS[1].color,
        },
        {
            name: 'Fat',
            value: toNumber(fatPercent),
            grams: fatG,
            calories: fatCalories,
            color: COLORS[2].color,
        },
    ];

    return (
        <div style={{
            background: 'linear-gradient(135deg, #f7fafc 0%, #eef6ff 100%)',
            borderRadius: '10px',
            padding: '22px',
            border: '1px solid #d6e4ff',
            boxShadow: '0 8px 18px rgba(31, 61, 99, 0.08)',
            fontFamily: '"Space Grotesk", "Segoe UI", sans-serif',
        }}>
            <div style={{
                display: 'flex',
                alignItems: 'baseline',
                justifyContent: 'space-between',
                marginBottom: '16px',
            }}>
                <h3 style={{ margin: 0, color: '#243b53', fontSize: '18px', fontWeight: 700 }}>{title}</h3>
                <span style={{ color: '#6b7280', fontSize: '13px' }}>Total macros: {toNumber(totalMacroCalories).toFixed(0)} kcal</span>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'minmax(180px, 260px) 1fr', gap: '20px', alignItems: 'center' }}>
                <div style={{ width: '100%', height: 200 }}>
                    <ResponsiveContainer>
                        <PieChart>
                            <Pie
                                data={chartData}
                                dataKey="value"
                                nameKey="name"
                                innerRadius={55}
                                outerRadius={85}
                                paddingAngle={3}
                            >
                                {chartData.map((entry) => (
                                    <Cell key={entry.name} fill={entry.color} />
                                ))}
                            </Pie>
                            <Tooltip
                                formatter={(value, name, payload) => {
                                    const grams = payload?.payload?.grams ?? 0;
                                    return [formatPercent(value), `${name} (${formatGrams(grams)})`];
                                }}
                            />
                        </PieChart>
                    </ResponsiveContainer>
                </div>

                <div style={{ display: 'grid', gap: '10px' }}>
                    {chartData.map((entry) => (
                        <div key={entry.name} style={{
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            background: '#ffffff',
                            borderRadius: '8px',
                            padding: '10px 14px',
                            border: '1px solid #edf2f7',
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#3a4a5c' }}>
                                <span style={{ width: 10, height: 10, borderRadius: '50%', background: entry.color }} />
                                <span style={{ fontWeight: 600 }}>{entry.name}</span>
                            </div>
                            <div style={{ display: 'flex', gap: '12px', color: '#4b5563', fontSize: '13px' }}>
                                <span>{formatGrams(entry.grams)}</span>
                                <span style={{ fontWeight: 600 }}>{formatPercent(entry.value)}</span>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default MacroDistributionCard;
