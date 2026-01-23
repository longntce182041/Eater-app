const validateCreateUser = (data) => {
    const errors = {};

    if (!data.email) {
        errors.email = "Email is required";
    } else if (!/^\S+@\S+\.\S+$/.test(data.email)) {
        errors.email = "Email is invalid";
    }

    if (!data.password) {
        errors.password = "Password is required";
    } else if (data.password.length < 6) {
        errors.password = "Password must be at least 6 characters";
    }

    // Nếu muốn validate role
    if (data.role && !["user", "admin", "nutritionist"].includes(data.role)) {
        errors.role = "Invalid role";
    }

    return {
        errors,
        isValid: Object.keys(errors).length === 0,
    };
};

const validateUpdateUser = (data) => {
    const errors = {};

    // Update thì password có thể để trống (nghĩa là không đổi pass)
    if (data.email && !/^\S+@\S+\.\S+$/.test(data.email)) {
        errors.email = "Email is invalid";
    }

    return {
        errors,
        isValid: Object.keys(errors).length === 0,
    };
};

module.exports = { validateCreateUser, validateUpdateUser };