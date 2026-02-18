import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import './MicronutrientForm.css';

const MicronutrientForm = ({ initialData, onSubmit, onCancel, isEditing }) => {
    const [formData, setFormData] = useState({
        name: '',
        unit: '',
        description: '',
    });
    const [errors, setErrors] = useState({});
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (initialData) {
            setFormData(initialData);
        }
    }, [initialData]);

    // Validate form
    const validateForm = () => {
        const newErrors = {};

        if (!formData.name || formData.name.trim() === '') {
            newErrors.name = 'Name is required';
        } else if (formData.name.length < 2) {
            newErrors.name = 'Name must be at least 2 characters';
        } else if (formData.name.length > 100) {
            newErrors.name = 'Name must not exceed 100 characters';
        }

        if (!formData.unit || formData.unit.trim() === '') {
            newErrors.unit = 'Unit is required';
        } else if (formData.unit.length > 20) {
            newErrors.unit = 'Unit must not exceed 20 characters';
        }

        if (formData.description && formData.description.length > 500) {
            newErrors.description = 'Description must not exceed 500 characters';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    // Handle input change
    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value,
        }));
        // Clear error for this field
        if (errors[name]) {
            setErrors(prev => ({
                ...prev,
                [name]: '',
            }));
        }
    };

    // Handle submit
    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!validateForm()) {
            return;
        }

        setLoading(true);
        try {
            await onSubmit(formData);
        } catch (err) {
            setErrors({ submit: err.message || 'Failed to save' });
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="modal-overlay">
            <div className="modal-content">
                <div className="modal-header">
                    <h2>{isEditing ? 'Edit Micronutrient' : 'Create New Micronutrient'}</h2>
                    <button className="btn-close" onClick={onCancel} disabled={loading}>
                        <X size={24} />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="micronutrient-form">
                    {/* Name Field */}
                    <div className="form-group">
                        <label htmlFor="name">Micronutrient Name *</label>
                        <input
                            type="text"
                            id="name"
                            name="name"
                            value={formData.name}
                            onChange={handleChange}
                            placeholder="e.g., Vitamin C, Iron, Calcium"
                            className={errors.name ? 'form-input error' : 'form-input'}
                            disabled={loading}
                        />
                        {errors.name && <span className="error-text">{errors.name}</span>}
                    </div>

                    {/* Unit Field */}
                    <div className="form-group">
                        <label htmlFor="unit">Unit *</label>
                        <input
                            type="text"
                            id="unit"
                            name="unit"
                            value={formData.unit}
                            onChange={handleChange}
                            placeholder="e.g., mg, mcg, g, IU"
                            className={errors.unit ? 'form-input error' : 'form-input'}
                            disabled={loading}
                        />
                        {errors.unit && <span className="error-text">{errors.unit}</span>}
                    </div>

                    {/* Description Field */}
                    <div className="form-group">
                        <label htmlFor="description">Description</label>
                        <textarea
                            id="description"
                            name="description"
                            value={formData.description}
                            onChange={handleChange}
                            placeholder="Enter description (optional)"
                            rows="4"
                            className={errors.description ? 'form-textarea error' : 'form-textarea'}
                            disabled={loading}
                        />
                        {errors.description && <span className="error-text">{errors.description}</span>}
                    </div>

                    {/* Submit Error */}
                    {errors.submit && <div className="alert-error">{errors.submit}</div>}

                    {/* Form Actions */}
                    <div className="form-actions">
                        <button
                            type="button"
                            className="btn-cancel"
                            onClick={onCancel}
                            disabled={loading}
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            className="btn-submit"
                            disabled={loading}
                        >
                            {loading ? 'Saving...' : (isEditing ? 'Update' : 'Create')}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default MicronutrientForm;
