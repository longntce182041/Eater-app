import React, { useEffect, useState } from 'react';
import axiosClient from '../../api/axiosClient';
import { Search, Stethoscope, Utensils, FileText, X, User as UserIcon, Activity, Plus, Trash2, Calendar, Mail, HeartPulse } from 'lucide-react';
import { toast } from 'react-toastify';

const MIN_TARGET_CALORIES = 800;
const MAX_TARGET_CALORIES = 10000;
const MAX_CALORIES_DIGITS = 4;

const ConsultationsPage = () => {
    // --- STATES ---
    const [patients, setPatients] = useState([]);
    const [recipes, setRecipes] = useState([]);
    const [dietTypes, setDietTypes] = useState([]);
    const [loading, setLoading] = useState(true);
    const [recipesLoading, setRecipesLoading] = useState(false);
    const [dietTypesLoading, setDietTypesLoading] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    // --- MODAL STATES ---
    const[showDiagnoseModal, setShowDiagnoseModal] = useState(false);
    const [showMealPlanModal, setShowMealPlanModal] = useState(false);
    const [showReportModal, setShowReportModal] = useState(false);
    const [showHealthDataModal, setShowHealthDataModal] = useState(false);

    // --- DATA STATES ---
    const [selectedPatient, setSelectedPatient] = useState(null);
    const[reportData, setReportData] = useState(null);
    const [healthData, setHealthData] = useState(null);
    const [healthDataLoading, setHealthDataLoading] = useState(false);

    // --- FORM STATES ---
    const [diagForm, setDiagForm] = useState({ diagnosis: '', recommendations: '', notes: '' });
    const [mealForm, setMealForm] = useState({
        date: '',
        days: 1,
        targetCalories: '',
        healthGoal: 'Maintain Weight',
        dietType: '',
        meals: [{ dayIndex: 0, mealType: 'breakfast', recipeId: '', servings: 1 }]
    });

    const validateTargetCalories = (value) => {
        if (value === '' || value === null || value === undefined) {
            return `Target calories must be between ${MIN_TARGET_CALORIES} and ${MAX_TARGET_CALORIES} kcal/day`;
        }

        const calories = Number(value);
        if (!Number.isInteger(calories)) {
            return 'Target calories must be a whole number';
        }

        if (calories < MIN_TARGET_CALORIES || calories > MAX_TARGET_CALORIES) {
            return `Target calories must be between ${MIN_TARGET_CALORIES} and ${MAX_TARGET_CALORIES} kcal/day`;
        }

        return null;
    };

    // 1. Lấy danh sách Bệnh nhân (Users có role = 'user')
    const fetchPatients = async () => {
        try {
            setLoading(true);
            // Dùng API lấy users, lọc chỉ lấy user thường
            const res = await axiosClient.get('/users', { 
                params: { role: 'user', proOnly: true, keyword: searchTerm, limit: 50 } 
            });
            if (res.data.success) {
                setPatients(res.data.data.users);
            }
        } catch (error) {
            toast.error("Failed to load patients list");
        } finally {
            setLoading(false);
        }
    };

    const fetchRecipes = async () => {
        try {
            setRecipesLoading(true);
            const res = await axiosClient.get('/recipes', { params: { limit: 100 } });
            if (res.data.success) {
                setRecipes(res.data.data.recipes || []);
            }
        } catch (error) {
            toast.error('Failed to load recipes list');
        } finally {
            setRecipesLoading(false);
        }
    };

    const fetchDietTypes = async () => {
        try {
            setDietTypesLoading(true);
            const res = await axiosClient.get('/health/diet-types');
            const dietTypesData = Array.isArray(res.data) ? res.data : [];
            setDietTypes(dietTypesData);
        } catch (error) {
            toast.error('Failed to load diet types');
            setDietTypes([]);
        } finally {
            setDietTypesLoading(false);
        }
    };

    useEffect(() => {
        const timer = setTimeout(() => {
            fetchPatients();
        }, 500);
        return () => clearTimeout(timer);
    }, [searchTerm]);

    // --- MỞ MODAL ---
    const openDiagnose = (patient) => {
        setSelectedPatient(patient);
        setDiagForm({ diagnosis: '', recommendations: '', notes: '' });
        setShowDiagnoseModal(true);
    };

    const openMealPlan = (patient) => {
        setSelectedPatient(patient);
        setMealForm({
            date: '',
            days: 1,
            targetCalories: '',
            healthGoal: 'Maintain Weight',
            dietType: '',
            meals: [{ dayIndex: 0, mealType: 'breakfast', recipeId: '', servings: 1 }]
        });
        setShowMealPlanModal(true);
        fetchRecipes();
        fetchDietTypes();
    };

    const openReport = async (patient) => {
        setSelectedPatient(patient);
        try {
            // Gọi API lấy Report tổng hợp
            const res = await axiosClient.get(`/consultations/reports/${patient._id}`);
            if (res.data.success) {
                setReportData(res.data.data);
                setShowReportModal(true);
            }
        } catch (error) {
            toast.error(error.response?.data?.message || "Failed to generate report");
        }
    };

    const openHealthData = async (patient) => {
        setSelectedPatient(patient);
        setHealthData(null);
        setShowHealthDataModal(true);

        try {
            setHealthDataLoading(true);
            const res = await axiosClient.get(`/consultations/users/${patient._id}/health-data`);
            if (res.data.success) {
                setHealthData(res.data.data);
            }
        } catch (error) {
            toast.error(error.response?.data?.message || 'Failed to load user health data');
            setShowHealthDataModal(false);
        } finally {
            setHealthDataLoading(false);
        }
    };

    const handleSendReportEmail = async () => {
        if (!selectedPatient?._id) return;

        try {
            const res = await axiosClient.get(`/consultations/reports/${selectedPatient._id}`, {
                params: { sendEmail: true }
            });

            if (res.data.success) {
                setReportData(res.data.data);
                toast.success('Report email sent successfully');
            }
        } catch (error) {
            toast.error(error.response?.data?.message || 'Failed to send report email');
        }
    };

    // --- XỬ LÝ SUBMIT ---
    const handleDiagnoseSubmit = async (e) => {
        e.preventDefault();
        try {
            const payload = { userId: selectedPatient._id, ...diagForm };
            const res = await axiosClient.post('/consultations/diagnose', payload);
            toast.success(res.data.message);
            setShowDiagnoseModal(false);
        } catch (error) {
            toast.error(error.response?.data?.message || "Diagnosis failed");
        }
    };

    const handleMealPlanSubmit = async (e) => {
        e.preventDefault();
        try {
            const caloriesError = validateTargetCalories(mealForm.targetCalories);
            if (caloriesError) {
                toast.error(caloriesError);
                return;
            }

            const invalidMeal = mealForm.meals.find((m) => !m.recipeId || !m.mealType);
            if (invalidMeal) {
                toast.error('Please select recipe and meal type for all rows');
                return;
            }

            const payload = { 
                userId: selectedPatient._id, 
                date: mealForm.date,
                days: Number(mealForm.days),
                targetCalories: Number(mealForm.targetCalories),
                healthGoal: mealForm.healthGoal,
                dietTypes: mealForm.dietType ? [mealForm.dietType] : [],
                meals: mealForm.meals.map((meal) => ({
                    dayIndex: Number(meal.dayIndex),
                    mealType: meal.mealType,
                    recipeId: meal.recipeId,
                    servings: Number(meal.servings) || 1
                }))
            };
            const res = await axiosClient.post('/consultations/meal-plans', payload);
            toast.success(res.data.message);
            setShowMealPlanModal(false);
        } catch (error) {
            toast.error(error.response?.data?.message || "Failed to assign meal plan");
        }
    };

    const addMealRow = () => {
        setMealForm((prev) => ({
            ...prev,
            meals: [...prev.meals, { dayIndex: 0, mealType: 'breakfast', recipeId: '', servings: 1 }]
        }));
    };

    const removeMealRow = (index) => {
        setMealForm((prev) => {
            if (prev.meals.length === 1) {
                return prev;
            }
            return {
                ...prev,
                meals: prev.meals.filter((_, i) => i !== index)
            };
        });
    };

    const updateMealRow = (index, field, value) => {
        setMealForm((prev) => ({
            ...prev,
            meals: prev.meals.map((meal, i) => i === index ? { ...meal, [field]: value } : meal)
        }));
    };

    return (
        <div>
            <h2 style={{ color: '#30a5ff', marginBottom: '20px' }}>Patient Consultations</h2>

            {/* TOOLBAR */}
            <div style={{ background: 'white', padding: '15px', borderRadius: '5px', marginBottom: '20px', display: 'flex', gap: '15px', alignItems: 'center', boxShadow: '0 1px 2px rgba(0,0,0,0.1)' }}>
                <div style={{ position: 'relative', flex: 1 }}>
                    <Search size={18} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: '#999' }} />
                    <input 
                        type="text" placeholder="Search patient by email..." 
                        value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)}
                        style={{ width: '100%', padding: '10px 10px 10px 35px', borderRadius: '4px', border: '1px solid #ddd' }}
                    />
                </div>
            </div>

            {/* PATIENTS TABLE */}
            <div style={{ background: 'white', padding: '20px', borderRadius: '5px', boxShadow: '0 1px 2px rgba(0,0,0,0.1)' }}>
                {loading ? <p style={{textAlign:'center'}}>Loading patients...</p> : (
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                            <tr style={{ borderBottom: '2px solid #eee', textAlign: 'left', color: '#5f6468' }}>
                                <th style={{ padding: '10px' }}>Patient Email</th>
                                <th style={{ padding: '10px' }}>Status</th>
                                <th style={{ padding: '10px' }}>Joined Date</th>
                                <th style={{ padding: '10px', textAlign: 'center' }}>Medical Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {patients.length > 0 ? patients.map(p => (
                                <tr key={p._id} style={{ borderBottom: '1px solid #eee', color: '#666' }}>
                                    <td style={{ padding: '12px', fontWeight: 'bold', color: '#333' }}>
                                        <div style={{display:'flex', alignItems:'center', gap:'8px'}}>
                                            <UserIcon size={18} color="#30a5ff"/> {p.email}
                                        </div>
                                    </td>
                                    <td style={{ padding: '12px' }}>
                                        <span style={{ color: p.isActive ? '#28a745' : '#dc3545', fontWeight: 'bold', fontSize: '12px' }}>
                                            {p.isActive ? 'Active' : 'Inactive'}
                                        </span>
                                    </td>
                                    <td style={{ padding: '12px' }}>{new Date(p.createdAt).toLocaleDateString()}</td>
                                    <td style={{ padding: '12px', display: 'flex', gap: '10px', justifyContent: 'center' }}>
                                        <button onClick={() => openDiagnose(p)} style={{ background:'#fff3cd', color:'#ffb53e', border:'1px solid #ffb53e', padding:'6px 12px', borderRadius:'4px', cursor:'pointer', display:'flex', gap:'5px', alignItems:'center', fontSize:'13px', fontWeight:'bold' }} title="Diagnose & Recommend">
                                            <Stethoscope size={16} /> Diagnose
                                        </button>
                                        <button onClick={() => openMealPlan(p)} style={{ background:'#e8f5e9', color:'#28a745', border:'1px solid #28a745', padding:'6px 12px', borderRadius:'4px', cursor:'pointer', display:'flex', gap:'5px', alignItems:'center', fontSize:'13px', fontWeight:'bold' }} title="Assign Diet Plan">
                                            <Utensils size={16} /> Diet Plan
                                        </button>
                                        <button onClick={() => openReport(p)} style={{ background:'#eef6ff', color:'#30a5ff', border:'1px solid #30a5ff', padding:'6px 12px', borderRadius:'4px', cursor:'pointer', display:'flex', gap:'5px', alignItems:'center', fontSize:'13px', fontWeight:'bold' }} title="View Nutrition Report">
                                            <FileText size={16} /> Report
                                        </button>
                                        <button onClick={() => openHealthData(p)} style={{ background:'#fff1f2', color:'#e11d48', border:'1px solid #e11d48', padding:'6px 12px', borderRadius:'4px', cursor:'pointer', display:'flex', gap:'5px', alignItems:'center', fontSize:'13px', fontWeight:'bold' }} title="View User Health Data">
                                            <HeartPulse size={16} /> Health Data
                                        </button>
                                    </td>
                                </tr>
                            )) : <tr><td colSpan="4" style={{textAlign:'center', padding:'20px'}}>No patients found.</td></tr>}
                        </tbody>
                    </table>
                )}
            </div>

            // Task: Diagnose Nutrition Condition + Send Recommendations
            {/* --- 1. MODAL DIAGNOSE --- */}
            {showDiagnoseModal && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '500px', position: 'relative' }}>
                        <button onClick={() => setShowDiagnoseModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={20} /></button>
                        <h3 style={{ marginTop: 0, color: '#ffb53e', display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <Stethoscope size={24}/> Medical Diagnosis
                        </h3>
                        <p style={{fontSize: '13px', color: '#666', marginBottom: '20px'}}>Patient: <strong>{selectedPatient?.email}</strong></p>
                        
                        <form onSubmit={handleDiagnoseSubmit}>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Diagnosis Result</label>
                                <textarea rows="3" value={diagForm.diagnosis} onChange={e => setDiagForm({...diagForm, diagnosis: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} placeholder="E.g., Vitamin D deficiency..." required />
                            </div>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Nutritional Recommendations</label>
                                <textarea rows="4" value={diagForm.recommendations} onChange={e => setDiagForm({...diagForm, recommendations: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} placeholder="E.g., Increase salmon intake, eat more greens..." required />
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Private Notes (Optional)</label>
                                <input type="text" value={diagForm.notes} onChange={e => setDiagForm({...diagForm, notes: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} />
                            </div>
                            <div style={{ display: 'flex', gap: '10px' }}>
                                <button
                                    type="button"
                                    onClick={() => setShowDiagnoseModal(false)}
                                    style={{ flex: 1, padding: '12px', background: '#f3f4f6', color: '#374151', border: '1px solid #d1d5db', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}
                                >
                                    Cancel
                                </button>
                                <button type="submit" style={{ flex: 1, padding: '12px', background: '#ffb53e', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>Send Diagnosis</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            // Task: Create Personalized Diet Plan + Assign Meal Plan To User
            {/* --- 2. MODAL MEAL PLAN --- */}
            {showMealPlanModal && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
                    <div style={{ background: 'white', padding: '30px', borderRadius: '8px', width: '780px', maxHeight: '90vh', overflowY: 'auto', position: 'relative' }}>
                        <button onClick={() => setShowMealPlanModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={20} /></button>
                        <h3 style={{ marginTop: 0, color: '#28a745', display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <Utensils size={24}/> Assign Diet Plan
                        </h3>
                        <p style={{fontSize: '13px', color: '#666', marginBottom: '20px'}}>Patient: <strong>{selectedPatient?.email}</strong></p>

                        <form onSubmit={handleMealPlanSubmit}>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Start Date</label>
                                <input type="date" value={mealForm.date} onChange={e => setMealForm({...mealForm, date: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }} required />
                            </div>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Plan Duration</label>
                                <select value={mealForm.days} onChange={e => setMealForm({...mealForm, days: Number(e.target.value), meals: mealForm.meals.map(m => ({...m, dayIndex: Math.min(Number(m.dayIndex), Number(e.target.value) - 1)}))})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}>
                                    <option value={1}>1 Day Plan</option>
                                    <option value={7}>7 Day Plan</option>
                                </select>
                            </div>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Target Calories (kcal/day)</label>
                                <input
                                    type="text"
                                    inputMode="numeric"
                                    value={mealForm.targetCalories}
                                    onChange={(e) => {
                                        const numericOnly = e.target.value.replace(/\D/g, '').slice(0, MAX_CALORIES_DIGITS);
                                        setMealForm({ ...mealForm, targetCalories: numericOnly });
                                    }}
                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                    placeholder={`E.g., 2000 (min ${MIN_TARGET_CALORIES}, max ${MAX_TARGET_CALORIES})`}
                                    required
                                />
                                <p style={{ margin: '6px 0 0 0', fontSize: '12px', color: '#666' }}>
                                    Allowed range: {MIN_TARGET_CALORIES} - {MAX_TARGET_CALORIES} kcal/day
                                </p>
                            </div>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Health Goal</label>
                                <select value={mealForm.healthGoal} onChange={e => setMealForm({...mealForm, healthGoal: e.target.value})} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}>
                                    <option value="Maintain Weight">Maintain Weight</option>
                                    <option value="Weight Loss">Weight Loss</option>
                                    <option value="Muscle Gain">Muscle Gain</option>
                                </select>
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', fontSize: '13px', marginBottom: '5px', fontWeight: 'bold' }}>Diet Types</label>
                                <select
                                    value={mealForm.dietType}
                                    onChange={e => setMealForm({ ...mealForm, dietType: e.target.value })}
                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                                >
                                    <option value="">Select diet type (optional)</option>
                                    {dietTypes.map((dietType) => (
                                        <option key={dietType._id} value={dietType.name}>{dietType.name}</option>
                                    ))}
                                </select>
                                {dietTypesLoading && <p style={{ fontSize: '12px', color: '#777', marginTop: '6px' }}>Loading diet types...</p>}
                                {!dietTypesLoading && dietTypes.length === 0 && <p style={{ fontSize: '12px', color: '#dc3545', marginTop: '6px' }}>No diet types found in database.</p>}
                            </div>

                            <div style={{ marginBottom: '20px' }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                                    <label style={{ display: 'block', fontSize: '13px', fontWeight: 'bold' }}>Meal Items</label>
                                    <button type="button" onClick={addMealRow} style={{ background: '#eef6ff', color: '#30a5ff', border: '1px solid #30a5ff', padding: '6px 10px', borderRadius: '4px', cursor: 'pointer', display: 'flex', gap: '6px', alignItems: 'center', fontWeight: 'bold' }}>
                                        <Plus size={15} /> Add Meal
                                    </button>
                                </div>
                                <div style={{ border: '1px solid #eee', borderRadius: '6px', overflow: 'hidden' }}>
                                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 2fr 1fr 70px', background: '#f8f9fa', padding: '8px', fontSize: '12px', fontWeight: 'bold', color: '#555' }}>
                                        <div>Day</div>
                                        <div>Meal Type</div>
                                        <div>Recipe</div>
                                        <div>Servings</div>
                                        <div></div>
                                    </div>
                                    {mealForm.meals.map((meal, idx) => (
                                        <div key={`meal-row-${idx}`} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 2fr 1fr 70px', padding: '8px', borderTop: '1px solid #f0f0f0', gap: '8px', alignItems: 'center' }}>
                                            <select value={meal.dayIndex} onChange={(e) => updateMealRow(idx, 'dayIndex', Number(e.target.value))} style={{ padding: '7px', border: '1px solid #ddd', borderRadius: '4px' }}>
                                                {Array.from({ length: Number(mealForm.days) }, (_, day) => (
                                                    <option key={`day-opt-${day}`} value={day}>Day {day + 1}</option>
                                                ))}
                                            </select>
                                            <select value={meal.mealType} onChange={(e) => updateMealRow(idx, 'mealType', e.target.value)} style={{ padding: '7px', border: '1px solid #ddd', borderRadius: '4px' }}>
                                                <option value="breakfast">Breakfast</option>
                                                <option value="lunch">Lunch</option>
                                                <option value="dinner">Dinner</option>
                                                <option value="snack">Snack</option>
                                            </select>
                                            <select value={meal.recipeId} onChange={(e) => updateMealRow(idx, 'recipeId', e.target.value)} style={{ padding: '7px', border: '1px solid #ddd', borderRadius: '4px' }} required>
                                                <option value="">Select recipe</option>
                                                {recipes.map((recipe) => (
                                                    <option key={recipe._id} value={recipe._id}>{recipe.name}</option>
                                                ))}
                                            </select>
                                            <input type="number" min="1" value={meal.servings} onChange={(e) => updateMealRow(idx, 'servings', e.target.value)} style={{ padding: '7px', border: '1px solid #ddd', borderRadius: '4px' }} />
                                            <button type="button" onClick={() => removeMealRow(idx)} style={{ border: '1px solid #dc3545', color: '#dc3545', background: 'white', borderRadius: '4px', cursor: 'pointer', height: '34px' }} title="Remove meal row">
                                                <Trash2 size={15} style={{ marginTop: '2px' }} />
                                            </button>
                                        </div>
                                    ))}
                                </div>
                                {recipesLoading && <p style={{ fontSize: '12px', color: '#777', marginTop: '8px' }}>Loading recipes...</p>}
                                {!recipesLoading && recipes.length === 0 && <p style={{ fontSize: '12px', color: '#dc3545', marginTop: '8px' }}>No recipes available to assign.</p>}
                            </div>
                            <div style={{ display: 'flex', gap: '10px' }}>
                                <button
                                    type="button"
                                    onClick={() => setShowMealPlanModal(false)}
                                    style={{ flex: 1, padding: '12px', background: '#f3f4f6', color: '#374151', border: '1px solid #d1d5db', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}
                                >
                                    Cancel
                                </button>
                                <button type="submit" style={{ flex: 1, padding: '12px', background: '#28a745', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>Assign Plan</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}


            // Task: Generate Comprehensive Nutrition Report + Send Report Email
            {/* --- 3. MODAL REPORT --- */}
            {showReportModal && reportData && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1100, overflowY: 'auto', padding: '40px 0' }}>
                    <div style={{ background: 'white', padding: '40px', borderRadius: '8px', width: '700px', position: 'relative', boxShadow: '0 10px 25px rgba(0,0,0,0.3)' }}>
                        <button onClick={() => setShowReportModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={26} /></button>
                        
                        <div style={{ textAlign: 'center', borderBottom: '2px solid #eee', paddingBottom: '20px', marginBottom: '20px' }}>
                            <h2 style={{ margin: 0, color: '#333', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px' }}><Activity size={28} color="#30a5ff"/> NUTRITION REPORT</h2>
                            <p style={{ margin: '5px 0 0 0', color: '#666' }}>Generated on: {new Date(reportData.generatedAt).toLocaleString()}</p>
                        </div>

                        {/* Patient Info */}
                        <h3 style={{ color: '#30a5ff', borderBottom: '1px solid #eee', paddingBottom: '5px' }}>1. Patient Information</h3>
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', background: '#f9f9f9', padding: '15px', borderRadius: '5px', marginBottom: '20px' }}>
                            <div><strong>Email:</strong> {reportData.patientInfo.email}</div>
                            <div><strong>Goal:</strong> {reportData.patientInfo.healthGoals || "N/A"}</div>
                            <div><strong>Age:</strong> {reportData.patientInfo.age || "N/A"}</div>
                            <div><strong>Gender:</strong> {reportData.patientInfo.gender || "N/A"}</div>
                            <div><strong>Height:</strong> {reportData.patientInfo.height ? `${reportData.patientInfo.height} cm` : "N/A"}</div>
                            <div><strong>Weight:</strong> {reportData.patientInfo.weight ? `${reportData.patientInfo.weight} kg` : "N/A"}</div>
                        </div>

                        {/* Consultations */}
                        <h3 style={{ color: '#30a5ff', borderBottom: '1px solid #eee', paddingBottom: '5px' }}>2. Recent Medical Diagnosis</h3>
                        {reportData.consultationHistory && reportData.consultationHistory.length > 0 ? (
                            reportData.consultationHistory.map((cons, idx) => (
                                <div key={idx} style={{ background: '#fff3cd', padding: '15px', borderRadius: '5px', marginBottom: '10px', borderLeft: '4px solid #ffb53e' }}>
                                    <div style={{ fontSize: '12px', color: '#999', marginBottom: '5px' }}>{new Date(cons.createdAt).toLocaleString()}</div>
                                    <p style={{ margin: '0 0 5px 0' }}><strong>Diagnosis:</strong> {cons.diagnosis}</p>
                                    <p style={{ margin: 0 }}><strong>Recommendations:</strong> {cons.recommendations}</p>
                                </div>
                            ))
                        ) : <p style={{color: '#999', fontStyle: 'italic'}}>No diagnosis history found.</p>}

                        {/* Meal Plans */}
                        <h3 style={{ color: '#30a5ff', borderBottom: '1px solid #eee', paddingBottom: '5px', marginTop: '20px' }}>3. Assigned Diet Plans</h3>
                        {reportData.recentMealPlans && reportData.recentMealPlans.length > 0 ? (
                            <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '10px' }}>
                                <thead>
                                    <tr style={{ background: '#f0f0f0', textAlign: 'left' }}>
                                        <th style={{ padding: '10px' }}>Plan Date</th>
                                        <th style={{ padding: '10px' }}>Target Cal</th>
                                        <th style={{ padding: '10px' }}>Goal</th>
                                        <th style={{ padding: '10px' }}>Creator</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {reportData.recentMealPlans.map((plan, idx) => (
                                        <tr key={idx} style={{ borderBottom: '1px solid #eee' }}>
                                            <td style={{ padding: '10px', display: 'flex', gap: '5px', alignItems: 'center' }}><Calendar size={16}/> {new Date(plan.date).toLocaleDateString()}</td>
                                            <td style={{ padding: '10px', fontWeight: 'bold', color: '#28a745' }}>{plan.targetCalories} kcal</td>
                                            <td style={{ padding: '10px' }}>{plan.healthGoal}</td>
                                            <td style={{ padding: '10px' }}>
                                                <span style={{ background: plan.aiGenerated ? '#1ebfae' : '#ffb53e', color: 'white', padding: '3px 6px', borderRadius: '4px', fontSize: '11px', fontWeight: 'bold' }}>
                                                    {plan.aiGenerated ? 'AI SYSTEM' : 'DOCTOR'}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        ) : <p style={{color: '#999', fontStyle: 'italic'}}>No diet plans found.</p>}

                        <div style={{ marginTop: '30px', textAlign: 'center', display: 'flex', gap: '10px', justifyContent: 'center' }}>
                            <button onClick={() => setShowReportModal(false)} style={{ background: '#f3f4f6', color: '#374151', border: '1px solid #d1d5db', padding: '10px 20px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
                                Cancel
                            </button>
                            <button onClick={handleSendReportEmail} style={{ background: '#28a745', color: 'white', border: 'none', padding: '10px 20px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', display: 'flex', alignItems: 'center', gap: '6px' }}>
                                <Mail size={16} /> Send Report Email
                            </button>
                            <button onClick={() => window.print()} style={{ background: '#30a5ff', color: 'white', border: 'none', padding: '10px 20px', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}>
                                Print Report
                            </button>
                        </div>
                    </div>
                </div>
            )}

            // Task: View User Health Data
            {/* --- 4. MODAL HEALTH DATA --- */}
            {showHealthDataModal && (
                <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1100, overflowY: 'auto', padding: '40px 0' }}>
                    <div style={{ background: 'white', padding: '28px', borderRadius: '8px', width: '760px', maxHeight: '90vh', overflowY: 'auto', position: 'relative', boxShadow: '0 10px 25px rgba(0,0,0,0.25)' }}>
                        <button onClick={() => setShowHealthDataModal(false)} style={{ position: 'absolute', top: '15px', right: '15px', border: 'none', background:'none', cursor:'pointer' }}><X size={24} /></button>

                        <div style={{ textAlign: 'center', borderBottom: '2px solid #eee', paddingBottom: '16px', marginBottom: '18px' }}>
                            <h2 style={{ margin: 0, color: '#e11d48', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px' }}>
                                <HeartPulse size={28} color="#e11d48" /> USER HEALTH DATA
                            </h2>
                            <p style={{ margin: '6px 0 0 0', color: '#666', fontSize: '13px' }}>Patient: {selectedPatient?.email}</p>
                        </div>

                        {healthDataLoading ? (
                            <p style={{ textAlign: 'center', color: '#777' }}>Loading health data...</p>
                        ) : !healthData ? (
                            <p style={{ textAlign: 'center', color: '#999' }}>No health data available for this patient.</p>
                        ) : (
                            <>
                                <h3 style={{ color: '#e11d48', borderBottom: '1px solid #eee', paddingBottom: '6px' }}>1. Basic Profile</h3>
                                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', background: '#f9fafb', padding: '14px', borderRadius: '6px', marginBottom: '18px' }}>
                                    <div><strong>Email:</strong> {healthData.patientInfo?.email || 'N/A'}</div>
                                    <div><strong>Status:</strong> {healthData.patientInfo?.isActive ? 'Active' : 'Inactive'}</div>
                                    <div><strong>Age:</strong> {healthData.profile?.age || 'N/A'}</div>
                                    <div><strong>Gender:</strong> {healthData.profile?.gender || 'N/A'}</div>
                                    <div><strong>Height:</strong> {healthData.profile?.height ? `${healthData.profile.height} cm` : 'N/A'}</div>
                                    <div><strong>Weight:</strong> {healthData.profile?.weight ? `${healthData.profile.weight} kg` : 'N/A'}</div>
                                    <div><strong>Goal Weight:</strong> {healthData.profile?.goal_weight ? `${healthData.profile.goal_weight} kg` : 'N/A'}</div>
                                    <div><strong>Health Goal:</strong> {healthData.profile?.healthGoals || 'N/A'}</div>
                                </div>

                                <h3 style={{ color: '#e11d48', borderBottom: '1px solid #eee', paddingBottom: '6px' }}>2. Dietary References</h3>
                                <div style={{ background: '#fff7ed', padding: '14px', borderRadius: '6px', marginBottom: '18px', borderLeft: '4px solid #fb923c' }}>
                                    <p style={{ margin: '0 0 8px 0' }}><strong>Diet Type:</strong> {healthData.dietaryReferences?.diet_typeId?.name || 'N/A'}</p>
                                    <p style={{ margin: '0 0 8px 0' }}><strong>Activity Level:</strong> {healthData.dietaryReferences?.activityLevel || 'N/A'}</p>
                                    <p style={{ margin: '0 0 8px 0' }}><strong>Cooking Skill:</strong> {healthData.dietaryReferences?.cookingSkillLevel || 'N/A'}</p>
                                    <p style={{ margin: '0 0 8px 0' }}><strong>Daily Target:</strong> {healthData.dietaryReferences?.daily_calorie_target ? `${healthData.dietaryReferences.daily_calorie_target} kcal` : 'N/A'}</p>
                                    <p style={{ margin: '0 0 8px 0' }}><strong>Allergies:</strong> {healthData.dietaryReferences?.allergies?.length ? healthData.dietaryReferences.allergies.join(', ') : 'None'}</p>
                                    <p style={{ margin: 0 }}><strong>Dislikes:</strong> {healthData.dietaryReferences?.dislikesIngredients?.length ? healthData.dietaryReferences.dislikesIngredients.join(', ') : 'None'}</p>
                                </div>

                                <h3 style={{ color: '#e11d48', borderBottom: '1px solid #eee', paddingBottom: '6px' }}>3. Latest Health Metrics</h3>
                                {healthData.latestHealthMetrics ? (
                                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '10px', marginBottom: '18px' }}>
                                        <div style={{ background: '#f0f9ff', border: '1px solid #bae6fd', borderRadius: '6px', padding: '10px' }}>
                                            <div style={{ color: '#0369a1', fontSize: '12px' }}>BMI</div>
                                            <div style={{ fontWeight: 'bold', fontSize: '20px' }}>{Number(healthData.latestHealthMetrics.bmi || 0).toFixed(1)}</div>
                                        </div>
                                        <div style={{ background: '#ecfdf5', border: '1px solid #a7f3d0', borderRadius: '6px', padding: '10px' }}>
                                            <div style={{ color: '#047857', fontSize: '12px' }}>BMR</div>
                                            <div style={{ fontWeight: 'bold', fontSize: '20px' }}>{Math.round(healthData.latestHealthMetrics.bmr || 0)}</div>
                                        </div>
                                        <div style={{ background: '#fffbeb', border: '1px solid #fde68a', borderRadius: '6px', padding: '10px' }}>
                                            <div style={{ color: '#b45309', fontSize: '12px' }}>TDEE</div>
                                            <div style={{ fontWeight: 'bold', fontSize: '20px' }}>{Math.round(healthData.latestHealthMetrics.tdee || 0)}</div>
                                        </div>
                                        <div style={{ background: '#fdf2f8', border: '1px solid #fbcfe8', borderRadius: '6px', padding: '10px' }}>
                                            <div style={{ color: '#be185d', fontSize: '12px' }}>Category</div>
                                            <div style={{ fontWeight: 'bold', fontSize: '16px' }}>{healthData.latestHealthMetrics.body_category || 'N/A'}</div>
                                        </div>
                                    </div>
                                ) : (
                                    <p style={{ color: '#999', fontStyle: 'italic' }}>No health metrics found.</p>
                                )}

                                <h3 style={{ color: '#e11d48', borderBottom: '1px solid #eee', paddingBottom: '6px' }}>4. Recent Metrics History</h3>
                                {healthData.recentHealthMetrics && healthData.recentHealthMetrics.length > 0 ? (
                                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                                        <thead>
                                            <tr style={{ background: '#f8fafc', textAlign: 'left' }}>
                                                <th style={{ padding: '8px' }}>Calculated At</th>
                                                <th style={{ padding: '8px' }}>BMI</th>
                                                <th style={{ padding: '8px' }}>BMR</th>
                                                <th style={{ padding: '8px' }}>TDEE</th>
                                                <th style={{ padding: '8px' }}>Source</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {healthData.recentHealthMetrics.map((metric) => (
                                                <tr key={metric._id} style={{ borderTop: '1px solid #eee' }}>
                                                    <td style={{ padding: '8px' }}>{new Date(metric.calculatedAt).toLocaleString()}</td>
                                                    <td style={{ padding: '8px' }}>{Number(metric.bmi || 0).toFixed(1)}</td>
                                                    <td style={{ padding: '8px' }}>{Math.round(metric.bmr || 0)}</td>
                                                    <td style={{ padding: '8px' }}>{Math.round(metric.tdee || 0)}</td>
                                                    <td style={{ padding: '8px' }}>{metric.source || 'N/A'}</td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                ) : (
                                    <p style={{ color: '#999', fontStyle: 'italic' }}>No metrics history found.</p>
                                )}

                                <h3 style={{ color: '#e11d48', borderBottom: '1px solid #eee', paddingBottom: '6px', marginTop: '18px' }}>5. Latest Clinical Snapshot</h3>
                                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', background: '#f8fafc', padding: '14px', borderRadius: '6px' }}>
                                    <div>
                                        <strong>Latest Consultation:</strong>
                                        <div style={{ color: '#555', marginTop: '4px' }}>
                                            {healthData.latestConsultation ? new Date(healthData.latestConsultation.createdAt).toLocaleString() : 'N/A'}
                                        </div>
                                    </div>
                                    <div>
                                        <strong>Latest Meal Plan:</strong>
                                        <div style={{ color: '#555', marginTop: '4px' }}>
                                            {healthData.latestMealPlan ? new Date(healthData.latestMealPlan.date).toLocaleDateString() : 'N/A'}
                                        </div>
                                    </div>
                                </div>
                            </>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
};

export default ConsultationsPage;