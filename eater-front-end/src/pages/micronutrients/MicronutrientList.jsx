import React, { useCallback, useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Search, ChevronLeft, ChevronRight } from 'lucide-react';
import { toast } from 'react-toastify';
import micronutrientService from '../../services/micronutrientService';
import MicronutrientForm from './MicronutrientForm';
import './MicronutrientList.css';

const MicronutrientList = () => {
    const [micronutrients, setMicronutrients] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [searchKeyword, setSearchKeyword] = useState('');
    const [unitFilter, setUnitFilter] = useState('');
    const [createdFrom, setCreatedFrom] = useState('');
    const [createdTo, setCreatedTo] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [pageSize] = useState(10);
    const [totalPages, setTotalPages] = useState(1);
    const [totalCount, setTotalCount] = useState(0);

    // Form state
    const [showForm, setShowForm] = useState(false);
    const [editingId, setEditingId] = useState(null);
    const [formData, setFormData] = useState({ name: '', unit: '', description: '' });

    // Fetch micronutrients
    const fetchMicronutrients = useCallback(async (page = 1, keyword = '') => {
        setLoading(true);
        setError('');
        try {
            const params = {
                keyword,
                page,
                limit: pageSize,
            };
            if (unitFilter) params.unit = unitFilter;
            if (createdFrom) params.createdFrom = createdFrom;
            if (createdTo) params.createdTo = createdTo;

            const result = await micronutrientService.getAll(params);
            setMicronutrients(result.data.micronutrients);
            setTotalPages(result.data.pagination.totalPages);
            setTotalCount(result.data.pagination.total);
            setCurrentPage(page);
        } catch (err) {
            setError(err.message || 'Failed to fetch micronutrients');
        } finally {
            setLoading(false);
        }
    }, [pageSize, unitFilter, createdFrom, createdTo]);

    // Initial load
    useEffect(() => {
        fetchMicronutrients(1, '');
    }, [fetchMicronutrients]);

    // Search handler
    const handleSearch = (e) => {
        e.preventDefault();
        setCurrentPage(1);
        fetchMicronutrients(1, searchKeyword);
    };

    // Reset filters
    const resetFilters = () => {
        setUnitFilter('');
        setCreatedFrom('');
        setCreatedTo('');
        setSearchKeyword('');
        fetchMicronutrients(1, '');
    };

    // derive available units for filter from current list
    const availableUnits = Array.from(new Set(micronutrients.map(m => m.unit).filter(Boolean)));

    // Open form for create/edit
    const openForm = (micronutrient = null) => {
        if (micronutrient) {
            setEditingId(micronutrient._id);
            setFormData({
                name: micronutrient.name,
                unit: micronutrient.unit,
                description: micronutrient.description || '',
            });
        } else {
            setEditingId(null);
            setFormData({ name: '', unit: '', description: '' });
        }
        setShowForm(true);
    };

    // Close form
    const closeForm = () => {
        setShowForm(false);
        setEditingId(null);
        setFormData({ name: '', unit: '', description: '' });
    };

    // Handle form submit
    const handleFormSubmit = async (data) => {
        try {
            if (editingId) {
                await micronutrientService.update(editingId, data);
                toast.success('Micronutrient updated successfully');
            } else {
                await micronutrientService.create(data);
                toast.success('Micronutrient created successfully');
            }
            closeForm();
            fetchMicronutrients(currentPage, searchKeyword);
        } catch (err) {
            const msg = err?.message || (err?.errors ? JSON.stringify(err.errors) : 'Failed to save');
            toast.error('Error: ' + msg);
        }
    };

    // Delete handler
    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this micronutrient?')) {
            try {
                await micronutrientService.delete(id);
                toast.success('Micronutrient deleted successfully');
                fetchMicronutrients(currentPage, searchKeyword);
            } catch (err) {
                const msg = err?.message || 'Failed to delete';
                toast.error('Error: ' + msg);
            }
        }
    };

    // Pagination handlers
    const goToPage = (page) => {
        if (page > 0 && page <= totalPages) {
            fetchMicronutrients(page, searchKeyword);
        }
    };

    return (
        <div className="micronutrient-container">
            <div className="micronutrient-header">
                <h1>Micronutrient Management</h1>
                <button
                    className="btn-primary"
                    onClick={() => openForm()}
                >
                    <Plus size={18} /> Add New Micronutrient
                </button>
            </div>

            {error && <div className="alert-error">{error}</div>}

            {/* Search Section */}
            <div className="search-section">
                <form onSubmit={handleSearch} className="search-form">
                    <input
                        type="text"
                        placeholder="Search by name..."
                        value={searchKeyword}
                        onChange={(e) => setSearchKeyword(e.target.value)}
                        className="search-input"
                    />
                    <select value={unitFilter} onChange={e => setUnitFilter(e.target.value)} className="search-input" style={{ maxWidth: 220 }}>
                        <option value="">All units</option>
                        {availableUnits.map(u => (
                            <option key={u} value={u}>{u}</option>
                        ))}
                    </select>
                    <input type="date" value={createdFrom} onChange={e => setCreatedFrom(e.target.value)} className="search-input" />
                    <input type="date" value={createdTo} onChange={e => setCreatedTo(e.target.value)} className="search-input" />
                    <button type="submit" className="btn-search">
                        <Search size={18} /> Search
                    </button>
                    <button type="button" className="btn-search" onClick={resetFilters} style={{ backgroundColor: '#6b7280' }}>
                        Reset
                    </button>
                </form>
            </div>

            {/* Table Section */}
            {loading ? (
                <div className="loading">Loading...</div>
            ) : (
                <>
                    <div className="table-responsive">
                        <table className="micronutrient-table">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Unit</th>
                                    <th>Description</th>
                                    <th>Created Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {micronutrients.length > 0 ? (
                                    micronutrients.map((micro) => (
                                        <tr key={micro._id}>
                                            <td>{micro.name}</td>
                                            <td>{micro.unit}</td>
                                            <td>{micro.description || '-'}</td>
                                            <td>{new Date(micro.createdAt).toLocaleDateString('vi-VN')}</td>
                                            <td>
                                                <div className="action-buttons">
                                                    <button
                                                        className="btn-edit"
                                                        onClick={() => openForm(micro)}
                                                        title="Edit"
                                                    >
                                                        <Edit2 size={16} />
                                                    </button>
                                                    <button
                                                        className="btn-delete"
                                                        onClick={() => handleDelete(micro._id)}
                                                        title="Delete"
                                                    >
                                                        <Trash2 size={16} />
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))
                                ) : (
                                    <tr>
                                        <td colSpan="5" className="text-center">
                                            No micronutrients found
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>

                    {/* Pagination */}
                    <div className="pagination-section">
                        <div className="info-text">
                            Showing {micronutrients.length} of {totalCount} micronutrients
                        </div>
                        <div className="pagination">
                            <button
                                className="btn-pagination"
                                onClick={() => goToPage(currentPage - 1)}
                                disabled={currentPage === 1}
                            >
                                <ChevronLeft size={18} /> Previous
                            </button>
                            <span className="page-info">{currentPage} / {totalPages}</span>
                            <button
                                className="btn-pagination"
                                onClick={() => goToPage(currentPage + 1)}
                                disabled={currentPage === totalPages}
                            >
                                Next <ChevronRight size={18} />
                            </button>
                        </div>
                    </div>
                </>
            )}

            {/* Form Modal */}
            {showForm && (
                <MicronutrientForm
                    initialData={editingId ? formData : null}
                    onSubmit={handleFormSubmit}
                    onCancel={closeForm}
                    isEditing={!!editingId}
                />
            )}
        </div>
    );
};

export default MicronutrientList;
