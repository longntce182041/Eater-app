/**
 * 🥗 MACRONUTRIENT DISTRIBUTION CARD COMPONENT
 *
 * Displays macronutrient breakdown as donut chart with stats table
 * Shows protein, carbs, and fat as percentages and grams
 * Used in dashboard for nutrition analytics overview
 *
 * Features:
 * - ✅ Interactive donut chart (recharts)
 * - ✅ Percentage calculations from grams
 * - ✅ Calorie content per macro (4 cal/g protein/carbs, 9 cal/g fat)
 * - ✅ Source labeling (estimated vs actual data)
 * - ✅ Loading and error states
 * - ✅ Responsive grid layout
 *
 * Props:
 * - data: Object - Nutritional data with protein/carbs/fat in grams and percentages
 *   Example: {
 *     protein_g: 150,
 *     carbs_g: 200,
 *     fat_g: 65,
 *     protein_percent: 30,
 *     carbs_percent: 40,
 *     fat_percent: 30,
 *     source: 'estimated' | 'measured'
 *   }
 * - loading: Boolean - Whether data is still being fetched
 * - title: String - Card title (default: 'Macronutrient Distribution')
 * - sourceLabel: String - Data source description (e.g., 'API')
 *
 * Data Flow:
 * ```
 * Input: protein_g=150, carbs_g=200, fat_g=65
 *   ↓
 * Convert to calories:
 *   protein: 150g × 4 cal/g = 600 cal
 *   carbs: 200g × 4 cal/g = 800 cal
 *   fat: 65g × 9 cal/g = 585 cal
 *   total: 1985 cal
 *   ↓
 * Calculate percentages:
 *   protein: 600/1985 × 100 = 30.2%
 *   carbs: 800/1985 × 40.3%
 *   fat: 585/1985 × 29.5%
 *   ↓
 * Render donut chart + stats table
 * ```
 *
 * Layout:
 * ```
 * ┌─────────────────────────────────────────────┐
 * │ Macronutrient Distribution     Source: API   │
 * ├─────────────────────────────────────────────┤
 * │ ╭─────────╮  ┌─────────────┐ │ Protein │  150g  30.2% │
 * │ │    🥧   │  │ Carbs       │ │ Carbs   │  200g  40.3% │
 * │ │   ○○○   │  │ Fat         │ │ Fat     │   65g  29.5% │
 * │ ╰─────────╯  └─────────────┘ └─────────────────────────┘
 * │                    Total macros: 1985 kcal
 * └─────────────────────────────────────────────┘
 * ```
 *
 * Color Scheme:
 * - Protein (Teal):   #1ea7a1
 * - Carbs (Orange):   #f6b26b
 * - Fat (Blue):       #6a9be6
 *
 * Usage Examples:
 * ```jsx
 * // With complete data
 * <MacroDistributionCard
 *   data={{
 *     protein_g: 150,
 *     carbs_g: 200,
 *     fat_g: 65,
 *     protein_percent: 30,
 *     carbs_percent: 40,
 *     fat_percent: 30,
 *     source: 'measured'
 *   }}
 *   title="Daily Macros"
 *   sourceLabel="User Input"
 * />
 *
 * // Loading state
 * <MacroDistributionCard
 *   data={null}
 *   loading={true}
 *   sourceLabel="API"
 * />
 *
 * // Error state (no data)
 * <MacroDistributionCard
 *   data={null}
 *   loading={false}
 *   sourceLabel="N/A"
 * />
 * ```
 */

import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';

/**
 * 🎨 COLOR CONFIGURATION
 *
 * Maps macronutrients to visual colors
 * Used in pie chart and stats table
 */
const COLORS = [
    { name: 'Protein', color: '#1ea7a1' },  // Teal - healthy protein
    { name: 'Carbs', color: '#f6b26b' },    // Warm orange - carbohydrates
    { name: 'Fat', color: '#6a9be6' },      // Cool blue - lipids
];

/**
 * 🔢 UTILITY FUNCTIONS
 *
 * Helpers for number conversion and formatting
 */

/**
 * Convert value to number, handling undefined/NaN cases
 *
 * Safety check to prevent calculation errors
 * Returns 0 if value cannot be parsed as number
 *
 * @param {*} value - Any value (number, string, null, undefined)
 * @returns {number} - Valid number or 0
 */
const toNumber = (value) => {
    const num = Number(value);
    return Number.isFinite(num) ? num : 0;
};

/**
 * Format percentage value for display
 *
 * Example: 30.2567 → "30.3%"
 *
 * @param {number} value - Percentage value
 * @returns {string} - Formatted percentage with 1 decimal place
 */
const formatPercent = (value) => `${toNumber(value).toFixed(1)}%`;

/**
 * Format gram measurement for display
 *
 * Example: 150.5 → "150g" (no decimals)
 *
 * @param {number} value - Gram value
 * @returns {string} - Formatted grams without decimals
 */
const formatGrams = (value) => `${toNumber(value).toFixed(0)}g`;

/**
 * 🥗 MACRONUTRIENT DISTRIBUTION CARD COMPONENT
 *
 * Main component - renders macro breakdown card
 */
const MacroDistributionCard = ({
    data,                                    // Nutritional data object
    loading = false,                         // Loading state flag
    title = 'Macronutrient Distribution',   // Card title
    sourceLabel = 'N/A',                    // Data source description
}) => {
    /**
     * 🔄 LOADING STATE
     *
     * Show placeholder while fetching data
     */
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

    /**
     * ⚠️ ERROR STATE
     *
     * Show message when no data available
     */
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

    /**
     * 📊 DATA EXTRACTION & CALCULATIONS
     *
     * Extract grams from data and calculate calories and percentages
     */

    // Extract gram values (handle both naming conventions)
    const proteinG = toNumber(data.protein_g);
    const carbsG = toNumber(data.carbs_g ?? data.carbohydrates_g);
    const fatG = toNumber(data.fat_g);

    /**
     * 🔥 CALORIE CALCULATIONS
     *
     * Macronutrient calorie values:
     * - Protein: 4 calories per gram
     * - Carbohydrates: 4 calories per gram
     * - Fat: 9 calories per gram
     */
    const proteinCalories = proteinG * 4;
    const carbsCalories = carbsG * 4;
    const fatCalories = fatG * 9;
    const totalMacroCalories = proteinCalories + carbsCalories + fatCalories;

    /**
     * 📈 PERCENTAGE CALCULATIONS
     *
     * Derive percentages from calories
     * Use provided data if available, otherwise calculate from calories
     */
    const proteinPercent = data.protein_percent ?? (totalMacroCalories ? (proteinCalories / totalMacroCalories) * 100 : 0);
    const carbsPercent = data.carbs_percent ?? (totalMacroCalories ? (carbsCalories / totalMacroCalories) * 100 : 0);
    const fatPercent = data.fat_percent ?? (totalMacroCalories ? (fatCalories / totalMacroCalories) * 100 : 0);

    /**
     * 🎨 CHART DATA PREPARATION
     *
     * Format data for recharts Pie component
     * Includes: name, percentage, grams, calories, color
     */
    const chartData = [
        {
            name: 'Protein',
            value: toNumber(proteinPercent),  // Percentage for pie slice
            grams: proteinG,                  // Show in tooltip
            calories: proteinCalories,
            color: COLORS[0].color,           // Color for pie slice
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

    /**
     * 🏷️ SOURCE INDICATOR
     *
     * Check if data is estimated (vs measured)
     * Affects badge display in header
     */
    const isEstimated = data?.source === 'estimated';

    return (
        <div style={{
            background: 'linear-gradient(135deg, #f7fafc 0%, #eef6ff 100%)',
            borderRadius: '10px',
            padding: '22px',
            border: '1px solid #d6e4ff',
            boxShadow: '0 8px 18px rgba(31, 61, 99, 0.08)',
            fontFamily: '"Space Grotesk", "Segoe UI", sans-serif',
        }}>
            {/* ═══ HEADER SECTION ═══ */}
            <div style={{
                display: 'flex',
                alignItems: 'baseline',
                justifyContent: 'space-between',
                marginBottom: '16px',
            }}>
                {/* Card title */}
                <h3 style={{ margin: 0, color: '#243b53', fontSize: '18px', fontWeight: 700 }}>
                    {title}
                </h3>

                {/* Source indicators on right */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    {/* Data source label */}
                    <span style={{
                        fontSize: '12px',
                        color: '#475467',
                        background: '#eef2ff',
                        border: '1px solid #d9e1ff',
                        borderRadius: '999px',
                        padding: '2px 8px',
                    }}>
                        Source: {sourceLabel}
                    </span>

                    {/* Estimated badge (if applicable) */}
                    {isEstimated && (
                        <span style={{
                            fontSize: '12px',
                            color: '#8a6d1f',
                            background: '#fff7d6',
                            border: '1px solid #f1dd93',
                            borderRadius: '999px',
                            padding: '2px 8px',
                        }}>
                            Estimated
                        </span>
                    )}

                    {/* Total calorie summary */}
                    <span style={{ color: '#6b7280', fontSize: '13px' }}>
                        Total macros: {toNumber(totalMacroCalories).toFixed(0)} kcal
                    </span>
                </div>
            </div>

            {/* ═══ CONTENT SECTION ═══ */}
            <div style={{
                display: 'grid',
                gridTemplateColumns: 'minmax(180px, 260px) 1fr',  // Responsive grid: chart + table
                gap: '20px',
                alignItems: 'center'
            }}>
                {/* 🥧 LEFT: DONUT CHART */}
                <div style={{ width: '100%', height: 200 }}>
                    <ResponsiveContainer>
                        <PieChart>
                            <Pie
                                data={chartData}
                                dataKey="value"                    // Percentage values
                                nameKey="name"                     // Macro names
                                innerRadius={55}                   // Donut hole size
                                outerRadius={85}                   // Outer ring size
                                paddingAngle={3}                   // Gap between slices
                            >
                                {/* Color each slice */}
                                {chartData.map((entry) => (
                                    <Cell key={entry.name} fill={entry.color} />
                                ))}
                            </Pie>

                            {/* Tooltip on hover */}
                            <Tooltip
                                formatter={(value, name, payload) => {
                                    const grams = payload?.payload?.grams ?? 0;
                                    return [formatPercent(value), `${name} (${formatGrams(grams)})`];
                                }}
                            />
                        </PieChart>
                    </ResponsiveContainer>
                </div>

                {/* 📊 RIGHT: STATS TABLE */}
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
                            {/* Left: Color indicator + macro name */}
                            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#3a4a5c' }}>
                                {/* Color dot */}
                                <span style={{
                                    width: 10,
                                    height: 10,
                                    borderRadius: '50%',
                                    background: entry.color
                                }} />
                                {/* Macro name */}
                                <span style={{ fontWeight: 600 }}>{entry.name}</span>
                            </div>

                            {/* Right: Grams + percentage */}
                            <div style={{ display: 'flex', gap: '12px', color: '#4b5563', fontSize: '13px' }}>
                                {/* Gram value (light gray) */}
                                <span>{formatGrams(entry.grams)}</span>
                                {/* Percentage (bold) */}
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