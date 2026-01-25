// Validator for Micronutrient Management

function validateCreateMicronutrient(data) {
    const errors = {};

    // Validate name
    if (!data.name || data.name.trim() === "") {
        errors.name = "Name is required";
    } else if (data.name.length < 2) {
        errors.name = "Name must be at least 2 characters";
    } else if (data.name.length > 100) {
        errors.name = "Name must not exceed 100 characters";
    }

    // Validate unit
    if (!data.unit || data.unit.trim() === "") {
        errors.unit = "Unit is required";
    } else if (data.unit.length > 20) {
        errors.unit = "Unit must not exceed 20 characters";
    }

    // Validate description (optional)
    if (data.description && data.description.length > 500) {
        errors.description = "Description must not exceed 500 characters";
    }

    return {
        errors,
        isValid: Object.keys(errors).length === 0,
    };
}

function validateUpdateMicronutrient(data) {
    const errors = {};

    // Validate name (if provided)
    if (data.name !== undefined) {
        if (data.name.trim() === "") {
            errors.name = "Name cannot be empty";
        } else if (data.name.length < 2) {
            errors.name = "Name must be at least 2 characters";
        } else if (data.name.length > 100) {
            errors.name = "Name must not exceed 100 characters";
        }
    }

    // Validate unit (if provided)
    if (data.unit !== undefined) {
        if (data.unit.trim() === "") {
            errors.unit = "Unit cannot be empty";
        } else if (data.unit.length > 20) {
            errors.unit = "Unit must not exceed 20 characters";
        }
    }

    // Validate description (if provided)
    if (data.description !== undefined && data.description.length > 500) {
        errors.description = "Description must not exceed 500 characters";
    }

    return {
        errors,
        isValid: Object.keys(errors).length === 0,
    };
}

module.exports = {
    validateCreateMicronutrient,
    validateUpdateMicronutrient,
};
