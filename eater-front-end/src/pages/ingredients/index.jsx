import React, { useEffect, useState } from 'react';
import axiosClient from '../../api/axiosClient';
import { Trash2, Edit, Plus, X, Image as ImageIcon, Search, Filter } from 'lucide-react';
import { toast } from 'react-toastify';

const IngredientPage = () => {
    const [ingredients, setIngredients] = useState([]);
    const [loading, setLoading] = useState(true);

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
        name: '',
        calories_per_unit: '',
        protein: '',
        carbs: '',
        fats: '',
        unit: 'gram',
        ImageUrl: '',
        description: ''
    });

    // --- LOGIC VALIDATE TRÊN GIAO DIỆN ---

    // 1. Chặn các ký tự e, E, +, - trong ô input number
    const blockInvalidChar = (e) => ['e', 'E', '+', '-', ',', '.'].includes(e.key) && e.preventDefault();

    // 2. Hàm xử lý thay đổi số (Giới hạn 0 - 10,000)
    const handleNumberChange = (field, value) => {
        let val = value;
        if (val > 10000) val = 10000; // Giới hạn tối đa 10k
        if (val < 0) val = 0;        // Giới hạn tối thiểu 0
        setFormData({ ...formData, [field]: val });
    };

    // 1. Gọi API lấy danh sách
    const fetchIngredients = async () => {
        try {
            setLoading(true);
            const res = await axiosClient.get('/ingredients', {
                params: {
                    keyword: filters.keyword,
                    unit: filters.unit
                }
            });
            if(res.data.success) {
                setIngredients(res.data.data.ingredients);
            }
        } catch (error) {
            console.error(error);
            toast.error("Failed to fetch data");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const timer = setTimeout(() => {
            fetchIngredients();
        }, 500);
        return () => clearTimeout(timer);
    }, [filters]);

    const handleOpenCreate = () => {
        setIsEditing(false);
        setFormData({ name: '', calories_per_unit: '', protein: '', carbs: '', fats: '', unit: 'gram', ImageUrl: '', description: '' });
        setShowModal(true);
    };

    const handleOpenEdit = (item) => {
        setIsEditing(true);
        setCurrentId(item._id);
        setFormData({
            name: item.name,
            calories_per_unit: item.calories_per_unit,
            protein: item.protein,
            carbs: item.carbs,
            fats: item.fats,
            unit: item.unit,
            ImageUrl: item.ImageUrl || '',
            description: item.description || ''
        });
        setShowModal(true);
    };

    const handleDelete = async (id) => {
        if(!window.confirm("Delete this ingredient?")) return;
        try {
            await axiosClient.delete(`/ingredients/delete/${id}`);
            toast.success("Ingredient deleted");
            fetchIngredients();
        } catch (error) {
            toast.error("Error deleting");
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (isEditing) {
                await axiosClient.put(`/ingredients/update/${currentId}`, formData);
                toast.success("Updated successfully!");
            } else {
                await axiosClient.post('/ingredients/create', formData);
                toast.success("Created successfully!");
            }
            setShowModal(false);
            fetchIngredients();
        } catch (error) {
            // Hiển thị lỗi từ Backend Validator trả về
            const serverMessage = error.response?.data?.message;
            const validatorErrors = error.response?.data?.errors;

            if (validatorErrors) {
                const firstError = Object.values(validatorErrors)[0];
                toast.error(firstError);
            } else {
                toast.error(serverMessage || "Action failed");
            }
        }
    };

    return (
        <div>
            <h2 style={{ color: '#30a5ff', marginBottom: '20px' }}>Ingredients Management</h2>

            {/* --- TOOLBAR --- */}
            <div style={{
                background: 'white', padding: '15px', borderRadius: '5px', marginBottom: '20px',
                display: 'flex', gap: '15px', alignItems: 'center', boxShadow: '0 1px 2px rgba(0,0,0,0.1)'
            }}>
                <div style={{ position: 'relative', flex: 1 }}>
                    <Search size={18} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <input
                        type="text"
                        placeholder="Search ingredients by name..."
                        value={filters.keyword}
                        onChange={(e) => setFilters({...filters, keyword: e.target.value})}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd' }}
                    />
                </div>

                <div style={{ position: 'relative', width: '200px' }}>
                    <Filter size={16} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <select
                        value={filters.unit}
                        onChange={(e) => setFilters({...filters, unit: e.target.value})}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd', cursor: 'pointer' }}
                    >
                        <option value="">All Units</option>
                        <option value="100g">gram</option>
                        <option value="ml">ml</option>
                        <option value="piece">piece</option>
                        <option value="cup">cup</option>
                    </select>
                </div>

                <button
                    onClick={handleOpenCreate}
                    style={{
                        background: '#30a5ff', color: 'white', border: 'none',
                        padding: '10px 20px', borderRadius: '4px', cursor: 'pointer',
                        display: 'flex', alignItems: 'center', gap: '5px', fontWeight: 'bold'
                    }}
                >
                    <Plus size={18}/> Add Ingredient
                </button>
            </div>

            {/* --- LIST CARDS --- */}
            {loading ? <p style={{textAlign:'center'}}>Loading...</p> : (
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
                                    <button onClick={() => handleOpenEdit(item)} style={{ color: '#30a5ff', background: 'none', border: 'none', cursor: 'pointer' }}><Edit size={20}/></button>
                                    <button onClick={() => handleDelete(item._id)} style={{ color: '#f9243f', background: 'none', border: 'none', cursor: 'pointer' }}><Trash2 size={20}/></button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* --- MODAL --- */}
            {showModal && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '500px', maxHeight: '90vh', overflowY: 'auto', position: 'relative' }}>
                        <button onClick={() => setShowModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={20} /></button>
                        <h3 style={{ marginTop: 0, color: '#30a5ff' }}>{isEditing ? 'Edit Ingredient' : 'Add New Ingredient'}</h3>

                        <form onSubmit={handleSubmit}>
                            <div style={{ marginBottom: '10px' }}>
                                <label style={{ display: 'block', fontSize: '13px' }}>Ingredient Name</label>
                                <input type="text" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} required />
                            </div>

                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginBottom: '10px' }}>
                                <div>
                                    <label style={{ display: 'block', fontSize: '13px' }}>Calories / Unit</label>
                                    <input
                                        type="number"
                                        onKeyDown={blockInvalidChar}
                                        value={formData.calories_per_unit}
                                        onChange={e => handleNumberChange('calories_per_unit', e.target.value)}
                                        style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                        required
                                    />
                                </div>
                                <div>
                                    <label style={{ display: 'block', fontSize: '13px' }}>Unit</label>
                                    <select value={formData.unit} onChange={e => setFormData({...formData, unit: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}>
                                        <option value="100g">gram</option>
                                        <option value="ml">ml</option>
                                        <option value="piece">piece</option>
                                        <option value="cup">cup</option>
                                    </select>
                                </div>
                            </div>

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

                            <button type="submit" style={{ width: '100%', padding: '12px', background: '#30a5ff', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
                                {isEditing ? 'Update Ingredient' : 'Add Ingredient'}
                            </button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default IngredientPage;