// File: src/pages/auth/index.jsx
import React from 'react';
// Import cái Form Login từ thư mục features
import LoginForm from '../../features/auth/components/LoginForm';

const LoginPage = () => {
    return (
        // Có thể bọc thêm div hoặc layout nếu muốn, hiện tại cứ trả về Form là được
        <LoginForm />
    );
};

// Quan trọng: Phải export default để bên kia import không cần ngoặc { }
export default LoginPage;