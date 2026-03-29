/**
 * 📊 STATS WIDGET COMPONENT
 *
 * Displays a single metric card in the admin dashboard
 * Shows: icon badge, metric count, and label
 * Reusable component for KPI visualization
 *
 * Props:
 * - title: String - Metric label (e.g., "Registered Users")
 * - count: Number|String - Value to display (e.g., 1,234)
 * - icon: ReactNode - Icon from lucide-react (e.g., <Users size={24} />)
 * - color: String - Hex color for badge and border (e.g., "#30a5ff")
 *
 * Layout:
 * ```
 * ┌─────────────────────────────────┐
 * │ ┌──────┐  28400                 │
 * │ │ 👥  │  REGISTERED USERS       │
 * │ └──────┘                         │
 * └─────────────────────────────────┘
 *   ↑ color border
 *   Blue circle = color prop
 *   Large number = count prop
 *   Small text = title prop
 * ```
 *
 * Features:
 * - Left color border for visual accent
 * - Color-coded icon circle (dynamic background)
 * - Responsive flex layout
 * - Subtlelbox shadow for depth
 * - Uppercase label styling
 *
 * Usage Examples:
 * ```jsx
 * // Registered users metric
 * <StatsWidget
 *   title="Registered Users"
 *   count={1234}
 *   icon={<Users size={24} />}
 *   color="#30a5ff"
 * />
 *
 * // Pro users metric
 * <StatsWidget
 *   title="Active Pro Users"
 *   count={456}
 *   icon={<Crown size={24} />}
 *   color="#ffb53e"
 * />
 *
 * // With loading state
 * <StatsWidget
 *   title="Recipes"
 *   count={loading ? '...' : 890}
 *   icon={<Utensils size={24} />}
 *   color="#8e44ad"
 * />
 * ```
 */

import React from 'react';

/**
 * 🎨 Stats Widget Component
 *
 * Renders a statistic card with icon, count, and title
 * Used in dashboard for KPI display
 */
const StatsWidget = ({ title, count, icon, color }) => {
    return (
        <div style={{
            // 🔲 Card container
            background: 'white',           // Clean white background
            padding: '20px',               // Internal spacing
            borderRadius: '8px',           // Subtle rounded corners
            boxShadow: '0 2px 10px rgba(0,0,0,0.05)',  // Soft shadow for depth
            flex: 1,                       // Flex layout - grows to fill space
            display: 'flex',               // Horizontal layout
            alignItems: 'center',          // Vertical centering
            minWidth: '200px',             // Minimum card width
            borderLeft: `5px solid ${color}` // 🎨 Left color accent border
        }}>
            {/* ✨ Icon badge circle */}
            <div style={{
                // Icon container styling
                width: '50px',             // Square dimensions (circle via border-radius)
                height: '50px',
                background: color,        // 🎨 Dynamic color from prop
                borderRadius: '50%',       // Circle shape
                display: 'flex',           // Flex centering
                justifyContent: 'center',
                alignItems: 'center',
                color: 'white',            // White icon on colored background
                marginRight: '15px'        // Spacing from text
            }}>
                {icon}                     {/* Icon passed from parent */}
            </div>

            {/* 📊 Text content section */}
            <div>
                {/* Large metric number */}
                <div style={{
                    fontSize: '28px',      // Large prominent number
                    fontWeight: 'bold',
                    color: '#5f6468',      // Dark gray
                    lineHeight: '1.2'      // Compact line spacing
                }}>
                    {count}                {/* The main metric value */}
                </div>

                {/* Metric label */}
                <div style={{
                    color: '#999',         // Lighter gray for secondary text
                    fontSize: '13px',      // Smaller font
                    textTransform: 'uppercase',  // All caps styling
                    fontWeight: '600'      // Semi-bold
                }}>
                    {title}                {/* Metric name (e.g., "Registered Users") */}
                </div>
            </div>
        </div>
    );
};

export default StatsWidget;