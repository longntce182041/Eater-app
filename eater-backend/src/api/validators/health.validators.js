const Joi = require("joi");

const updateHealthInfoSchema = Joi.object({
  age: Joi.number().integer().min(1).max(150).optional(),
  gender: Joi.string().valid("male", "female", "other").optional(),
  height: Joi.number().min(50).max(300).optional(), // in centimeters
  weight: Joi.number().min(20).max(500).optional(), // in kilograms
  dietaryPreferences: Joi.array().items(Joi.string()).optional(),
  allergies: Joi.array().items(Joi.string()).optional(),
  activityLevel: Joi.string()
    .valid("sedentary", "light", "moderate", "active", "very active")
    .optional(),
  healthGoals: Joi.string().max(500).optional(),
  cookingSkillLevel: Joi.string()
    .valid("beginner", "intermediate", "advanced")
    .optional(),
  available_cooking_time: Joi.number().min(0).max(1440).optional(), // in minutes
  daily_calorie_target: Joi.number().min(500).max(10000).optional(), // in kcal
});

const createHealthInfoSchema = Joi.object({
  age: Joi.number().integer().min(1).max(150).required(),
  gender: Joi.string().valid("male", "female", "other").required(),
  height: Joi.number().min(50).max(300).required(),
  weight: Joi.number().min(20).max(500).required(),
  dietaryPreferences: Joi.array().items(Joi.string()).optional(),
  allergies: Joi.array().items(Joi.string()).optional(),
  activityLevel: Joi.string()
    .valid("sedentary", "light", "moderate", "active", "very active")
    .required(),
  healthGoals: Joi.string().max(500).optional(),
  cookingSkillLevel: Joi.string()
    .valid("beginner", "intermediate", "advanced")
    .optional(),
  available_cooking_time: Joi.number().min(0).max(1440).optional(),
  daily_calorie_target: Joi.number().min(500).max(10000).optional(),
});

module.exports = {
  updateHealthInfoSchema,
  createHealthInfoSchema,
};
