import React from 'react';

const StatsWidget = ({ title, count, icon, color }) => {
    return (
        <div style={{
            background: 'white',
            padding: '20px',
            borderRadius: '8px',
            boxShadow: '0 2px 10px rgba(0,0,0,0.05)',
            flex: 1,
            display: 'flex',
            alignItems: 'center',
            minWidth: '200px',
            borderLeft: `5px solid ${color}` // Viền màu bên trái
        }}>
            <div style={{
                width: '50px',
                height: '50px',
                background: color,
                borderRadius: '50%',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                color: 'white',
                marginRight: '15px'
            }}>
                {icon}
            </div>
            <div>
                <div style={{ fontSize: '28px', fontWeight: 'bold', color: '#5f6468', lineHeight: '1.2' }}>{count}</div>
                <div style={{ color: '#999', fontSize: '13px', textTransform: 'uppercase', fontWeight: '600' }}>{title}</div>
            </div>
        </div>
    );
};

export default StatsWidget;