// src/api/services/ingredient.management.service.js
const { Ingredient } = require("../../models/ingredients"); // Đảm bảo đường dẫn đúng tới file model

class IngredientManagementService {
    // 1. Get All + Search + Pagination
    async getAllIngredients(query) {
        // 1. Lấy thêm 'unit' từ query truyền lên
        const { keyword, unit, page = 1, limit = 10, sort = 'name' } = query;

        let filter = {};

        // 2. Tìm kiếm theo tên (Bạn đã có)
        if (keyword) {
            filter.name = { $regex: keyword, $options: "i" };
        }

        // 3. THÊM MỚI: Lọc theo đơn vị (Nếu có truyền unit lên thì mới lọc)
        if (unit) {
            filter.unit = { $regex: unit, $options: "i" };
        }

        const skip = (parseInt(page) - 1) * parseInt(limit);

        const ingredients = await Ingredient.find(filter)
            .sort({ [sort]: 1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Ingredient.countDocuments(filter);

        return {
            ingredients,
            total,
            page: parseInt(page),
            totalPages: Math.ceil(total / limit),
        };
    }

    // 2. Get Detail
    async getIngredientById(id) {
        const ingredient = await Ingredient.findById(id);
        if (!ingredient) throw new Error("Ingredient not found");
        return ingredient;
    }

    // 3. Create
    async createIngredient(data) {
        // Check trùng tên
        const existing = await Ingredient.findOne({ name: data.name });
        if (existing) throw new Error("Ingredient name already exists");

        const newIngredient = new Ingredient({
            name: data.name,
            ImageUrl: data.ImageUrl || "", // Lưu ý Model bạn đặt là ImageUrl viết hoa chữ I
            calories_per_unit: data.calories_per_unit,
            protein: data.protein || 0,
            carbs: data.carbs || 0,
            fats: data.fats || 0,
            description: data.description || "",
            unit: data.unit
        });

        return await newIngredient.save();
    }

    // 4. Update
    async updateIngredient(id, data) {
        const ingredient = await Ingredient.findById(id);
        if (!ingredient) throw new Error("Ingredient not found");

        // Nếu đổi tên, phải check xem tên mới có trùng với món khác không
        if (data.name && data.name !== ingredient.name) {
            const duplicate = await Ingredient.findOne({ name: data.name });
            if (duplicate) throw new Error("Ingredient name already exists");
        }

        // Cập nhật dữ liệu
        Object.assign(ingredient, data);

        return await ingredient.save();
    }

    // 5. Delete (Xóa cứng - Xóa hẳn khỏi DB vì nguyên liệu rác không cần giữ)
    async deleteIngredient(id) {
        const ingredient = await Ingredient.findByIdAndDelete(id);
        if (!ingredient) throw new Error("Ingredient not found");
        return ingredient;
    }
}

module.exports = new IngredientManagementService();