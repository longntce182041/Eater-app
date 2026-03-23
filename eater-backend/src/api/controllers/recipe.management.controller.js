const recipeService = require("../services/recipe.management.service");
const { validateRecipe } = require("../validators/recipe.management.validators");
const { getActionMessage } = require("../../utils/actionMessage.util");

class RecipeManagementController {
    // GET List
    async getRecipes(req, res) {
        try {
            const result = await recipeService.getAllRecipes(req.query);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    // GET Detail
    async getRecipeDetail(req, res) {
        try {
            const recipe = await recipeService.getRecipeById(req.params.id);
            res.json({ success: true, data: recipe });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    }

    // POST Create
    async createRecipe(req, res) {
        try {
            // Validate
            const { errors, isValid } = validateRecipe(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const newRecipe = await recipeService.createRecipe(req.body);
            const message = getActionMessage('create', 'Recipe');
            res.status(201).json({ success: true, message, data: newRecipe });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // PUT Update
    async updateRecipe(req, res) {
        try {
            // Validate (Có thể lỏng hơn Create một chút nếu muốn, nhưng ở đây dùng chung cho chặt chẽ)
            const { errors, isValid } = validateRecipe(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const updatedRecipe = await recipeService.updateRecipe(req.params.id, req.body);
            const message = getActionMessage('update', 'Recipe');
            res.json({ success: true, message, data: updatedRecipe });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // DELETE
    async deleteRecipe(req, res) {
        try {
            await recipeService.deleteRecipe(req.params.id);
            const message = getActionMessage('delete', 'Recipe');
            res.json({ success: true, message });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // GET Nutrition Values
    async getRecipeNutrition(req, res) {
        try {
            const nutrition = await recipeService.getNutritionByRecipeId(req.params.id);
            res.json({ success: true, data: nutrition });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    }

    // GET Full Recipe Details (with ingredients, steps, nutrition, micronutrients)
    async getFullRecipeDetail(req, res) {
        try {
            const recipeDetail = await recipeService.getFullRecipeDetails(req.params.id);
            res.json({ success: true, data: recipeDetail });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    }
}

module.exports = new RecipeManagementController();