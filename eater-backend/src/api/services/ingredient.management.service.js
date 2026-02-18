// src/api/services/ingredient.management.service.js
const { Ingredient } = require("../../models/ingredients"); // Đảm bảo đường dẫn đúng tới file model
const { IngredientMicronutrientValues } = require("../../models/ingredient_micronutrient_values");

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

        // Load linked micronutrient values from join table and populate micronutrient details
        const micronValues = await IngredientMicronutrientValues.find({ ingredientId: id }).populate('micronutrientId', 'name unit');
        const micronutrients = micronValues.map(mv => ({
            micronutrientId: mv.micronutrientId?._id || mv.micronutrientId,
            name: mv.micronutrientId?.name || null,
            unit: mv.micronutrientId?.unit || null,
            amount: mv.amount,
        }));

        const result = ingredient.toObject();
        result.micronutrients = micronutrients;
        return result;
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

        const saved = await newIngredient.save();

        // Nếu có micronutrients kèm theo, tạo các bản ghi trong bảng phụ
        if (data.micronutrients && Array.isArray(data.micronutrients) && data.micronutrients.length) {
            const docs = data.micronutrients.map(m => ({
                ingredientId: saved._id,
                micronutrientId: m.micronutrientId,
                amount: Number(m.amount)
            }));
            await IngredientMicronutrientValues.insertMany(docs);
        }

        return saved;
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

        const updated = await ingredient.save();

        // Nếu gửi lên danh sách micronutrients, cập nhật bảng phụ tương ứng
        if (data.micronutrients !== undefined) {
            // Xóa các bản ghi cũ cho ingredient này
            await IngredientMicronutrientValues.deleteMany({ ingredientId: updated._id });

            if (Array.isArray(data.micronutrients) && data.micronutrients.length) {
                const docs = data.micronutrients.map(m => ({
                    ingredientId: updated._id,
                    micronutrientId: m.micronutrientId,
                    amount: Number(m.amount)
                }));
                await IngredientMicronutrientValues.insertMany(docs);
            }
        }

        return updated;
    }

    // 5. Delete (Xóa cứng - Xóa hẳn khỏi DB vì nguyên liệu rác không cần giữ)
    async deleteIngredient(id) {
        const ingredient = await Ingredient.findByIdAndDelete(id);
        if (!ingredient) throw new Error("Ingredient not found");
        return ingredient;
    }
}

module.exports = new IngredientManagementService();