import React, { useEffect, useState } from 'react';
import axiosClient from '../../api/axiosClient';
import { Trash2, Edit, Plus, X, Image as ImageIcon, Search, Filter, ChevronLeft, ChevronRight } from 'lucide-react';
import { toast } from 'react-toastify';

const IngredientPage = () => {
    const [ingredients, setIngredients] = useState([]);
    const [loading, setLoading] = useState(true);

    // --- STATE PHÂN TRANG ---
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(0);
    const ITEMS_PER_PAGE = 12;

    // --- STATE MODAL ---
    const [showModal, setShowModal] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [currentId, setCurrentId] = useState(null);

    // --- STATE TÌM KIẾM & LỌC ---
    const [filters, setFilters] = useState({
        keyword: '',
        unit: ''
    });

    // --- STATE FORM DATA ---
    const [formData, setFormData] = useState({
        name: '', calories_per_unit: '', protein: '', carbs: '', fats: '', unit: 'gram', ImageUrl: '', description: ''
    });

    const [availableMicros, setAvailableMicros] = useState([]);
    const [selectedMicros, setSelectedMicros] = useState([]);
    const [showDetail, setShowDetail] = useState(false);
    const [detailData, setDetailData] = useState(null);

    const blockInvalidChar = (e) => ['e', 'E', '+', '-', ',', '.'].includes(e.key) && e.preventDefault();

    const handleNumberChange = (field, value) => {
        let val = value;
        if (val > 10000) val = 10000;
        if (val < 0) val = 0;
        setFormData({ ...formData, [field]: val });
    };

    // 1. Gọi API lấy danh sách (Có phân trang)
    const fetchIngredients = async () => {
        try {
            setLoading(true);
            const res = await axiosClient.get('/ingredients', {
                params: {
                    keyword: filters.keyword,
                    unit: filters.unit,
                    page: currentPage,      // Gửi trang hiện tại
                    limit: ITEMS_PER_PAGE   // Số lượng item/trang
                }
            });
            if(res.data.success) {
                setIngredients(res.data.data.ingredients);
                // Backend của bạn cần trả về totalPages, nếu chưa có thì có thể tính tạm hoặc yêu cầu backend update
                setTotalPages(res.data.data.totalPages || 1);
            }
        } catch (error) {
            console.error(error);
            toast.error("Failed to fetch data");
        } finally {
            setLoading(false);
        }
    };

    // Effect: Gọi lại khi Filters hoặc Page thay đổi
    useEffect(() => {
        const timer = setTimeout(() => {
            fetchIngredients();
        }, 500);
        return () => clearTimeout(timer);
    }, [filters, currentPage]);

    // Reset về trang 1 khi đổi bộ lọc
    useEffect(() => {
        setCurrentPage(1);
    }, [filters]);

    useEffect(() => {
        const fetchMicros = async () => {
            try {
                const res = await axiosClient.get('/micronutrients', { params: { limit: 1000 } });
                if (res.data && res.data.success) {
                    setAvailableMicros(res.data.data?.micronutrients || res.data.data || []);
                }
            } catch (err) {
                console.error('Failed to load micronutrients', err);
            }
        };
        fetchMicros();
    }, []);

    // --- HANDLERS PHÂN TRANG ---
    const handlePrevPage = () => { if (currentPage > 1) setCurrentPage(prev => prev - 1); };
    const handleNextPage = () => { if (currentPage < totalPages) setCurrentPage(prev => prev + 1); };

    // --- MODAL HANDLERS ---
    const handleOpenCreate = () => {
        setIsEditing(false);
        setFormData({ name: '', calories_per_unit: '', protein: '', carbs: '', fats: '', unit: 'gram', ImageUrl: '', description: '' });
        setSelectedMicros([]);
        setShowModal(true);
    };

    const handleOpenEdit = async (item) => {
        setIsEditing(true);
        setCurrentId(item._id);
        try {
            const res = await axiosClient.get(`/ingredients/${item._id}`);
            if (res.data && res.data.success) {
                const data = res.data.data;
                setFormData({
                    name: data.name || '',
                    calories_per_unit: data.calories_per_unit || '',
                    protein: data.protein || '',
                    carbs: data.carbs || '',
                    fats: data.fats || '',
                    unit: data.unit || 'gram',
                    ImageUrl: data.ImageUrl || '',
                    description: data.description || ''
                });
                const micros = (data.micronutrients || []).map(m => ({ micronutrientId: m.micronutrientId || m._id || m.id, amount: m.amount }));
                setSelectedMicros(micros);
            } else {
                setFormData({ ...item, ImageUrl: item.ImageUrl || '', description: item.description || '' });
                setSelectedMicros([]);
            }
        } catch (err) {
            setFormData({ ...item, ImageUrl: item.ImageUrl || '', description: item.description || '' });
            setSelectedMicros([]);
        }
        setShowModal(true);
    };

    const handleDelete = async (id) => {
        if(!window.confirm("Delete this ingredient?")) return;
        try {
            const res = await axiosClient.delete(`/ingredients/delete/${id}`);
            toast.success(res.data.message);
            fetchIngredients();
        } catch (error) {
            toast.error(error.response?.data?.message || "Error deleting");
        }
    };

    const handleView = async (id) => {
        try {
            const res = await axiosClient.get(`/ingredients/${id}`);
            if (res.data && res.data.success) {
                setDetailData(res.data.data);
                setShowDetail(true);
            }
        } catch (err) {
            toast.error('Failed to load detail');
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const payload = { ...formData, micronutrients: selectedMicros };
            let res;
            if (isEditing) {
                res = await axiosClient.put(`/ingredients/update/${currentId}`, payload);
            } else {
                res = await axiosClient.post('/ingredients/create', payload);
            }
            toast.success(res.data.message);
            setShowModal(false);
            fetchIngredients();
        } catch (error) {
            const serverMessage = error.response?.data?.message;
            toast.error(serverMessage || "Action failed");
        }
    };

    return (
        <div>
            <h2 style={{ color: '#30a5ff', marginBottom: '20px' }}>Ingredients Management</h2>

            {/* --- TOOLBAR --- */}
            <div style={{ background: 'white', padding: '15px', borderRadius: '5px', marginBottom: '20px', display: 'flex', gap: '15px', alignItems: 'center', boxShadow: '0 1px 2px rgba(0,0,0,0.1)' }}>
                <div style={{ position: 'relative', flex: 1 }}>
                    <Search size={18} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <input
                        type="text" placeholder="Search ingredients..."
                        value={filters.keyword} onChange={(e) => setFilters({...filters, keyword: e.target.value})}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd' }}
                    />
                </div>
                <div style={{ position: 'relative', width: '200px' }}>
                    <Filter size={16} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <select
                        value={filters.unit} onChange={(e) => setFilters({...filters, unit: e.target.value})}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd', cursor: 'pointer' }}
                    >
                        <option value="">All Units</option>
                        <option value="gram">gram</option>
                        <option value="ml">ml</option>
                        <option value="piece">piece</option>
                        <option value="cup">cup</option>
                    </select>
                </div>
                <button onClick={handleOpenCreate} style={{ background: '#30a5ff', color: 'white', border: 'none', padding: '10px 20px', borderRadius: '4px', cursor: 'pointer', display: 'flex', gap: '5px', fontWeight: 'bold' }}>
                    <Plus size={18}/> Add Ingredient
                </button>
            </div>

            {/* --- LIST CARDS --- */}
            {loading ? <p style={{textAlign:'center', color: '#666'}}>Loading data...</p> : (
                <>
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '20px' }}>
                        {ingredients.map((item) => (
                            <div key={item._id} style={{ background: 'white', borderRadius: '8px', overflow: 'hidden', boxShadow: '0 2px 5px rgba(0,0,0,0.1)', border: '1px solid #eee' }}>
                                <div style={{ height: '160px', background: '#f8f9fa' }}>
                                    {item.ImageUrl ? <img src={item.ImageUrl} alt={item.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : <div style={{ display:'flex', justifyContent:'center', alignItems:'center', height:'100%', color:'#ccc' }}><ImageIcon size={40}/></div>}
                                </div>
                                <div style={{ padding: '15px' }}>
                                    <h3 style={{ margin: '0 0 5px 0', color: '#333' }}>{item.name}</h3>
                                    <p style={{ margin: '0', color: '#666', fontSize: '14px' }}>Calories: <strong style={{color:'#30a5ff'}}>{item.calories_per_unit}</strong> / {item.unit}</p>
                                    <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '15px', gap: '15px' }}>
                                        <button onClick={() => handleView(item._id)} style={{ color: '#555', background: 'none', border: 'none', cursor: 'pointer' }}>View</button>
                                        <button onClick={() => handleOpenEdit(item)} style={{ color: '#30a5ff', background: 'none', border: 'none', cursor: 'pointer' }}><Edit size={20}/></button>
                                        <button onClick={() => handleDelete(item._id)} style={{ color: '#f9243f', background: 'none', border: 'none', cursor: 'pointer' }}><Trash2 size={20}/></button>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* --- PAGINATION CONTROLS --- */}
                    {ingredients.length > 0 && (
                        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '20px', marginTop: '30px', paddingBottom: '20px' }}>
                            <button
                                onClick={handlePrevPage} disabled={currentPage === 1}
                                style={{ background: currentPage === 1 ? '#eee' : 'white', border: '1px solid #ddd', padding: '8px 15px', borderRadius: '5px', cursor: currentPage === 1 ? 'not-allowed' : 'pointer', display: 'flex', alignItems: 'center', gap: '5px', color: currentPage === 1 ? '#999' : '#333' }}
                            >
                                <ChevronLeft size={18}/> Previous
                            </button>
                            <span style={{ fontWeight: 'bold', color: '#5f6468' }}>Page {currentPage} of {totalPages}</span>
                            <button
                                onClick={handleNextPage} disabled={currentPage === totalPages}
                                style={{ background: currentPage === totalPages ? '#eee' : 'white', border: '1px solid #ddd', padding: '8px 15px', borderRadius: '5px', cursor: currentPage === totalPages ? 'not-allowed' : 'pointer', display: 'flex', alignItems: 'center', gap: '5px', color: currentPage === totalPages ? '#999' : '#333' }}
                            >
                                Next <ChevronRight size={18}/>
                            </button>
                        </div>
                    )}
                </>
            )}

            {/* --- MODALS (Create/Edit/Detail - Code cũ giữ nguyên bên dưới) --- */}
            {showModal && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '500px', maxHeight: '90vh', overflowY: 'auto', position: 'relative' }}>
                        <button onClick={() => setShowModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={20} /></button>
                        <h3 style={{ marginTop: 0, color: '#30a5ff' }}>{isEditing ? 'Edit Ingredient' : 'Add New Ingredient'}</h3>
                        <form onSubmit={handleSubmit}>
                            {/* ... FORM CONTENT GIỮ NGUYÊN ... */}
                            <div style={{ marginBottom: '10px' }}>
                                <label style={{ display: 'block', fontSize: '13px' }}>Ingredient Name</label>
                                <input type="text" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} required />
                            </div>
                            {/* ... CÁC INPUT KHÁC GIỮ NGUYÊN ... */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginBottom: '10px' }}>
                                <div>
                                    <label style={{ display: 'block', fontSize: '13px' }}>Calories / Unit</label>
                                    <input type="number" onKeyDown={blockInvalidChar} value={formData.calories_per_unit} onChange={e => handleNumberChange('calories_per_unit', e.target.value)} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} required />
                                </div>
                                <div>
                                    <label style={{ display: 'block', fontSize: '13px' }}>Unit</label>
                                    <select value={formData.unit} onChange={e => setFormData({...formData, unit: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}>
                                        <option value="gram">gram</option>
                                        <option value="ml">ml</option>
                                        <option value="piece">piece</option>
                                        <option value="cup">cup</option>
                                    </select>
                                </div>
                            </div>
                            {/* ... */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '10px', marginBottom: '10px' }}>
                                <div>
                                    <label style={{ display: 'block', fontSize: '12px' }}>Protein (g)</label>
                                    <input type="number" onKeyDown={blockInvalidChar} value={formData.protein} onChange={e => handleNumberChange('protein', e.target.value)} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} required />
                                </div>
                                <div>
                                    <label style={{ display: 'block', fontSize: '12px' }}>Carbs (g)</label>
                                    <input type="number" onKeyDown={blockInvalidChar} value={formData.carbs} onChange={e => handleNumberChange('carbs', e.target.value)} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} required />
                                </div>
                                <div>
                                    <label style={{ display: 'block', fontSize: '12px' }}>Fats (g)</label>
                                    <input type="number" onKeyDown={blockInvalidChar} value={formData.fats} onChange={e => handleNumberChange('fats', e.target.value)} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} required />
                                </div>
                            </div>
                            <div style={{ marginBottom: '10px' }}>
                                <label style={{ display: 'block', fontSize: '13px' }}>Image URL</label>
                                <input type="text" value={formData.ImageUrl} onChange={e => setFormData({...formData, ImageUrl: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} placeholder="https://..." />
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', fontSize: '13px' }}>Description</label>
                                <textarea rows="2" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}></textarea>
                            </div>
                            {/* MICRONUTRIENTS SECTION */}
                            <div style={{ marginBottom: '12px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '6px' }}>Micronutrients (optional)</label>
                                {selectedMicros.map((m, idx) => (
                                    <div key={idx} style={{ display: 'flex', gap: '8px', marginBottom: '8px' }}>
                                        <select
                                            value={m.micronutrientId || ''}
                                            onChange={e => {
                                                const copy = [...selectedMicros];
                                                copy[idx].micronutrientId = e.target.value;
                                                setSelectedMicros(copy);
                                            }}
                                            style={{ flex: 1, padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                        >
                                            <option value="">Select micronutrient</option>
                                            {availableMicros
                                                .filter(a => {
                                                    const id = a._id || a.id;
                                                    const already = selectedMicros.some((s, si) => s.micronutrientId === id && si !== idx);
                                                    return !already || (m.micronutrientId && (m.micronutrientId === id));
                                                })
                                                .map(a => <option key={a._id || a.id} value={a._id || a.id}>{a.name}</option>)}
                                        </select>
                                        <input type="number" min="0" onKeyDown={blockInvalidChar} value={m.amount}
                                               onChange={e => {
                                                   const copy = [...selectedMicros];
                                                   copy[idx].amount = e.target.value;
                                                   setSelectedMicros(copy);
                                               }}
                                               placeholder="amount" style={{ width: '110px', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} />
                                        <button type="button" onClick={() => { const copy = selectedMicros.filter((_, i) => i !== idx); setSelectedMicros(copy); }} style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: '#f0243f' }}><Trash2 size={16}/></button>
                                    </div>
                                ))}
                                <div>
                                    <button type="button" onClick={() => setSelectedMicros([...selectedMicros, { micronutrientId: '', amount: '' }])} style={{ background: '#eef6ff', border: '1px dashed #30a5ff', padding: '6px 10px', borderRadius: '4px', cursor: 'pointer' }}>
                                        + Add micronutrient
                                    </button>
                                </div>
                            </div>
                            <button type="submit" style={{ width: '100%', padding: '12px', background: '#30a5ff', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
                                {isEditing ? 'Update Ingredient' : 'Add Ingredient'}
                            </button>
                        </form>
                    </div>
                </div>
            )}

            {/* --- DETAIL MODAL --- */}
            {showDetail && detailData && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1100 }}>
                    <div style={{ background: 'white', padding: '24px', borderRadius: '8px', width: '520px', maxHeight: '80vh', overflowY: 'auto', position: 'relative' }}>
                        <button onClick={() => { setShowDetail(false); setDetailData(null); }} style={{ position: 'absolute', top: '12px', right: '12px', border: 'none', background: 'none', cursor: 'pointer' }}><X size={18} /></button>
                        <h3 style={{ marginTop: 0, color: '#30a5ff' }}>{detailData.name}</h3>
                        <p><strong>Unit:</strong> {detailData.unit} &nbsp; <strong>Calories/Unit:</strong> {detailData.calories_per_unit}</p>
                        <p><strong>Protein:</strong> {detailData.protein}g &nbsp; <strong>Carbs:</strong> {detailData.carbs}g &nbsp; <strong>Fats:</strong> {detailData.fats}g</p>
                        <p style={{ whiteSpace: 'pre-wrap' }}>{detailData.description}</p>
                        <h4 style={{ marginTop: '12px' }}>Micronutrients</h4>
                        {detailData.micronutrients && detailData.micronutrients.length ? (
                            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                                <thead>
                                <tr style={{ textAlign: 'left', borderBottom: '1px solid #eee' }}>
                                    <th style={{ padding: '8px' }}>Name</th>
                                    <th style={{ padding: '8px' }}>Amount</th>
                                    <th style={{ padding: '8px' }}>Unit</th>
                                </tr>
                                </thead>
                                <tbody>
                                {detailData.micronutrients.map((m, i) => (
                                    <tr key={i} style={{ borderBottom: '1px solid #fafafa' }}>
                                        <td style={{ padding: '8px' }}>{m.name || (m.micronutrientId)}</td>
                                        <td style={{ padding: '8px' }}>{m.amount}</td>
                                        <td style={{ padding: '8px' }}>{m.unit || '-'}</td>
                                    </tr>
                                ))}
                                </tbody>
                            </table>
                        ) : (
                            <p style={{ color: '#666' }}>No micronutrients linked.</p>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
};

export default IngredientPage;