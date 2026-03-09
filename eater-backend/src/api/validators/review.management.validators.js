const validateReview = (data) => {
    const errors = {};

    // Validate Rating
    if (!data.rating) {
        errors.rating = "Rating is required";
    } else if (isNaN(data.rating) || data.rating < 1 || data.rating > 5) {
        errors.rating = "Rating must be a number between 1 and 5";
    }

    // Validate Comment (Optional but length check is good)
    if (data.comment && data.comment.length > 500) {
        errors.comment = "Comment must not exceed 500 characters";
    }

    // Khi Create bắt buộc phải có userId và recipeId
    // (Tuy nhiên Admin thường chỉ xóa/xem, ít khi tạo review thay user, nhưng cứ validate cho đủ)
    if (!data.userId) errors.userId = "User ID is required";
    if (!data.recipeId) errors.recipeId = "Recipe ID is required";

    return {
        errors,
        isValid: Object.keys(errors).length === 0
    };
};

module.exports = { validateReview };