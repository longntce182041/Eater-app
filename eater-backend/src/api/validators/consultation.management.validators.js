const validateDiagnosis = (data) => {
    const errors = {};
    if (!data.userId) errors.userId = "Patient (User ID) is required";
    if (!data.diagnosis) errors.diagnosis = "Diagnosis is required";
    if (!data.recommendations) errors.recommendations = "Recommendations are required";

    return { errors, isValid: Object.keys(errors).length === 0 };
};

const validateDietPlan = (data) => {
    const errors = {};
    const MIN_TARGET_CALORIES = 800;
    const MAX_TARGET_CALORIES = 10000;

    if (!data.userId) errors.userId = "Patient (User ID) is required";
    if (!data.date) errors.date = "Date is required";

    const targetCalories = Number(data.targetCalories);
    if (!Number.isInteger(targetCalories)) {
        errors.targetCalories = "Target calories must be a whole number";
    } else if (targetCalories < MIN_TARGET_CALORIES || targetCalories > MAX_TARGET_CALORIES) {
        errors.targetCalories = `Target calories must be between ${MIN_TARGET_CALORIES} and ${MAX_TARGET_CALORIES}`;
    }

    return { errors, isValid: Object.keys(errors).length === 0 };
};

module.exports = { validateDiagnosis, validateDietPlan };