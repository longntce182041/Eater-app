const { validationResult } = require("express-validator");

const validateRequest = (schema) => {
  return async (req, res, next) => {
    try {
      // Validate the request body against the schema
      const { error, value } = schema.validate(req.body, {
        abortEarly: false,
        stripUnknown: true,
      });

      if (error) {
        const errors = error.details.map((detail) => ({
          field: detail.path.join("."),
          message: detail.message,
        }));
        return res.status(400).json({
          status: "fail",
          message: "Validation failed",
          errors,
        });
      }

      // Replace request body with validated data
      req.body = value;
      next();
    } catch (err) {
      next(err);
    }
  };
};

module.exports = { validateRequest };
