import React, { useCallback, useEffect, useState } from 'react';
import axiosClient from '../../api/axiosClient';
import { Trash2, Edit, Plus, X, Eye, EyeOff, Search, Filter, BadgeCheck } from 'lucide-react';
import { toast } from 'react-toastify';

const UserPage = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);

    // --- STATE MODAL ---
    const [showModal, setShowModal] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [currentUser, setCurrentUser] = useState(null);

    // --- STATE HIỆN PASS ---
    const [showPassword, setShowPassword] = useState(false);

    // --- STATE TÌM KIẾM & LỌC ---
    const [filters, setFilters] = useState({
        keyword: '',
        role: ''
    });

    // --- STATE FORM DATA ---
    const [formData, setFormData] = useState({
        email: '',
        password: '',
        role: 'user',
        isActive: true,
        isEmailVerified: false // ✅ THÊM STATE CHO VERIFY EMAIL
    });

    // 1. Gọi API lấy danh sách
    const fetchUsers = useCallback(async () => {
        try {
            setLoading(true);
            const res = await axiosClient.get('/users', {
                params: {
                    keyword: filters.keyword,
                    role: filters.role
                }
            });
            if (res.data.success) {
                setUsers(res.data.data.users);
            }
        } catch (error) {
            console.error(error);
            toast.error("Failed to fetch users");
        } finally {
            setLoading(false);
        }
    }, [filters.keyword, filters.role]);

    useEffect(() => {
        const timer = setTimeout(() => {
            fetchUsers();
        }, 500);
        return () => clearTimeout(timer);
    }, [fetchUsers]);

    // 2. Mở Modal Create
    const handleOpenCreate = () => {
        setIsEditing(false);
        // Reset form, mặc định tạo mới thì isEmailVerified = false
        setFormData({ email: '', password: '', role: 'user', isActive: true, isEmailVerified: false });
        setShowPassword(false);
        setShowModal(true);
    };

    // 3. Mở Modal Edit
    const handleOpenEdit = (user) => {
        setIsEditing(true);
        setCurrentUser(user);
        // Đổ dữ liệu cũ lên form
        setFormData({
            email: user.email,
            password: '', // Để trống vì ko dùng tới khi edit
            role: user.role,
            isActive: user.isActive,
            isEmailVerified: user.isEmailVerified || false // ✅ Đổ trạng thái verify cũ lên
        });
        setShowPassword(false);
        setShowModal(true);
    };

    // 4. Xóa User (Soft Delete)
    const handleDelete = async (id) => {
        if (!window.confirm("Are you sure you want to deactivate this user?")) return;
        try {
            const res = await axiosClient.delete(`/users/delete/${id}`);
            toast.success(res.data.message);
            fetchUsers();
        } catch (error) {
            toast.error(error.response?.data?.message || "Failed to delete user");
        }
    };

    // 5. Submit Form
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            let res;

            if (isEditing) {
                const updateData = { ...formData };
                // ✅ Khi Edit, KHÔNG gửi password và email đi để tránh lỗi backend
                delete updateData.password;
                delete updateData.email;

                res = await axiosClient.put(`/users/update/${currentUser._id}`, updateData);
            } else {
                res = await axiosClient.post('/users/create', formData);
            }

            toast.success(res.data.message);
            setShowModal(false);
            fetchUsers();
        } catch (error) {
            const msg = error.response?.data?.message || "Action failed";
            toast.error(msg);
        }
    };

    return (
        <div>
            <h2 style={{ color: '#30a5ff', marginBottom: '20px' }}>User Management</h2>

            {/* --- TOOLBAR --- */}
            <div style={{
                background: 'white', padding: '15px', borderRadius: '5px', marginBottom: '20px',
                display: 'flex', gap: '15px', alignItems: 'center', boxShadow: '0 1px 2px rgba(0,0,0,0.1)'
            }}>
                <div style={{ position: 'relative', flex: 1 }}>
                    <Search size={18} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <input
                        type="text"
                        placeholder="Search by email..."
                        value={filters.keyword}
                        onChange={(e) => setFilters({ ...filters, keyword: e.target.value })}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd' }}
                    />
                </div>

                <div style={{ position: 'relative', width: '200px' }}>
                    <Filter size={16} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <select
                        value={filters.role}
                        onChange={(e) => setFilters({ ...filters, role: e.target.value })}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd', cursor: 'pointer' }}
                    >
                        <option value="">All Roles</option>
                        <option value="user">User</option>
                        <option value="admin">Admin</option>
                        <option value="nutritionist">Nutritionist</option>
                    </select>
                </div>

                <button
                    onClick={handleOpenCreate}
                    style={{
                        background: '#30a5ff', color: 'white', border: 'none',
                        padding: '10px 20px', borderRadius: '4px', cursor: 'pointer',
                        display: 'flex', alignItems: 'center', gap: '5px', fontWeight: 'bold', whiteSpace: 'nowrap'
                    }}
                >
                    <Plus size={18} /> Create User
                </button>
            </div>

            {/* --- TABLE --- */}
            <div style={{ background: 'white', padding: '20px', borderRadius: '5px', boxShadow: '0 1px 2px rgba(0,0,0,0.1)' }}>
                {loading ? (
                    <p style={{ textAlign: 'center', color: '#666' }}>Loading data...</p>
                ) : (
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                            <tr style={{ borderBottom: '2px solid #eee', textAlign: 'left', color: '#5f6468' }}>
                                <th style={{ padding: '10px' }}>Email</th>
                                <th style={{ padding: '10px' }}>Role</th>
                                <th style={{ padding: '10px' }}>Status</th>
                                <th style={{ padding: '10px' }}>Created At</th>
                                <th style={{ padding: '10px' }}>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {users.length > 0 ? users.map((user) => (
                                <tr key={user._id} style={{ borderBottom: '1px solid #eee', color: '#666' }}>
                                    <td style={{ padding: '12px' }}>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                            {user.email}
                                            {/* ✅ Hiển thị dấu tích xanh nếu Email đã được Verify */}
                                            {user.isEmailVerified && (
                                                <BadgeCheck size={16} color="#28a745" title="Email Verified" />
                                            )}
                                        </div>
                                    </td>
                                    <td style={{ padding: '12px' }}>
                                        <span style={{
                                            padding: '4px 8px', borderRadius: '4px', fontSize: '11px', fontWeight: 'bold', textTransform: 'uppercase',
                                            background: user.role === 'admin' ? '#30a5ff' : (user.role === 'nutritionist' ? '#ffb53e' : '#eee'),
                                            color: user.role === 'admin' || user.role === 'nutritionist' ? 'white' : '#333'
                                        }}>
                                            {user.role}
                                        </span>
                                    </td>
                                    <td style={{ padding: '12px' }}>
                                        {user.isActive ? (
                                            <span style={{ color: '#28a745', fontWeight: 'bold' }}>Active</span>
                                        ) : (
                                            <span style={{ color: '#dc3545', fontWeight: 'bold' }}>Inactive</span>
                                        )}
                                    </td>
                                    <td style={{ padding: '12px' }}>{new Date(user.createdAt).toLocaleDateString()}</td>
                                    <td style={{ padding: '12px' }}>
                                        <button onClick={() => handleOpenEdit(user)} style={{ marginRight: '10px', border: 'none', background: 'none', cursor: 'pointer', color: '#30a5ff' }}>
                                            <Edit size={18} />
                                        </button>
                                        <button onClick={() => handleDelete(user._id)} style={{ border: 'none', background: 'none', cursor: 'pointer', color: '#f9243f' }}>
                                            <Trash2 size={18} />
                                        </button>
                                    </td>
                                </tr>
                            )) : (
                                <tr>
                                    <td colSpan="5" style={{ textAlign: 'center', padding: '20px' }}>No users found.</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                )}
            </div>

            {/* --- MODAL CREATE / EDIT --- */}
            {showModal && (
                <div style={{
                    position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
                    background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000
                }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '400px', position: 'relative' }}>
                        <button onClick={() => setShowModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', background: 'none', border: 'none', cursor: 'pointer' }}>
                            <X size={20} />
                        </button>
                        <h3 style={{ marginTop: 0, color: '#30a5ff' }}>{isEditing ? 'Edit User' : 'Add New User'}</h3>

                        <form onSubmit={handleSubmit}>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px' }}>Email</label>
                                <input
                                    type="email"
                                    value={formData.email}
                                    onChange={e => setFormData({ ...formData, email: e.target.value })}
                                    style={{
                                        width: '100%', padding: '8px', borderRadius: '4px',
                                        border: '1px solid #ccc',
                                        backgroundColor: isEditing ? '#f0f0f0' : 'white', // Làm xám nền khi Edit
                                        cursor: isEditing ? 'not-allowed' : 'text'
                                    }}
                                    disabled={isEditing} // ✅ CHỈ ĐỌC NẾU ĐANG LÀ CHẾ ĐỘ SỬA
                                    required
                                />
                            </div>

                            {/* ✅ ẨN HOÀN TOÀN KHUNG PASSWORD NẾU ĐANG LÀ CHẾ ĐỘ SỬA */}
                            {!isEditing && (
                                <div style={{ marginBottom: '15px' }}>
                                    <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px' }}>Password</label>
                                    <div style={{ position: 'relative' }}>
                                        <input
                                            type={showPassword ? "text" : "password"}
                                            value={formData.password}
                                            onChange={e => setFormData({ ...formData, password: e.target.value })}
                                            style={{ width: '100%', padding: '8px 35px 8px 8px', borderRadius: '4px', border: '1px solid #ccc' }}
                                            required
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowPassword(!showPassword)}
                                            style={{
                                                position: 'absolute', right: '5px', top: '50%', transform: 'translateY(-50%)',
                                                background: 'none', border: 'none', cursor: 'pointer', color: '#666'
                                            }}
                                        >
                                            {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                        </button>
                                    </div>
                                </div>
                            )}

                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px' }}>Role</label>
                                <select
                                    value={formData.role}
                                    onChange={e => setFormData({ ...formData, role: e.target.value })}
                                    style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ccc' }}
                                >
                                    <option value="user">User</option>
                                    <option value="admin">Admin</option>
                                    <option value="nutritionist">Nutritionist</option>
                                </select>
                            </div>

                            {/* Khu vực Checkbox */}
                            <div style={{ marginBottom: '20px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                <label style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '14px', cursor: 'pointer' }}>
                                    <input
                                        type="checkbox"
                                        checked={formData.isActive}
                                        onChange={e => setFormData({ ...formData, isActive: e.target.checked })}
                                    />
                                    Is Active Account (Cho phép Đăng nhập)
                                </label>

                                {/* ✅ CHECKBOX VERIFY EMAIL THỦ CÔNG */}
                                <label style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '10px',
                                    fontSize: '14px',
                                    // Nếu user gốc đã verify thì đổi con trỏ chuột thành hình tròn gạch chéo
                                    cursor: currentUser?.isEmailVerified ? 'not-allowed' : 'pointer',
                                    color: formData.isEmailVerified ? '#28a745' : '#dc3545',
                                    // Làm mờ đi 1 chút nếu đã bị khóa để dễ nhận biết
                                    opacity: currentUser?.isEmailVerified ? 0.7 : 1
                                }}>
                                    <input
                                        type="checkbox"
                                        checked={formData.isEmailVerified}
                                        onChange={e => setFormData({ ...formData, isEmailVerified: e.target.checked })}
                                        // 👇 DÒNG QUAN TRỌNG NHẤT: Khóa checkbox nếu dữ liệu gốc đã là true
                                        disabled={currentUser?.isEmailVerified}
                                    />
                                    <strong>Email Verified</strong>
                                    {currentUser?.isEmailVerified ? "(Đã xác thực - Không thể hủy)" : "(Xác thực Email thủ công)"}
                                </label>
                            </div>

                            <button type="submit" style={{ width: '100%', padding: '10px', background: '#30a5ff', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
                                {isEditing ? 'Save Changes' : 'Create User'}
                            </button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default UserPage;