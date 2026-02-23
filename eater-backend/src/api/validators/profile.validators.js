const Joi = require("joi");

// Create profile validation schema
const createProfileSchema = Joi.object({
  firstName: Joi.string().max(50).default("").messages({
    "string.max": "First name must not exceed 50 characters",
  }),
  lastName: Joi.string().max(50).default("").messages({
    "string.max": "Last name must not exceed 50 characters",
  }),
  phoneNumber: Joi.string()
    .pattern(/^[0-9+\-()\s]*$/)
    .max(20)
    .default("")
    .messages({
      "string.pattern.base": "Phone number is invalid",
      "string.max": "Phone number must not exceed 20 characters",
    }),
  avatar: Joi.string().uri().default("").messages({
    "string.uri": "Avatar must be a valid URL",
  }),
  age: Joi.number().integer().min(1).max(150).required().messages({
    "number.base": "Age must be a number",
    "number.min": "Age must be at least 1",
    "number.max": "Age must not exceed 150",
    "any.required": "Age is required",
  }),
  gender: Joi.string().valid("male", "female", "other").required().messages({
    "any.only": "Gender must be one of: male, female, other",
    "any.required": "Gender is required",
  }),
  height: Joi.number().positive().required().messages({
    "number.base": "Height must be a number",
    "number.positive": "Height must be greater than 0",
    "any.required": "Height is required",
  }),
  weight: Joi.number().positive().required().messages({
    "number.base": "Weight must be a number",
    "number.positive": "Weight must be greater than 0",
    "any.required": "Weight is required",
  }),
  dietaryPreferences: Joi.array().items(Joi.string()).default([]).messages({
    "array.base": "Dietary preferences must be an array",
  }),
  allergies: Joi.array().items(Joi.string()).default([]).messages({
    "array.base": "Allergies must be an array",
  }),
  activityLevel: Joi.string()
    .valid("sedentary", "light", "moderate", "active", "very active")
    .required()
    .messages({
      "any.only":
        "Activity level must be one of: sedentary, light, moderate, active, very active",
      "any.required": "Activity level is required",
    }),
  healthGoals: Joi.string().max(500).default("").messages({
    "string.max": "Health goals must not exceed 500 characters",
  }),
  cookingSkillLevel: Joi.string()
    .valid("beginner", "intermediate", "advanced")
    .default("beginner")
    .messages({
      "any.only":
        "Cooking skill level must be one of: beginner, intermediate, advanced",
    }),
  available_cooking_time: Joi.number()
    .integer()
    .positive()
    .default(30)
    .messages({
      "number.base": "Available cooking time must be a number",
      "number.positive": "Available cooking time must be greater than 0",
    }),
  daily_calorie_target: Joi.number().positive().default(2000).messages({
    "number.base": "Daily calorie target must be a number",
    "number.positive": "Daily calorie target must be greater than 0",
  }),
});

// Update profile validation schema (all fields are optional)
const updateProfileSchema = Joi.object({
  firstName: Joi.string().max(50).allow("").messages({
    "string.max": "First name must not exceed 50 characters",
  }),
  lastName: Joi.string().max(50).allow("").messages({
    "string.max": "Last name must not exceed 50 characters",
  }),
  phoneNumber: Joi.string()
    .pattern(/^[0-9+\-(\)\s]*$/)
    .max(20)
    .allow("")
    .messages({
      "string.pattern.base": "Phone number is invalid",
      "string.max": "Phone number must not exceed 20 characters",
    }),
  avatar: Joi.string().uri().allow("").messages({
    "string.uri": "Avatar must be a valid URL",
  }),
  age: Joi.number().integer().min(1).max(150).messages({
    "number.base": "Age must be a number",
    "number.min": "Age must be at least 1",
    "number.max": "Age must not exceed 150",
  }),
  gender: Joi.string().valid("male", "female", "other").messages({
    "any.only": "Gender must be one of: male, female, other",
  }),
  height: Joi.number().positive().messages({
    "number.base": "Height must be a number",
    "number.positive": "Height must be greater than 0",
  }),
  weight: Joi.number().positive().messages({
    "number.base": "Weight must be a number",
    "number.positive": "Weight must be greater than 0",
  }),
  goal_weight: Joi.number().positive().allow(null).messages({
    "number.base": "Goal weight must be a number",
    "number.positive": "Goal weight must be greater than 0",
  }),
  healthGoals: Joi.string().max(500).allow("").messages({
    "string.max": "Health goals must not exceed 500 characters",
  }),
  diet_typeId: Joi.string().allow("").messages({
    "string.base": "Diet type ID must be a valid ID",
  }),
  allergies: Joi.array().items(Joi.string()).messages({
    "array.base": "Allergies must be an array",
  }),
  dislikesIngredients: Joi.array().items(Joi.string()).messages({
    "array.base": "Dislikes must be an array",
  }),
  activityLevel: Joi.string()
    .valid("sedentary", "light", "moderate", "active", "very active")
    .messages({
      "any.only":
        "Activity level must be one of: sedentary, light, moderate, active, very active",
    }),
  cookingSkillLevel: Joi.string()
    .valid("beginner", "intermediate", "advanced")
    .messages({
      "any.only":
        "Cooking skill level must be one of: beginner, intermediate, advanced",
    }),
  available_cooking_time: Joi.number().integer().positive().messages({
    "number.base": "Available cooking time must be a number",
    "number.positive": "Available cooking time must be greater than 0",
  }),
  daily_calorie_target: Joi.number().positive().messages({
    "number.base": "Daily calorie target must be a number",
    "number.positive": "Daily calorie target must be greater than 0",
  }),
})
  .min(1)
  .messages({
    "object.min": "At least one field must be provided for update",
  });

module.exports = {
  createProfileSchema,
  updateProfileSchema,
};
