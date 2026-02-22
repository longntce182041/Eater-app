import React, { useEffect, useState } from 'react';
import axiosClient from '../../api/axiosClient';
import { Trash2, Edit, Plus, X, Search, Filter, ChefHat, Clock, Users, Eye, Activity, ChevronLeft, ChevronRight } from 'lucide-react';
import { toast } from 'react-toastify';

const RecipesPage = () => {
    const [recipes, setRecipes] = useState([]);
    const [allIngredients, setAllIngredients] = useState([]);
    const [loading, setLoading] = useState(true);

    // --- STATE PHÂN TRANG (PAGINATION) ---
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(0);
    const ITEMS_PER_PAGE = 12; // Số món trên 1 trang (để 12 cho đẹp lưới)

    // --- STATE MODALS ---
    const [showModal, setShowModal] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [currentId, setCurrentId] = useState(null);
    const [showDetail, setShowDetail] = useState(false);
    const [detailData, setDetailData] = useState(null);

    // --- FILTER ---
    const [keyword, setKeyword] = useState('');

    // --- FORM DATA ---
    const [formData, setFormData] = useState({
        name: '', description: '', cookingTime: '', baseServings: '', imageUrl: '', status: 'draft',
        ingredients: [], steps: [],
        nutrition: { calories: 0, protein: 0, fat: 0, carbohydrates: 0 }
    });

    // 1. Load danh sách Recipes (Có phân trang)
    const fetchRecipes = async () => {
        try {
            setLoading(true);
            const res = await axiosClient.get('/recipes', {
                params: {
                    keyword,
                    page: currentPage,      // Gửi trang hiện tại
                    limit: ITEMS_PER_PAGE   // Gửi số lượng muốn lấy
                }
            });
            if (res.data.success) {
                setRecipes(res.data.data.recipes);
                setTotalPages(res.data.data.totalPages); // Lưu tổng số trang backend trả về
            }
        } catch (error) {
            toast.error("Failed to fetch recipes");
        } finally {
            setLoading(false);
        }
    };

    // 2. Load Ingredients cho dropdown
    const fetchAllIngredients = async () => {
        try {
            const res = await axiosClient.get('/ingredients', { params: { limit: 1000 } });
            if (res.data.success) setAllIngredients(res.data.data.ingredients);
        } catch (error) {
            console.error("Failed to load ingredients");
        }
    };

    useEffect(() => {
        fetchAllIngredients();
    }, []);

    // Effect: Khi Keyword thay đổi -> Reset về trang 1
    useEffect(() => {
        setCurrentPage(1);
    }, [keyword]);

    // Effect: Gọi API khi trang thay đổi hoặc keyword thay đổi (sau debounce)
    useEffect(() => {
        const timer = setTimeout(() => {
            fetchRecipes();
        }, 500);
        return () => clearTimeout(timer);
    }, [currentPage, keyword]);

    // --- HANDLERS PHÂN TRANG ---
    const handlePrevPage = () => {
        if (currentPage > 1) setCurrentPage(prev => prev - 1);
    };

    const handleNextPage = () => {
        if (currentPage < totalPages) setCurrentPage(prev => prev + 1);
    };

    // --- DYNAMIC FORM HANDLERS ---
    const addIngredientRow = () => {
        setFormData({
            ...formData,
            ingredients: [...formData.ingredients, { ingredientId: '', base_quantity: '', unit: 'g' }]
        });
    };

    const removeIngredientRow = (index) => {
        const newIngs = [...formData.ingredients];
        newIngs.splice(index, 1);
        setFormData({ ...formData, ingredients: newIngs });
    };

    const handleIngredientChange = (index, field, value) => {
        const newIngs = [...formData.ingredients];
        newIngs[index][field] = value;
        setFormData({ ...formData, ingredients: newIngs });
    };

    const addStepRow = () => {
        setFormData({
            ...formData,
            steps: [...formData.steps, { stepNumber: formData.steps.length + 1, instruction: '' }]
        });
    };

    const removeStepRow = (index) => {
        const newSteps = [...formData.steps];
        newSteps.splice(index, 1);
        const reorderedSteps = newSteps.map((s, i) => ({ ...s, stepNumber: i + 1 }));
        setFormData({ ...formData, steps: reorderedSteps });
    };

    const handleStepChange = (index, value) => {
        const newSteps = [...formData.steps];
        newSteps[index].instruction = value;
        setFormData({ ...formData, steps: newSteps });
    };

    // --- MODAL HANDLERS ---
    const handleOpenCreate = () => {
        setIsEditing(false);
        setFormData({
            name: '', description: '', cookingTime: '', baseServings: '', imageUrl: '', status: 'draft',
            ingredients: [], steps: [],
            nutrition: { calories: 0, protein: 0, fat: 0, carbohydrates: 0 }
        });
        setShowModal(true);
    };

    const handleOpenEdit = async (id) => {
        try {
            const res = await axiosClient.get(`/recipes/${id}`);
            if (res.data.success) {
                const data = res.data.data;
                const formattedIngredients = data.ingredients.map(ing => ({
                    ingredientId: ing.ingredientId?._id || ing.ingredientId,
                    base_quantity: ing.base_quantity,
                    unit: ing.unit
                }));

                setFormData({
                    name: data.name,
                    description: data.description,
                    cookingTime: data.cookingTime,
                    baseServings: data.baseServings,
                    imageUrl: data.imageUrl || '',
                    status: data.status,
                    ingredients: formattedIngredients,
                    steps: data.steps,
                    nutrition: data.nutrition || { calories: 0, protein: 0, fat: 0, carbohydrates: 0 }
                });
                setIsEditing(true);
                setCurrentId(id);
                setShowModal(true);
            }
        } catch (error) {
            toast.error("Error fetching detail");
        }
    };

    const handleViewDetail = async (id) => {
        try {
            const res = await axiosClient.get(`/recipes/${id}`);
            if (res.data.success) {
                setDetailData(res.data.data);
                setShowDetail(true);
            }
        } catch (error) {
            toast.error("Failed to load details");
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const payload = { ...formData, dietTypeIds: [] };
            let res;
            if (isEditing) {
                res = await axiosClient.put(`/recipes/update/${currentId}`, payload);
            } else {
                res = await axiosClient.post('/recipes/create', payload);
            }
            toast.success(res.data.message);
            setShowModal(false);
            fetchRecipes(); // Refresh list
        } catch (error) {
            toast.error(error.response?.data?.message || "Action failed");
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm("Delete this recipe?")) return;
        try {
            const res = await axiosClient.delete(`/recipes/delete/${id}`);
            toast.success(res.data.message);
            fetchRecipes();
        } catch (error) {
            toast.error("Failed to delete");
        }
    };

    return (
        <div>
            <h2 style={{ color: '#30a5ff', marginBottom: '20px' }}>Recipes Management</h2>

            {/* TOOLBAR */}
            <div style={{ background: 'white', padding: '15px', borderRadius: '5px', marginBottom: '20px', display: 'flex', gap: '15px', alignItems: 'center', boxShadow: '0 1px 2px rgba(0,0,0,0.1)' }}>
                <div style={{ position: 'relative', flex: 1 }}>
                    <Search size={18} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <input
                        type="text" placeholder="Search recipes..."
                        value={keyword} onChange={(e) => setKeyword(e.target.value)}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd' }}
                    />
                </div>
                <button onClick={handleOpenCreate} style={{ background: '#30a5ff', color: 'white', border: 'none', padding: '10px 20px', borderRadius: '4px', cursor: 'pointer', display: 'flex', gap: '5px', fontWeight: 'bold' }}>
                    <Plus size={18}/> New Recipe
                </button>
            </div>

            {/* LIST RECIPES */}
            {loading ? (
                <p style={{ textAlign: 'center', color: '#666' }}>Loading recipes...</p>
            ) : (
                <>
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '20px' }}>
                        {recipes.map((item) => (
                            <div key={item._id} style={{ background: 'white', borderRadius: '8px', overflow: 'hidden', boxShadow: '0 2px 5px rgba(0,0,0,0.1)', border: '1px solid #eee' }}>
                                <div style={{ height: '180px', background: '#f0f0f0', position: 'relative' }}>
                                    {item.imageUrl ?
                                        <img src={item.imageUrl} alt={item.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                        : <div style={{display:'flex',justifyContent:'center',alignItems:'center',height:'100%',color:'#ccc'}}><ChefHat size={40}/></div>
                                    }
                                    <span style={{ position: 'absolute', top: 10, right: 10, background: item.status === 'published' ? '#28a745' : '#ffc107', color: 'white', padding: '3px 8px', borderRadius: '4px', fontSize: '12px', fontWeight: 'bold', textTransform: 'uppercase' }}>
                                        {item.status}
                                    </span>
                                </div>
                                <div style={{ padding: '15px' }}>
                                    <h3 style={{ margin: '0 0 5px 0', fontSize: '18px', color: '#333', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{item.name}</h3>
                                    <div style={{ display: 'flex', gap: '15px', fontSize: '13px', color: '#666', marginBottom: '10px' }}>
                                        <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}><Clock size={14}/> {item.cookingTime} min</span>
                                        <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}><Users size={14}/> {item.baseServings} serv</span>
                                    </div>
                                    <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '10px', borderTop: '1px solid #eee', paddingTop: '10px' }}>
                                        <button onClick={() => handleViewDetail(item._id)} style={{ color: '#555', background: 'none', border: 'none', cursor: 'pointer' }}><Eye size={20}/></button>
                                        <button onClick={() => handleOpenEdit(item._id)} style={{ color: '#30a5ff', background: 'none', border: 'none', cursor: 'pointer' }}><Edit size={18}/></button>
                                        <button onClick={() => handleDelete(item._id)} style={{ color: '#f9243f', background: 'none', border: 'none', cursor: 'pointer' }}><Trash2 size={18}/></button>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* --- PAGINATION CONTROLS (THANH PHÂN TRANG) --- */}
                    {recipes.length > 0 && (
                        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '20px', marginTop: '30px', paddingBottom: '20px' }}>
                            <button
                                onClick={handlePrevPage}
                                disabled={currentPage === 1}
                                style={{
                                    background: currentPage === 1 ? '#eee' : 'white',
                                    border: '1px solid #ddd', padding: '8px 15px', borderRadius: '5px',
                                    cursor: currentPage === 1 ? 'not-allowed' : 'pointer',
                                    display: 'flex', alignItems: 'center', gap: '5px', color: currentPage === 1 ? '#999' : '#333'
                                }}
                            >
                                <ChevronLeft size={18}/> Previous
                            </button>

                            <span style={{ fontWeight: 'bold', color: '#5f6468' }}>
                                Page {currentPage} of {totalPages}
                            </span>

                            <button
                                onClick={handleNextPage}
                                disabled={currentPage === totalPages}
                                style={{
                                    background: currentPage === totalPages ? '#eee' : 'white',
                                    border: '1px solid #ddd', padding: '8px 15px', borderRadius: '5px',
                                    cursor: currentPage === totalPages ? 'not-allowed' : 'pointer',
                                    display: 'flex', alignItems: 'center', gap: '5px', color: currentPage === totalPages ? '#999' : '#333'
                                }}
                            >
                                Next <ChevronRight size={18}/>
                            </button>
                        </div>
                    )}
                </>
            )}

            {/* --- MODAL VIEW DETAIL --- */}
            {showDetail && detailData && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', justifyContent: 'center', alignItems: 'start', zIndex: 1100, overflowY: 'auto', padding: '40px 0' }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '900px', position: 'relative', boxShadow: '0 10px 25px rgba(0,0,0,0.3)' }}>
                        <button onClick={() => { setShowDetail(false); setDetailData(null); }} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={26} /></button>
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '30px' }}>
                            <div>
                                <div style={{ width: '100%', height: '250px', borderRadius: '8px', overflow: 'hidden', marginBottom: '20px', border: '1px solid #eee' }}>
                                    {detailData.imageUrl ?
                                        <img src={detailData.imageUrl} alt={detailData.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                        : <div style={{display:'flex',justifyContent:'center',alignItems:'center',height:'100%',background:'#f9f9f9',color:'#ccc'}}><ChefHat size={60}/></div>
                                    }
                                </div>
                                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', textAlign: 'center' }}>
                                    <div style={{ background:'#f0f8ff', padding:'10px', borderRadius:'6px' }}>
                                        <Clock size={20} color="#30a5ff" style={{marginBottom:'5px'}}/>
                                        <div style={{fontWeight:'bold', color:'#333'}}>{detailData.cookingTime} min</div>
                                    </div>
                                    <div style={{ background:'#f0f8ff', padding:'10px', borderRadius:'6px' }}>
                                        <Users size={20} color="#30a5ff" style={{marginBottom:'5px'}}/>
                                        <div style={{fontWeight:'bold', color:'#333'}}>{detailData.baseServings}</div>
                                    </div>
                                </div>
                                <div style={{ marginTop: '20px', padding: '15px', background: '#fff8e1', borderRadius: '8px' }}>
                                    <h4 style={{ margin: '0 0 10px 0', color: '#d97706', display:'flex', alignItems:'center', gap:'5px' }}><Activity size={18}/> Nutrition Facts</h4>
                                    <div style={{ display:'flex', justifyContent:'space-between', fontSize:'14px', marginBottom:'5px' }}>
                                        <span>Calories:</span> <strong>{detailData.nutrition?.calories} kcal</strong>
                                    </div>
                                    <div style={{ display:'flex', justifyContent:'space-between', fontSize:'14px', marginBottom:'5px' }}>
                                        <span>Protein:</span> <strong>{detailData.nutrition?.protein} g</strong>
                                    </div>
                                    <div style={{ display:'flex', justifyContent:'space-between', fontSize:'14px', marginBottom:'5px' }}>
                                        <span>Carbs:</span> <strong>{detailData.nutrition?.carbohydrates} g</strong>
                                    </div>
                                    <div style={{ display:'flex', justifyContent:'space-between', fontSize:'14px' }}>
                                        <span>Fats:</span> <strong>{detailData.nutrition?.fat} g</strong>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <h1 style={{ marginTop: 0, color: '#333', fontSize: '28px' }}>{detailData.name}</h1>
                                <span style={{ background: detailData.status === 'published' ? '#28a745' : '#ffc107', color: 'white', padding: '4px 10px', borderRadius: '15px', fontSize: '12px', fontWeight: 'bold', textTransform: 'uppercase' }}>
                                    {detailData.status}
                                </span>
                                <p style={{ color: '#666', lineHeight: '1.6', marginTop: '15px' }}>{detailData.description}</p>
                                <h3 style={{ color: '#30a5ff', borderBottom: '2px solid #f0f0f0', paddingBottom: '10px', marginTop: '30px' }}>Ingredients</h3>
                                <ul style={{ listStyle: 'none', padding: 0 }}>
                                    {detailData.ingredients?.map((ing, idx) => (
                                        <li key={idx} style={{ padding: '10px 0', borderBottom: '1px solid #f9f9f9', display: 'flex', alignItems: 'center', gap: '15px' }}>
                                            <div style={{ width: '40px', height: '40px', borderRadius: '4px', overflow: 'hidden', background: '#eee' }}>
                                                {ing.ingredientId?.ImageUrl && <img src={ing.ingredientId.ImageUrl} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />}
                                            </div>
                                            <div style={{ flex: 1 }}>
                                                <div style={{ fontWeight: 'bold', color: '#333' }}>
                                                    {ing.ingredientId?.name || "Unknown Ingredient"}
                                                </div>
                                            </div>
                                            <div style={{ fontWeight: 'bold', color: '#30a5ff' }}>
                                                {ing.base_quantity} {ing.unit}
                                            </div>
                                        </li>
                                    ))}
                                </ul>
                                <h3 style={{ color: '#30a5ff', borderBottom: '2px solid #f0f0f0', paddingBottom: '10px', marginTop: '30px' }}>Instructions</h3>
                                <div>
                                    {detailData.steps?.map((step, idx) => (
                                        <div key={idx} style={{ display: 'flex', gap: '15px', marginBottom: '20px' }}>
                                            <div style={{ width: '30px', height: '30px', background: '#30a5ff', color: 'white', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', fontWeight: 'bold', flexShrink: 0 }}>
                                                {step.stepNumber}
                                            </div>
                                            <div style={{ color: '#444', lineHeight: '1.6', marginTop: '4px' }}>
                                                {step.instruction}
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* --- MODAL FORM CREATE/EDIT (Giữ nguyên form nhập liệu bên dưới) --- */}
            {showModal && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'start', zIndex: 1000, overflowY: 'auto', padding: '40px 0' }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '800px', position: 'relative', boxShadow: '0 5px 15px rgba(0,0,0,0.2)' }}>
                        <button onClick={() => setShowModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={24} /></button>
                        <h2 style={{ marginTop: 0, color: '#30a5ff', marginBottom: '20px', borderBottom: '1px solid #eee', paddingBottom: '10px' }}>
                            {isEditing ? 'Edit Recipe' : 'Create New Recipe'}
                        </h2>
                        <form onSubmit={handleSubmit}>
                            {/* FORM CONTENT GIỮ NGUYÊN NHƯ CŨ */}
                            <h4 style={{color: '#555', marginBottom: '10px'}}>1. Basic Information</h4>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '15px' }}>
                                <div>
                                    <label style={{display:'block', fontSize:'13px'}}>Recipe Name</label>
                                    <input type="text" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} style={{width:'100%', padding:'8px', border:'1px solid #ddd', borderRadius:'4px'}} required />
                                </div>
                                <div>
                                    <label style={{display:'block', fontSize:'13px'}}>Image URL</label>
                                    <input type="text" value={formData.imageUrl} onChange={e => setFormData({...formData, imageUrl: e.target.value})} style={{width:'100%', padding:'8px', border:'1px solid #ddd', borderRadius:'4px'}} placeholder="http://..." />
                                </div>
                            </div>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{display:'block', fontSize:'13px'}}>Description</label>
                                <textarea rows="3" value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} style={{width:'100%', padding:'8px', border:'1px solid #ddd', borderRadius:'4px'}} required />
                            </div>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '20px', marginBottom: '20px' }}>
                                <div>
                                    <label style={{display:'block', fontSize:'13px'}}>Cooking Time (mins)</label>
                                    <input type="number" value={formData.cookingTime} onChange={e => setFormData({...formData, cookingTime: e.target.value})} style={{width:'100%', padding:'8px', border:'1px solid #ddd', borderRadius:'4px'}} required />
                                </div>
                                <div>
                                    <label style={{display:'block', fontSize:'13px'}}>Servings</label>
                                    <input type="number" value={formData.baseServings} onChange={e => setFormData({...formData, baseServings: e.target.value})} style={{width:'100%', padding:'8px', border:'1px solid #ddd', borderRadius:'4px'}} required />
                                </div>
                                <div>
                                    <label style={{display:'block', fontSize:'13px'}}>Status</label>
                                    <select value={formData.status} onChange={e => setFormData({...formData, status: e.target.value})} style={{width:'100%', padding:'8px', border:'1px solid #ddd', borderRadius:'4px'}}>
                                        <option value="draft">Draft</option>
                                        <option value="published">Published</option>
                                    </select>
                                </div>
                            </div>

                            <h4 style={{color: '#555', marginBottom: '10px', display:'flex', justifyContent:'space-between'}}>
                                2. Ingredients List
                                <button type="button" onClick={addIngredientRow} style={{background:'#eef6ff', border:'1px solid #30a5ff', color:'#30a5ff', padding:'2px 10px', borderRadius:'4px', cursor:'pointer', fontSize:'12px'}}>+ Add Item</button>
                            </h4>
                            <div style={{ background:'#f9f9f9', padding:'15px', borderRadius:'5px', marginBottom:'20px' }}>
                                {formData.ingredients.map((ing, idx) => (
                                    <div key={idx} style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
                                        <select
                                            value={ing.ingredientId}
                                            onChange={e => handleIngredientChange(idx, 'ingredientId', e.target.value)}
                                            style={{ flex: 2, padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                            required
                                        >
                                            <option value="">Select Ingredient</option>
                                            {allIngredients.map(item => (
                                                <option key={item._id} value={item._id}>{item.name}</option>
                                            ))}
                                        </select>
                                        <input
                                            type="number" placeholder="Qty"
                                            value={ing.base_quantity} onChange={e => handleIngredientChange(idx, 'base_quantity', e.target.value)}
                                            style={{ width:'80px', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                            required
                                        />
                                        <input
                                            type="text" placeholder="Unit"
                                            value={ing.unit} onChange={e => handleIngredientChange(idx, 'unit', e.target.value)}
                                            style={{ width:'80px', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                            required
                                        />
                                        <button type="button" onClick={() => removeIngredientRow(idx)} style={{ border:'none', background:'none', color:'#f9243f', cursor:'pointer' }}><Trash2 size={18}/></button>
                                    </div>
                                ))}
                            </div>

                            <h4 style={{color: '#555', marginBottom: '10px', display:'flex', justifyContent:'space-between'}}>
                                3. Cooking Steps
                                <button type="button" onClick={addStepRow} style={{background:'#eef6ff', border:'1px solid #30a5ff', color:'#30a5ff', padding:'2px 10px', borderRadius:'4px', cursor:'pointer', fontSize:'12px'}}>+ Add Step</button>
                            </h4>
                            <div style={{ background:'#f9f9f9', padding:'15px', borderRadius:'5px', marginBottom:'20px' }}>
                                {formData.steps.map((step, idx) => (
                                    <div key={idx} style={{ display: 'flex', gap: '10px', marginBottom: '10px', alignItems:'start' }}>
                                        <span style={{fontWeight:'bold', marginTop:'8px', width:'20px'}}>{idx + 1}.</span>
                                        <textarea
                                            rows="2" placeholder="Instruction details..."
                                            value={step.instruction} onChange={e => handleStepChange(idx, e.target.value)}
                                            style={{ flex: 1, padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                            required
                                        />
                                        <button type="button" onClick={() => removeStepRow(idx)} style={{ border:'none', background:'none', color:'#f9243f', cursor:'pointer' }}><Trash2 size={18}/></button>
                                    </div>
                                ))}
                            </div>

                            <h4 style={{color: '#555', marginBottom: '10px'}}>4. Nutrition Facts (Total)</h4>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: '15px', marginBottom: '20px', background:'#fff8e1', padding:'15px', borderRadius:'5px' }}>
                                <div>
                                    <label style={{display:'block', fontSize:'12px'}}>Calories</label>
                                    <input type="number" value={formData.nutrition.calories} onChange={e => setFormData({...formData, nutrition: {...formData.nutrition, calories: e.target.value}})} style={{width:'100%', padding:'5px', border:'1px solid #ddd', borderRadius:'4px'}} />
                                </div>
                                <div>
                                    <label style={{display:'block', fontSize:'12px'}}>Protein (g)</label>
                                    <input type="number" value={formData.nutrition.protein} onChange={e => setFormData({...formData, nutrition: {...formData.nutrition, protein: e.target.value}})} style={{width:'100%', padding:'5px', border:'1px solid #ddd', borderRadius:'4px'}} />
                                </div>
                                <div>
                                    <label style={{display:'block', fontSize:'12px'}}>Carbs (g)</label>
                                    <input type="number" value={formData.nutrition.carbohydrates} onChange={e => setFormData({...formData, nutrition: {...formData.nutrition, carbohydrates: e.target.value}})} style={{width:'100%', padding:'5px', border:'1px solid #ddd', borderRadius:'4px'}} />
                                </div>
                                <div>
                                    <label style={{display:'block', fontSize:'12px'}}>Fats (g)</label>
                                    <input type="number" value={formData.nutrition.fat} onChange={e => setFormData({...formData, nutrition: {...formData.nutrition, fat: e.target.value}})} style={{width:'100%', padding:'5px', border:'1px solid #ddd', borderRadius:'4px'}} />
                                </div>
                            </div>

                            <button type="submit" style={{ width: '100%', padding: '15px', background: '#30a5ff', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', fontSize:'16px' }}>
                                {isEditing ? 'Update Recipe' : 'Create Recipe'}
                            </button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default RecipesPage;