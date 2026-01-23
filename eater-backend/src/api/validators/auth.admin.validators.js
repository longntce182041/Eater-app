//Chứa các file validation schemas và rules để kiểm tra tính hợp lệ của dữ liệu đầu vào từ các request API.
const validateLoginInput = (data) => {
    const errors = {};

    if (!data.email) {
        errors.email = "Email field is required";
    } else if (!/^\S+@\S+\.\S+$/.test(data.email)) {
        errors.email = "Email is invalid";
    }

    if (!data.password) {
        errors.password = "Password field is required";
    }

    return {
        errors,
        isValid: Object.keys(errors).length === 0,
    };
};

module.exports = { validateLoginInput };