const validateIngredient = (data) => {
    const errors = {};
    const MAX_VALUE = 10000; // Giới hạn tối đa

    // 1. Validate Tên
    if (!data.name || data.name.trim() === "") {
        errors.name = "Ingredient name is required";
    }

    // 2. Validate Đơn vị
    if (!data.unit) {
        errors.unit = "Unit is required (e.g., gram, ml, piece)";
    }

    // --- Hàm phụ để kiểm tra số (Calories, Protein, Carbs, Fats) ---
    const validateNumberField = (value, fieldName) => {
        // Kiểm tra bỏ trống (undefined, null hoặc chuỗi rỗng)
        if (value === undefined || value === null || value === "") {
            return `${fieldName} is required and cannot be empty`;
        }

        const num = Number(value);

        // Kiểm tra có phải là số không
        if (isNaN(num)) {
            return `${fieldName} must be a valid number`;
        }

        // Kiểm tra không được nhỏ hơn 0
        if (num < 0) {
            return `${fieldName} cannot be less than 0`;
        }

        // Kiểm tra không được lớn hơn 10,000
        if (num > MAX_VALUE) {
            return `${fieldName} cannot exceed ${MAX_VALUE}`;
        }

        return null; // Không có lỗi
    };

    // 3. Thực hiện validate các trường số
    const caloriesError = validateNumberField(data.calories_per_unit, "Calories");
    if (caloriesError) errors.calories_per_unit = caloriesError;

    const proteinError = validateNumberField(data.protein, "Protein");
    if (proteinError) errors.protein = proteinError;

    const carbsError = validateNumberField(data.carbs, "Carbs");
    if (carbsError) errors.carbs = carbsError;

    const fatsError = validateNumberField(data.fats, "Fats");
    if (fatsError) errors.fats = fatsError;


    return {
        errors,
        isValid: Object.keys(errors).length === 0,
    };
};

module.exports = { validateIngredient };