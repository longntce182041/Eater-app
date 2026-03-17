import React, { useCallback, useEffect, useState } from 'react';
import axiosClient from '../../api/axiosClient';
import { Trash2, Edit, X, Search, Filter, Star, Eye, MessageCircle } from 'lucide-react';
import { toast } from 'react-toastify';

const ReviewsPage = () => {
    const [reviews, setReviews] = useState([]);
    const [loading, setLoading] = useState(true);

    // --- PAGINATION STATE ---
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(0);
    const ITEMS_PER_PAGE = 10;

    // --- MODAL STATE ---
    const [showEditModal, setShowEditModal] = useState(false);
    const [showDetailModal, setShowDetailModal] = useState(false);
    const [selectedReview, setSelectedReview] = useState(null);

    // --- FILTERS ---
    const [keyword, setKeyword] = useState('');
    const [ratingFilter, setRatingFilter] = useState('');

    // --- FORM DATA (For Update) ---
    const [formData, setFormData] = useState({
        rating: 5,
        comment: ''
    });

    // 1. Fetch Reviews
    const fetchReviews = useCallback(async () => {
        try {
            setLoading(true);
            const res = await axiosClient.get('/reviews', {
                params: {
                    keyword,
                    rating: ratingFilter,
                    page: currentPage,
                    limit: ITEMS_PER_PAGE
                }
            });
            if (res.data.success) {
                setReviews(res.data.data.reviews);
                setTotalPages(res.data.data.totalPages || 1);
            }
        } catch (error) {
            console.error(error);
            toast.error("Failed to fetch reviews");
        } finally {
            setLoading(false);
        }
    }, [keyword, ratingFilter, currentPage]);

    // Effect: Gọi lại khi filter hoặc page thay đổi
    useEffect(() => {
        const timer = setTimeout(() => fetchReviews(), 500);
        return () => clearTimeout(timer);
    }, [fetchReviews]);

    // Helper: Render số sao thành icon
    const renderStars = (count) => {
        return [...Array(5)].map((_, index) => (
            <Star
                key={index}
                size={14}
                fill={index < count ? "#ffc107" : "none"}
                color={index < count ? "#ffc107" : "#ccc"}
            />
        ));
    };

    // --- HANDLERS ---

    const handleDelete = async (id) => {
        if (!window.confirm("Are you sure you want to delete this review?")) return;
        try {
            // Gọi route: DELETE /reviews/delete/:id (Đúng theo backend của bạn)
            const res = await axiosClient.delete(`/reviews/delete/${id}`);
            toast.success(res.data.message);
            fetchReviews();
        } catch (error) {
            toast.error(error.response?.data?.message || "Delete failed");
        }
    };

    const handleOpenEdit = (review) => {
        setSelectedReview(review);
        setFormData({
            rating: review.rating,
            comment: review.comment
        });
        setShowEditModal(true);
    };

    const handleUpdate = async (e) => {
        e.preventDefault();
        try {
            // Gọi route: PUT /reviews/update/:id (Đúng theo backend của bạn)
            const res = await axiosClient.put(`/reviews/update/${selectedReview._id}`, formData);
            toast.success(res.data.message);
            setShowEditModal(false);
            fetchReviews();
        } catch (error) {
            toast.error(error.response?.data?.message || "Update failed");
        }
    };

    const handleViewDetail = (review) => {
        setSelectedReview(review);
        setShowDetailModal(true);
    };

    return (
        <div>
            <h2 style={{ color: '#30a5ff', marginBottom: '20px' }}>Reviews Management</h2>

            {/* --- TOOLBAR --- */}
            <div style={{ background: 'white', padding: '15px', borderRadius: '5px', marginBottom: '20px', display: 'flex', gap: '15px', alignItems: 'center', boxShadow: '0 1px 2px rgba(0,0,0,0.1)' }}>
                {/* Search Comment */}
                <div style={{ position: 'relative', flex: 1 }}>
                    <Search size={18} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <input
                        type="text" placeholder="Search comments..."
                        value={keyword} onChange={(e) => setKeyword(e.target.value)}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd' }}
                    />
                </div>

                {/* Filter Rating */}
                <div style={{ position: 'relative', width: '200px' }}>
                    <Filter size={16} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <select
                        value={ratingFilter} onChange={(e) => setRatingFilter(e.target.value)}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd', cursor: 'pointer' }}
                    >
                        <option value="">All Ratings</option>
                        <option value="5">5 Stars</option>
                        <option value="4">4 Stars</option>
                        <option value="3">3 Stars</option>
                        <option value="2">2 Stars</option>
                        <option value="1">1 Star</option>
                    </select>
                </div>
            </div>

            {/* --- TABLE LIST --- */}
            <div style={{ background: 'white', padding: '20px', borderRadius: '5px', boxShadow: '0 1px 2px rgba(0,0,0,0.1)' }}>
                {loading ? <p style={{ textAlign: 'center', color: '#666' }}>Loading reviews...</p> : (
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                            <tr style={{ borderBottom: '2px solid #eee', textAlign: 'left', color: '#5f6468' }}>
                                <th style={{ padding: '10px' }}>User</th>
                                <th style={{ padding: '10px' }}>Recipe</th>
                                <th style={{ padding: '10px', width: '100px' }}>Rating</th>
                                <th style={{ padding: '10px' }}>Comment</th>
                                <th style={{ padding: '10px', width: '150px' }}>Date</th>
                                <th style={{ padding: '10px', width: '120px' }}>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {reviews.length > 0 ? reviews.map((item) => (
                                <tr key={item._id} style={{ borderBottom: '1px solid #eee', color: '#666' }}>
                                    {/* Cột User */}
                                    <td style={{ padding: '12px' }}>
                                        <div style={{ fontWeight: 'bold', fontSize: '13px' }}>{item.userId?.email || 'Unknown User'}</div>
                                        <div style={{ fontSize: '11px', color: '#999' }}>{item.userId?.role}</div>
                                    </td>

                                    {/* Cột Recipe */}
                                    <td style={{ padding: '12px' }}>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                            {item.recipeId?.imageUrl && (
                                                <img src={item.recipeId.imageUrl} alt="" style={{ width: '40px', height: '40px', borderRadius: '4px', objectFit: 'cover' }} />
                                            )}
                                            <span style={{ fontWeight: '500' }}>{item.recipeId?.name || 'Unknown Recipe'}</span>
                                        </div>
                                    </td>

                                    {/* Cột Rating */}
                                    <td style={{ padding: '12px' }}>
                                        <div style={{ display: 'flex' }}>{renderStars(item.rating)}</div>
                                    </td>

                                    {/* Cột Comment (Cắt ngắn nếu dài) */}
                                    <td style={{ padding: '12px', fontSize: '13px', fontStyle: 'italic' }}>
                                        "{item.comment.length > 50 ? item.comment.substring(0, 50) + '...' : item.comment}"
                                    </td>

                                    {/* Cột Date */}
                                    <td style={{ padding: '12px', fontSize: '13px' }}>
                                        {new Date(item.createdAt).toLocaleDateString()}
                                    </td>

                                    {/* Actions */}
                                    <td style={{ padding: '12px' }}>
                                        <button onClick={() => handleViewDetail(item)} style={{ marginRight: '8px', border: 'none', background: 'none', cursor: 'pointer', color: '#555' }} title="View Detail">
                                            <Eye size={18} />
                                        </button>
                                        <button onClick={() => handleOpenEdit(item)} style={{ marginRight: '8px', border: 'none', background: 'none', cursor: 'pointer', color: '#30a5ff' }} title="Edit">
                                            <Edit size={18} />
                                        </button>
                                        <button onClick={() => handleDelete(item._id)} style={{ border: 'none', background: 'none', cursor: 'pointer', color: '#f9243f' }} title="Delete">
                                            <Trash2 size={18} />
                                        </button>
                                    </td>
                                </tr>
                            )) : (
                                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '20px' }}>No reviews found.</td></tr>
                            )}
                        </tbody>
                    </table>
                )}

                {/* Phân trang (Giản lược) */}
                <div style={{ marginTop: '20px', display: 'flex', justifyContent: 'center', gap: '10px' }}>
                    <button disabled={currentPage === 1} onClick={() => setCurrentPage(p => p - 1)} style={{ padding: '5px 10px', cursor: 'pointer' }}>&lt; Prev</button>
                    <span>Page {currentPage} of {totalPages}</span>
                    <button disabled={currentPage === totalPages} onClick={() => setCurrentPage(p => p + 1)} style={{ padding: '5px 10px', cursor: 'pointer' }}>Next &gt;</button>
                </div>
            </div>

            {/* --- MODAL EDIT (Moderation) --- */}
            {showEditModal && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '450px', position: 'relative' }}>
                        <button onClick={() => setShowEditModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background: 'none', cursor: 'pointer' }}><X size={20} /></button>
                        <h3 style={{ marginTop: 0, color: '#30a5ff' }}>Edit Review</h3>

                        <form onSubmit={handleUpdate}>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', marginBottom: '5px', fontSize: '13px' }}>Rating</label>
                                <select
                                    value={formData.rating}
                                    onChange={e => setFormData({ ...formData, rating: parseInt(e.target.value) })}
                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                >
                                    {[1, 2, 3, 4, 5].map(num => <option key={num} value={num}>{num} Stars</option>)}
                                </select>
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', marginBottom: '5px', fontSize: '13px' }}>Comment Content</label>
                                <textarea
                                    rows="5"
                                    value={formData.comment}
                                    onChange={e => setFormData({ ...formData, comment: e.target.value })}
                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                />
                            </div>
                            <button type="submit" style={{ width: '100%', padding: '10px', background: '#30a5ff', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
                                Save Changes
                            </button>
                        </form>
                    </div>
                </div>
            )}

            {/* --- MODAL DETAIL (Read Only) --- */}
            {showDetailModal && selectedReview && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '500px', position: 'relative' }}>
                        <button onClick={() => setShowDetailModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background: 'none', cursor: 'pointer' }}><X size={20} /></button>
                        <h3 style={{ marginTop: 0, color: '#30a5ff', display: 'flex', alignItems: 'center', gap: '10px' }}>
                            <MessageCircle size={24} /> Review Detail
                        </h3>

                        <div style={{ marginTop: '20px' }}>
                            <p><strong>User:</strong> {selectedReview.userId?.email}</p>
                            <p><strong>Recipe:</strong> {selectedReview.recipeId?.name}</p>
                            <p style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                                <strong>Rating:</strong> {renderStars(selectedReview.rating)} ({selectedReview.rating}/5)
                            </p>
                            <div style={{ background: '#f9f9f9', padding: '15px', borderRadius: '5px', marginTop: '15px', borderLeft: '4px solid #30a5ff' }}>
                                <p style={{ margin: 0, fontStyle: 'italic', color: '#555' }}>{selectedReview.comment}</p>
                            </div>
                            <p style={{ fontSize: '12px', color: '#999', marginTop: '15px', textAlign: 'right' }}>
                                Created at: {new Date(selectedReview.createdAt).toLocaleString()}
                            </p>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ReviewsPage;