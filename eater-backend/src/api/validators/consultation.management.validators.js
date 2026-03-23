const validateDiagnosis = (data) => {
    const errors = {};
    if (!data.userId) errors.userId = "Patient (User ID) is required";
    if (!data.diagnosis) errors.diagnosis = "Diagnosis is required";
    if (!data.recommendations) errors.recommendations = "Recommendations are required";

    return { errors, isValid: Object.keys(errors).length === 0 };
};

const validateDietPlan = (data) => {
    const errors = {};
    if (!data.userId) errors.userId = "Patient (User ID) is required";
    if (!data.date) errors.date = "Date is required";
    if (!data.targetCalories || isNaN(data.targetCalories)) errors.targetCalories = "Valid target calories required";

    return { errors, isValid: Object.keys(errors).length === 0 };
};

module.exports = { validateDiagnosis, validateDietPlan };