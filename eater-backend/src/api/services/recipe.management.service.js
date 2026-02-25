// src/api/services/recipe.management.service.js
const mongoose = require('mongoose');
const { Recipe } = require('../../models/Recipe');
const { RecipesIngredient } = require('../../models/recipes_ingredient');
const { RecipesStep } = require('../../models/recipes_step');
const { RecipeDietType } = require('../../models/recipe_diet_type');
const { RecipeNutrition } = require('../../models/recipe_nutrion');

class RecipeService {
    // 1. Get All
    async getAllRecipes(query) {
        const { keyword, status = 'published', page = 1, limit = 10, maxCookingTime } = query;
        let filter = {};

        // Search in both name and description
        if (keyword) {
            filter.$or = [
                { name: { $regex: keyword, $options: "i" } },
                { description: { $regex: keyword, $options: "i" } }
            ];
        }

        // Filter by status (default: published for mobile apps)
        if (status) {
            filter.status = status;
        }

        // Filter by max cooking time (useful for quick meal searches)
        if (maxCookingTime) {
            filter.cookingTime = { $lte: parseInt(maxCookingTime) };
        }

        const skip = (parseInt(page) - 1) * parseInt(limit);

        const recipes = await Recipe.find(filter)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Recipe.countDocuments(filter);

        return { recipes, total, page: parseInt(page), totalPages: Math.ceil(total / limit) };
    }

    // 2. Get Detail
    async getRecipeById(id) {
        const recipe = await Recipe.findById(id);
        if (!recipe) throw new Error("Recipe not found");

        const [ingredients, steps, nutrition, dietTypes] = await Promise.all([
            RecipesIngredient.find({ recipeId: id }).populate('ingredientId'),
            RecipesStep.find({ recipeId: id }).sort({ stepNumber: 1 }),
            RecipeNutrition.findOne({ recipeId: id }),
            RecipeDietType.find({ recipeId: id }).populate('dietTypeId')
        ]);

        return {
            ...recipe.toObject(),
            ingredients,
            steps,
            nutrition,
            dietTypes
        };
    }

    // 3. Create Recipe
    async createRecipe(data) {
        // 3.1 Tạo Recipe chính
        const newRecipe = new Recipe({
            name: data.name,
            description: data.description,
            imageUrl: data.imageUrl,
            cookingTime: data.cookingTime,
            baseServings: data.baseServings,
            status: data.status || 'draft'
        });
        const savedRecipe = await newRecipe.save();
        const recipeId = savedRecipe._id;

        try {
            // 3.2 Lưu Ingredients
            if (data.ingredients && data.ingredients.length > 0) {
                const ingredientsData = data.ingredients.map(ing => ({
                    recipeId: recipeId,
                    ingredientId: ing.ingredientId,
                    base_quantity: ing.base_quantity,
                    unit: ing.unit
                }));
                await RecipesIngredient.insertMany(ingredientsData);
            }

            // 3.3 Lưu Steps
            if (data.steps && data.steps.length > 0) {
                const stepsData = data.steps.map((step, index) => ({
                    recipeId: recipeId,
                    stepNumber: step.stepNumber || index + 1,
                    instruction: step.instruction
                }));
                await RecipesStep.insertMany(stepsData);
            }

            // 3.4 Lưu Diet Types
            if (data.dietTypeIds && data.dietTypeIds.length > 0) {
                const dietData = data.dietTypeIds.map(dtId => ({
                    recipeId: recipeId,
                    dietTypeId: dtId
                }));
                await RecipeDietType.insertMany(dietData);
            }

            // 3.5 Lưu Nutrition
            if (data.nutrition) {
                await new RecipeNutrition({
                    recipeId: recipeId,
                    calories: data.nutrition.calories || 0,
                    protein: data.nutrition.protein || 0,
                    fat: data.nutrition.fat || 0,
                    carbohydrates: data.nutrition.carbohydrates || 0
                }).save();
            }

            return savedRecipe;

        } catch (error) {
            // Nếu lỗi ở các bước phụ, xóa recipe chính để tránh rác (Manual Rollback)
            await Recipe.findByIdAndDelete(recipeId);
            throw error;
        }
    }

    // 4. Update Recipe
    async updateRecipe(id, data) {
        const recipe = await Recipe.findById(id);
        if (!recipe) throw new Error("Recipe not found");

        // 4.1 Update thông tin cơ bản
        Object.assign(recipe, {
            name: data.name,
            description: data.description,
            imageUrl: data.imageUrl,
            cookingTime: data.cookingTime,
            baseServings: data.baseServings,
            status: data.status
        });
        await recipe.save();

        // 4.2 Xử lý Ingredients
        if (data.ingredients) {
            await RecipesIngredient.deleteMany({ recipeId: id });
            const ingredientsData = data.ingredients.map(ing => ({
                recipeId: id,
                ingredientId: ing.ingredientId,
                base_quantity: ing.base_quantity,
                unit: ing.unit
            }));
            await RecipesIngredient.insertMany(ingredientsData);
        }

        // 4.3 Xử lý Steps
        if (data.steps) {
            await RecipesStep.deleteMany({ recipeId: id });
            const stepsData = data.steps.map((step, index) => ({
                recipeId: id,
                stepNumber: step.stepNumber || index + 1,
                instruction: step.instruction
            }));
            await RecipesStep.insertMany(stepsData);
        }

        // 4.4 Xử lý Nutrition
        if (data.nutrition) {
            let nutriRecord = await RecipeNutrition.findOne({ recipeId: id });
            if (!nutriRecord) {
                nutriRecord = new RecipeNutrition({ recipeId: id });
            }
            nutriRecord.calories = data.nutrition.calories;
            nutriRecord.protein = data.nutrition.protein;
            nutriRecord.fat = data.nutrition.fat;
            nutriRecord.carbohydrates = data.nutrition.carbohydrates;
            await nutriRecord.save();
        }

        // 4.5 Xử lý Diet Types
        if (data.dietTypeIds) {
            await RecipeDietType.deleteMany({ recipeId: id });
            const dietData = data.dietTypeIds.map(dtId => ({
                recipeId: id,
                dietTypeId: dtId
            }));
            await RecipeDietType.insertMany(dietData);
        }

        return recipe;
    }

    // 5. Get Nutrition Values
    async getNutritionByRecipeId(recipeId) {
        const nutrition = await RecipeNutrition.findOne({ recipeId }).populate('recipeId', 'name');
        if (!nutrition) {
            throw new Error("Nutrition information not found for this recipe");
        }
        return nutrition;
    }

    // 6. Delete Recipe
    async deleteRecipe(id) {
        const recipe = await Recipe.findById(id);
        if (!recipe) throw new Error("Recipe not found");

        await Promise.all([
            Recipe.findByIdAndDelete(id),
            RecipesIngredient.deleteMany({ recipeId: id }),
            RecipesStep.deleteMany({ recipeId: id }),
            RecipeDietType.deleteMany({ recipeId: id }),
            RecipeNutrition.deleteMany({ recipeId: id }),
        ]);

        return { message: "Recipe and all related data deleted" };
    }
}

module.exports = new RecipeService();