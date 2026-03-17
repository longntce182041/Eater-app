const validateCreateNutritionist = (data) => {
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

  if (!data.fullName || data.fullName.trim() === "") {
    errors.fullName = "Full name is required";
  }

  if (!data.specialization || data.specialization.trim() === "") {
    errors.specialization = "Specialization is required";
  }

  if (
    data.experience === undefined ||
    data.experience === null ||
    data.experience === ""
  ) {
    errors.experience = "Experience is required";
  } else if (Number.isNaN(Number(data.experience))) {
    errors.experience = "Experience must be a number";
  } else if (Number(data.experience) < 0) {
    errors.experience = "Experience cannot be negative";
  }

  if (
    data.certifications_url !== undefined &&
    !Array.isArray(data.certifications_url)
  ) {
    errors.certifications_url = "certifications_url must be an array of URLs";
  }

  if (data.verified !== undefined && typeof data.verified !== "boolean") {
    errors.verified = "verified must be a boolean";
  }

  return {
    errors,
    isValid: Object.keys(errors).length === 0,
  };
};

const validateUpdateNutritionist = (data) => {
  const errors = {};

  if (data.fullName !== undefined && data.fullName.trim() === "") {
    errors.fullName = "Full name cannot be empty";
  }

  if (data.specialization !== undefined && data.specialization.trim() === "") {
    errors.specialization = "Specialization cannot be empty";
  }

  if (data.experience !== undefined) {
    if (Number.isNaN(Number(data.experience))) {
      errors.experience = "Experience must be a number";
    } else if (Number(data.experience) < 0) {
      errors.experience = "Experience cannot be negative";
    }
  }

  if (
    data.certifications_url !== undefined &&
    !Array.isArray(data.certifications_url)
  ) {
    errors.certifications_url = "certifications_url must be an array of URLs";
  }

  if (data.verified !== undefined && typeof data.verified !== "boolean") {
    errors.verified = "verified must be a boolean";
  }

  return {
    errors,
    isValid: Object.keys(errors).length === 0,
  };
};

module.exports = {
  validateCreateNutritionist,
  validateUpdateNutritionist,
};
