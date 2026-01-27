// src/api/controllers/ingredient.management.controller.js
const ingredientService = require("../services/ingredient.management.service");
const { validateIngredient } = require("../validators/ingredient.management.validators");
const { getActionMessage } = require("../../utils/actionMessage.util");

class IngredientManagementController {
    // GET /api/ingredients
    async getIngredients(req, res) {
        try {
            const result = await ingredientService.getAllIngredients(req.query);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    // GET /api/ingredients/:id
    async getIngredientDetail(req, res) {
        try {
            const ingredient = await ingredientService.getIngredientById(req.params.id);
            res.json({ success: true, data: ingredient });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    }

    // POST /api/ingredients
    async createIngredient(req, res) {
        try {
            // Validate input
            const { errors, isValid } = validateIngredient(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const newIngredient = await ingredientService.createIngredient(req.body);
            const message = getActionMessage('create', 'Ingredient');
            res.status(201).json({ success: true, message, data: newIngredient });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // PUT /api/ingredients/:id
    async updateIngredient(req, res) {
        try {
            // Validate sơ bộ (nếu cần thiết có thể dùng hàm validate riêng cho update)
            const updatedIngredient = await ingredientService.updateIngredient(req.params.id, req.body);
            const message = getActionMessage('update', 'Ingredient');
            res.json({ success: true, message, data: updatedIngredient });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // DELETE /api/ingredients/:id
    async deleteIngredient(req, res) {
        try {
            await ingredientService.deleteIngredient(req.params.id);
            const message = getActionMessage('delete', 'Ingredient');
            res.json({ success: true, message });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }
}

module.exports = new IngredientManagementController();