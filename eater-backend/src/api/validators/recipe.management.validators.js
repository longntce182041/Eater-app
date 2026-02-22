const validateRecipe = (data) => {
    const errors = {};

    if (!data.name) errors.name = "Recipe name is required";
    if (!data.description) errors.description = "Description is required";
    if (!data.cookingTime || isNaN(data.cookingTime)) errors.cookingTime = "Cooking time must be a number (minutes)";
    if (!data.baseServings || isNaN(data.baseServings)) errors.baseServings = "Base servings must be a number";

    // Validate Ingredients Array
    if (!data.ingredients || !Array.isArray(data.ingredients) || data.ingredients.length === 0) {
        errors.ingredients = "At least one ingredient is required";
    } else {
        data.ingredients.forEach((ing, index) => {
            if (!ing.ingredientId) errors[`ingredients[${index}]`] = "Ingredient ID is missing";
            if (!ing.base_quantity) errors[`ingredients[${index}]`] = "Quantity is missing";
            if (!ing.unit) errors[`ingredients[${index}]`] = "Unit is missing";
        });
    }

    // Validate Steps Array
    if (!data.steps || !Array.isArray(data.steps) || data.steps.length === 0) {
        errors.steps = "Cooking steps are required";
    }

    return {
        errors,
        isValid: Object.keys(errors).length === 0
    };
};

module.exports = { validateRecipe };