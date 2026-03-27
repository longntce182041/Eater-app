const mongoose = require('mongoose');
const { Recipe } = require('../../models/Recipe');
const { RecipesIngredient } = require('../../models/recipes_ingredient');
const { RecipesStep } = require('../../models/recipes_step');
const { RecipeDietType } = require('../../models/recipe_diet_type');
const { RecipeNutrition } = require('../../models/recipe_nutrion');
const { RecipeMicronutrientValues } = require('../../models/recipe_micronutrient_values');
const { IngredientMicronutrientValues } = require('../../models/ingredient_micronutrient_values');
const { DietType } = require('../../models/diet_types');
const { Ingredient } = require('../../models/ingredients');

class RecipeService {
    parseNumber(value) {
        if (value === undefined || value === null || value === '') return null;
        const parsed = Number(value);
        return Number.isFinite(parsed) ? parsed : null;
    }

    buildNutritionFilter(query) {
        const minCalories = this.parseNumber(query.minCalories);
        const maxCalories = this.parseNumber(query.maxCalories);
        const minProtein = this.parseNumber(query.minProtein);
        const maxProtein = this.parseNumber(query.maxProtein);
        const minFat = this.parseNumber(query.minFat);
        const maxFat = this.parseNumber(query.maxFat);
        const minCarbohydrates = this.parseNumber(query.minCarbohydrates);
        const maxCarbohydrates = this.parseNumber(query.maxCarbohydrates);

        const rangeFilter = {};

        if (minCalories !== null || maxCalories !== null) {
            rangeFilter.calories = {
                ...(minCalories !== null ? { $gte: minCalories } : {}),
                ...(maxCalories !== null ? { $lte: maxCalories } : {}),
            };
        }

        if (minProtein !== null || maxProtein !== null) {
            rangeFilter.protein = {
                ...(minProtein !== null ? { $gte: minProtein } : {}),
                ...(maxProtein !== null ? { $lte: maxProtein } : {}),
            };
        }

        if (minFat !== null || maxFat !== null) {
            rangeFilter.fat = {
                ...(minFat !== null ? { $gte: minFat } : {}),
                ...(maxFat !== null ? { $lte: maxFat } : {}),
            };
        }

        if (minCarbohydrates !== null || maxCarbohydrates !== null) {
            rangeFilter.carbohydrates = {
                ...(minCarbohydrates !== null ? { $gte: minCarbohydrates } : {}),
                ...(maxCarbohydrates !== null ? { $lte: maxCarbohydrates } : {}),
            };
        }

        return rangeFilter;
    }

    buildSuggestedCookingTimeOptions(minCookingTime, maxCookingTime) {
        const defaults = [15, 30, 45, 60];
        const validDefaults = defaults.filter((item) => maxCookingTime >= item);

        if (validDefaults.length === 0 && Number.isFinite(maxCookingTime)) {
            return [maxCookingTime];
        }

        if (Number.isFinite(maxCookingTime) && maxCookingTime > 60) {
            return [...validDefaults, maxCookingTime];
        }

        return validDefaults;
    }

    async syncRecipeMicronutrientsFromIngredients(recipeId, ingredients = []) {
        await RecipeMicronutrientValues.deleteMany({ recipeId });

        if (!Array.isArray(ingredients) || ingredients.length === 0) return;

        const ingredientQuantityMap = ingredients.reduce((acc, item) => {
            const ingredientId = String(item?.ingredientId || '');
            if (!mongoose.Types.ObjectId.isValid(ingredientId)) return acc;

            const quantity = this.parseNumber(item?.base_quantity);
            const multiplier = quantity !== null && quantity > 0 ? quantity : 1;

            acc.set(ingredientId, (acc.get(ingredientId) || 0) + multiplier);
            return acc;
        }, new Map());

        if (ingredientQuantityMap.size === 0) return;

        const ingredientIds = [...ingredientQuantityMap.keys()].map(
            (id) => new mongoose.Types.ObjectId(id),
        );

        const ingredientMicronutrients = await IngredientMicronutrientValues.find({
            ingredientId: { $in: ingredientIds },
        }).select('ingredientId micronutrientId amount');

        if (ingredientMicronutrients.length === 0) return;

        const micronutrientTotals = ingredientMicronutrients.reduce((acc, item) => {
            const ingredientId = String(item.ingredientId);
            const micronutrientId = String(item.micronutrientId);
            const multiplier = ingredientQuantityMap.get(ingredientId) || 1;
            const amount = (Number(item.amount) || 0) * multiplier;

            if (amount <= 0) return acc;

            acc.set(micronutrientId, (acc.get(micronutrientId) || 0) + amount);
            return acc;
        }, new Map());

        if (micronutrientTotals.size === 0) return;

        const recipeMicronutrientDocs = [...micronutrientTotals.entries()].map(([micronutrientId, amount]) => ({
            recipeId,
            micronutrientId,
            amount,
        }));

        await RecipeMicronutrientValues.insertMany(recipeMicronutrientDocs);
    }

    async getRecipeFilterOptions(query = {}) {
        const { status } = query;
        const recipeFilter = {};

        if (status) {
            recipeFilter.status = status;
        }

        const recipes = await Recipe.find(recipeFilter).select('_id cookingTime');

        if (recipes.length === 0) {
            return {
                cookingTime: {
                    min: 0,
                    max: 0,
                    suggestedMaxOptions: [],
                },
                nutritionRanges: {
                    calories: { min: 0, max: 0 },
                    protein: { min: 0, max: 0 },
                    fat: { min: 0, max: 0 },
                    carbohydrates: { min: 0, max: 0 },
                },
                dietTypes: [],
                ingredients: [],
            };
        }

        const recipeIds = recipes.map((item) => item._id);
        const cookingTimes = recipes
            .map((item) => Number(item.cookingTime || 0))
            .filter((value) => Number.isFinite(value) && value >= 0);

        const minCookingTime = cookingTimes.length > 0 ? Math.min(...cookingTimes) : 0;
        const maxCookingTime = cookingTimes.length > 0 ? Math.max(...cookingTimes) : 0;

        const [nutritionStats, dietCountStats, ingredientStats, allDietTypes] = await Promise.all([
            RecipeNutrition.aggregate([
                { $match: { recipeId: { $in: recipeIds } } },
                {
                    $group: {
                        _id: null,
                        minCalories: { $min: '$calories' },
                        maxCalories: { $max: '$calories' },
                        minProtein: { $min: '$protein' },
                        maxProtein: { $max: '$protein' },
                        minFat: { $min: '$fat' },
                        maxFat: { $max: '$fat' },
                        minCarbohydrates: { $min: '$carbohydrates' },
                        maxCarbohydrates: { $max: '$carbohydrates' },
                    },
                },
            ]),
            RecipeDietType.aggregate([
                { $match: { recipeId: { $in: recipeIds } } },
                {
                    $group: {
                        _id: '$dietTypeId',
                        recipeCount: { $sum: 1 },
                    },
                },
            ]),
            RecipesIngredient.aggregate([
                { $match: { recipeId: { $in: recipeIds } } },
                {
                    $group: {
                        _id: '$ingredientId',
                        recipeCount: { $sum: 1 },
                    },
                },
                {
                    $lookup: {
                        from: 'ingredients',
                        localField: '_id',
                        foreignField: '_id',
                        as: 'ingredient',
                    },
                },
                {
                    $project: {
                        _id: 0,
                        id: '$_id',
                        recipeCount: 1,
                        name: { $arrayElemAt: ['$ingredient.name', 0] },
                    },
                },
                { $match: { name: { $exists: true, $ne: null } } },
                { $sort: { recipeCount: -1, name: 1 } },
            ]),
            DietType.find({}).select('_id name').sort({ name: 1 }),
        ]);

        const nutrition = nutritionStats[0] || {};
        const dietCountMap = new Map(
            dietCountStats.map((item) => [String(item._id), Number(item.recipeCount || 0)]),
        );

        const dietTypes = allDietTypes
            .map((item) => ({
                id: String(item._id),
                name: item.name,
                recipeCount: dietCountMap.get(String(item._id)) || 0,
            }))
            .sort((a, b) => {
                if (b.recipeCount !== a.recipeCount) return b.recipeCount - a.recipeCount;
                return a.name.localeCompare(b.name);
            });

        return {
            cookingTime: {
                min: Number(minCookingTime || 0),
                max: Number(maxCookingTime || 0),
                suggestedMaxOptions: this.buildSuggestedCookingTimeOptions(
                    Number(minCookingTime || 0),
                    Number(maxCookingTime || 0),
                ),
            },
            nutritionRanges: {
                calories: {
                    min: Number(nutrition.minCalories || 0),
                    max: Number(nutrition.maxCalories || 0),
                },
                protein: {
                    min: Number(nutrition.minProtein || 0),
                    max: Number(nutrition.maxProtein || 0),
                },
                fat: {
                    min: Number(nutrition.minFat || 0),
                    max: Number(nutrition.maxFat || 0),
                },
                carbohydrates: {
                    min: Number(nutrition.minCarbohydrates || 0),
                    max: Number(nutrition.maxCarbohydrates || 0),
                },
            },
            dietTypes,
            ingredients: ingredientStats.map((item) => ({
                id: String(item.id),
                name: item.name,
                recipeCount: Number(item.recipeCount || 0),
            })),
        };
    }

    // 1. Get All
    async getAllRecipes(query) {
        const {
            keyword,
            status,
            page = 1,
            limit = 10,
            maxCookingTime,
            dietTypes,
            dietTypeIds,
            ingredients,
        } = query;
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

        const nutritionFilter = this.buildNutritionFilter(query);
        const hasNutritionFilter = Object.keys(nutritionFilter).length > 0;

        const dietNames = String(dietTypes || '')
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean);

        const dietIdsFromQuery = String(dietTypeIds || '')
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean)
            .filter((item) => mongoose.Types.ObjectId.isValid(item));

        const ingredientNames = String(ingredients || '')
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean);

        const hasDietFilter = dietNames.length > 0 || dietIdsFromQuery.length > 0;
        const hasIngredientFilter = ingredientNames.length > 0;

        let matchedRecipeIds = null;

        if (hasNutritionFilter) {
            const nutritionMatched = await RecipeNutrition.find(nutritionFilter).select('recipeId');
            const nutritionRecipeIds = nutritionMatched.map((item) => String(item.recipeId));
            matchedRecipeIds = new Set(nutritionRecipeIds);
        }

        if (hasDietFilter) {
            let finalDietTypeIds = [...dietIdsFromQuery];

            if (dietNames.length > 0) {
                const exactCaseInsensitiveNames = dietNames.map((name) => new RegExp(`^${name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, 'i'));
                const dietDocs = await DietType.find({ name: { $in: exactCaseInsensitiveNames } }).select('_id');
                finalDietTypeIds = [
                    ...new Set([...finalDietTypeIds, ...dietDocs.map((doc) => String(doc._id))]),
                ];
            }

            if (finalDietTypeIds.length === 0) {
                return { recipes: [], total: 0, page: parseInt(page), totalPages: 0 };
            }

            const dietMatched = await RecipeDietType.find({
                dietTypeId: { $in: finalDietTypeIds },
            }).select('recipeId');

            const dietRecipeIds = new Set(dietMatched.map((item) => String(item.recipeId)));

            if (matchedRecipeIds === null) {
                matchedRecipeIds = dietRecipeIds;
            } else {
                matchedRecipeIds = new Set([...matchedRecipeIds].filter((id) => dietRecipeIds.has(id)));
            }
        }

        if (hasIngredientFilter) {
            const exactCaseInsensitiveNames = ingredientNames.map(
                (name) =>
                    new RegExp(
                        `^${name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`,
                        'i',
                    ),
            );

            const ingredientDocs = await Ingredient.find({
                name: { $in: exactCaseInsensitiveNames },
            }).select('_id');

            const ingredientIds = ingredientDocs.map((item) => item._id);

            if (ingredientIds.length === 0) {
                return { recipes: [], total: 0, page: parseInt(page), totalPages: 0 };
            }

            const ingredientMatched = await RecipesIngredient.find({
                ingredientId: { $in: ingredientIds },
            }).select('recipeId');

            const ingredientRecipeIds = new Set(
                ingredientMatched.map((item) => String(item.recipeId)),
            );

            if (matchedRecipeIds === null) {
                matchedRecipeIds = ingredientRecipeIds;
            } else {
                matchedRecipeIds = new Set(
                    [...matchedRecipeIds].filter((id) => ingredientRecipeIds.has(id)),
                );
            }
        }

        if (matchedRecipeIds !== null) {
            const ids = [...matchedRecipeIds].map((id) => new mongoose.Types.ObjectId(id));
            filter._id = { $in: ids };
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

            await this.syncRecipeMicronutrientsFromIngredients(recipeId, data.ingredients || []);

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

            await this.syncRecipeMicronutrientsFromIngredients(id, data.ingredients);
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

    // 6. Get Full Recipe Details (with micronutrients)
    async getFullRecipeDetails(id) {
        const recipe = await Recipe.findById(id);
        if (!recipe) throw new Error("Recipe not found");

        const [ingredients, steps, nutrition, dietTypes, micronutrients] = await Promise.all([
            RecipesIngredient.find({ recipeId: id }).populate('ingredientId'),
            RecipesStep.find({ recipeId: id }).sort({ stepNumber: 1 }),
            RecipeNutrition.findOne({ recipeId: id }),
            RecipeDietType.find({ recipeId: id }).populate('dietTypeId'),
            RecipeMicronutrientValues.find({ recipeId: id }).populate('micronutrientId')
        ]);

        return {
            ...recipe.toObject(),
            ingredients,
            steps,
            nutrition,
            dietTypes,
            micronutrients
        };
    }

    // 7. Delete Recipe
    async deleteRecipe(id) {
        const recipe = await Recipe.findById(id);
        if (!recipe) throw new Error("Recipe not found");

        await Promise.all([
            Recipe.findByIdAndDelete(id),
            RecipesIngredient.deleteMany({ recipeId: id }),
            RecipesStep.deleteMany({ recipeId: id }),
            RecipeDietType.deleteMany({ recipeId: id }),
            RecipeNutrition.deleteMany({ recipeId: id }),
            RecipeMicronutrientValues.deleteMany({ recipeId: id }),
        ]);

        return { message: "Recipe and all related data deleted" };
    }
}

module.exports = new RecipeService();