const { body, query, validationResult } = require("express-validator");

/**
 * Validation middleware for meal plan generation
 */
const validateMealPlanGeneration = [
  body("userId").optional().isMongoId().withMessage("Invalid user ID format"),
  body("days")
    .optional()
    .isInt({ min: 1, max: 30 })
    .withMessage("Days must be between 1 and 30"),
  body("useML").optional().isBoolean().withMessage("useML must be a boolean"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }
    next();
  },
];

/**
 * Validation middleware for getting user meal plans
 */
const validateGetMealPlans = [
  query("userId").optional().isMongoId().withMessage("Invalid user ID format"),
  query("limit")
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage("Limit must be between 1 and 100"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }
    next();
  },
];

/**
 * Validation middleware for getting recommended recipes
 */
const validateGetRecommendedRecipes = [
  query("userId").optional().isMongoId().withMessage("Invalid user ID format"),
  query("limit")
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage("Limit must be between 1 and 100"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }
    next();
  },
];

/**
 * Validation middleware for getting user data
 */
const validateGetUserData = [
  query("userId").optional().isMongoId().withMessage("Invalid user ID format"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }
    next();
  },
];

/**
 * Validation middleware for analyzing user profile
 */
const validateAnalyzeUserProfile = [
  body("userId").optional().isMongoId().withMessage("Invalid user ID format"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }
    next();
  },
];

module.exports = {
  validateMealPlanGeneration,
  validateGetMealPlans,
  validateGetRecommendedRecipes,
  validateGetUserData,
  validateAnalyzeUserProfile,
};
