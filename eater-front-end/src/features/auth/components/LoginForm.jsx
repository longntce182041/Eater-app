import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axiosClient from '../../../../src/api/axiosClient.js'; // Import axios client đã cấu hình
import { toast } from 'react-toastify'; // Import thư viện thông báo

const LoginForm = () => {
    const navigate = useNavigate();

    // State lưu dữ liệu nhập vào
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    // State xử lý trạng thái loading khi đang gọi API
    const [loading, setLoading] = useState(false);

    const handleLogin = async (e) => {
        e.preventDefault();
        if (!email || !password) return toast.warning("Enter info");

        try {
            setLoading(true);
            const res = await axiosClient.post('/auth/admin/login', { email, password });

            // --- IN RA CONSOLE ĐỂ KIỂM TRA ---
            console.log("KẾT QUẢ BACKEND TRẢ VỀ:", res.data);

            // Kiểm tra xem Backend trả về success hay không?
            // Lưu ý: Tùy backend bạn code, có thể là res.data.success hoặc chỉ res.data
            if (res.data.success) {

                // Lấy token từ đúng chỗ (Kiểm tra kỹ xem token nằm ở res.data.token hay res.data.data.token)
                // Dựa theo code backend bài trước mình hướng dẫn thì nó nằm trong data
                const token = res.data.data?.token || res.data.token;
                const role = res.data.data?.user?.role || res.data.user?.role;

                if (token) {
                    localStorage.setItem('token', token);
                    localStorage.setItem('userRole', role);

                    toast.success("Login Success!");

                    // Chờ 1 chút để lưu xong token rồi mới chuyển trang
                    setTimeout(() => {
                        navigate(role === 'nutritionist' ? '/consultations' : '/dashboard');
                    }, 500);
                } else {
                    toast.error("Login success but no Token found!");
                    console.error("Không tìm thấy token trong response");
                }
            }

        } catch (error) {
            console.error("Lỗi Login:", error);
            toast.error("Login failed!");
        } finally {
            setLoading(false);
        }
    };

    // --- PHẦN GIAO DIỆN (CSS IN JS) ---
    return (
        <div style={styles.container}>
            <div style={styles.card}>
                <h2 style={styles.title}>Eater Admin</h2>
                <p style={styles.subtitle}>Please login to continue</p>

                <form onSubmit={handleLogin}>
                    <div style={styles.inputGroup}>
                        <input
                            type="email"
                            placeholder="E-mail"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            style={styles.input}
                            disabled={loading}
                            autoFocus
                        />
                    </div>

                    <div style={styles.inputGroup}>
                        <input
                            type="password"
                            placeholder="Password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            style={styles.input}
                            disabled={loading}
                        />
                    </div>

                    <button
                        type="submit"
                        style={loading ? styles.buttonDisabled : styles.button}
                        disabled={loading}
                    >
                        {loading ? 'Logging in...' : 'Login'}
                    </button>
                </form>
            </div>
        </div>
    );
};

// --- CSS STYLES (Giống Lumino Admin) ---
const styles = {
    container: {
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        background: '#f1f4f7', // Màu nền xám nhạt đặc trưng
    },
    card: {
        background: 'white',
        padding: '40px',
        borderRadius: '8px',
        boxShadow: '0 4px 15px rgba(0,0,0,0.05)', // Đổ bóng nhẹ
        width: '100%',
        maxWidth: '380px',
        textAlign: 'center'
    },
    title: {
        color: '#30a5ff', // Màu xanh dương chủ đạo
        fontSize: '28px',
        marginBottom: '5px',
        fontWeight: '600'
    },
    subtitle: {
        color: '#999',
        fontSize: '14px',
        marginBottom: '30px'
    },
    inputGroup: {
        marginBottom: '20px'
    },
    input: {
        width: '100%',
        padding: '12px 15px',
        borderRadius: '4px',
        border: '1px solid #ddd',
        fontSize: '15px',
        outline: 'none',
        boxSizing: 'border-box', // Quan trọng để padding không làm vỡ layout
        transition: 'border 0.3s',
    },
    button: {
        width: '100%',
        padding: '12px',
        background: '#30a5ff',
        color: 'white',
        border: 'none',
        borderRadius: '4px',
        cursor: 'pointer',
        fontSize: '16px',
        fontWeight: 'bold',
        transition: 'background 0.3s',
    },
    buttonDisabled: {
        width: '100%',
        padding: '12px',
        background: '#8ecfff',
        color: 'white',
        border: 'none',
        borderRadius: '4px',
        cursor: 'not-allowed',
        fontSize: '16px',
    }
};

export default LoginForm;