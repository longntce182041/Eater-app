const request = require('supertest');
const app = require('../../app');
const db = require('./db-handler');
const { Ingredient } = require('../../src/models/ingredients'); // Chú ý cách import nếu dùng { Ingredient }

beforeAll(async () => await db.connect());
afterEach(async () => await db.clearDatabase());
afterAll(async () => await db.closeDatabase());

describe('Ingredient Management Tests', () => {

    // --- CREATE ---
    it('POST /api/ingredients/create - Should create ingredient', async () => {
        const res = await request(app).post('/api/ingredients/create').send({
            name: 'Beef',
            calories_per_unit: 250,
            unit: '100g',
            protein: 26,
            carbs: 0,
            fats: 15
        });

        expect(res.statusCode).toBe(201);
        const item = await Ingredient.findOne({ name: 'Beef' });
        expect(item).toBeTruthy();
    });
    // --- UPDATE (Thêm đoạn này vào) ---
    it('PUT /api/ingredients/update/:id - Should update ingredient', async () => {
        // 1. Tạo giả 1 nguyên liệu cũ
        const item = await Ingredient.create({
            name: 'Old Beef',
            calories_per_unit: 100,
            unit: '100g',
            protein: 10, carbs: 0, fats: 5
        });

        // 2. Gọi API Update đổi tên và calo
        const res = await request(app).put(`/api/ingredients/update/${item._id}`).send({
            name: 'New Beef',
            calories_per_unit: 500
        });

        // 3. Kiểm tra kết quả
        expect(res.statusCode).toBe(200);

        // 4. Kiểm tra trong DB xem đã đổi chưa
        const updatedItem = await Ingredient.findById(item._id);
        expect(updatedItem.name).toBe('New Beef');
        expect(updatedItem.calories_per_unit).toBe(500);
    });

    // --- GET LIST ---
    it('GET /api/ingredients - Should get list', async () => {
        await Ingredient.create({ name: 'Chicken', calories_per_unit: 100, unit: 'g' });

        const res = await request(app).get('/api/ingredients');
        expect(res.statusCode).toBe(200);
        expect(res.body.data.ingredients.length).toBeGreaterThan(0);
    });

    // --- DELETE (Hard Delete) ---
    it('DELETE /api/ingredients/delete/:id - Should hard delete ingredient', async () => {
        const item = await Ingredient.create({ name: 'Trash', calories_per_unit: 0, unit: 'g' });

        const res = await request(app).delete(`/api/ingredients/delete/${item._id}`);
        expect(res.statusCode).toBe(200);

        // Kiểm tra DB: Phải mất luôn (Hard Delete)
        const check = await Ingredient.findById(item._id);
        expect(check).toBeNull();
    });
});