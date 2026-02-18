const request = require('supertest');
const app = require('../../app');
const db = require('./db-handler');
const User = require('../../src/models/user');

beforeAll(async () => await db.connect());
afterEach(async () => await db.clearDatabase());
afterAll(async () => await db.closeDatabase());

describe('User Management Tests', () => {

    // --- CREATE USER ---
    it('POST /api/users/create - Should create a new user', async () => {
        const res = await request(app).post('/api/users/create').send({
            email: 'newuser@test.com',
            password: 'password123',
            role: 'user'
        });

        expect(res.statusCode).toBe(201);
        expect(res.body.message).toMatch(/Create User successfully/i);

        // Kiểm tra xem đã lưu vào DB chưa
        const userInDb = await User.findOne({ email: 'newuser@test.com' });
        expect(userInDb).toBeTruthy();
    });

    // --- SEARCH / FILTER ---
    it('GET /api/users - Should search and filter users', async () => {
        // Tạo sẵn 2 user
        await User.create({ email: 'alice@test.com', passwordHash: '123', role: 'user' });
        await User.create({ email: 'bob@test.com', passwordHash: '123', role: 'nutritionist' });

        // Test Search: Tìm 'alice'
        const resSearch = await request(app).get('/api/users?keyword=alice');
        expect(resSearch.body.data.users.length).toBe(1);
        expect(resSearch.body.data.users[0].email).toBe('alice@test.com');

        // Test Filter: Tìm role 'nutritionist'
        const resFilter = await request(app).get('/api/users?role=nutritionist');
        expect(resFilter.body.data.users.length).toBe(1);
        expect(resFilter.body.data.users[0].email).toBe('bob@test.com');
    });

    // --- UPDATE USER ---
    it('PUT /api/users/update/:id - Should update user info', async () => {
        const user = await User.create({ email: 'update@test.com', passwordHash: '123', role: 'user' });

        const res = await request(app).put(`/api/users/update/${user._id}`).send({
            role: 'admin'
        });

        expect(res.statusCode).toBe(200);

        const updatedUser = await User.findById(user._id);
        expect(updatedUser.role).toBe('admin');
    });

    /// --- DELETE USER ---
    it('DELETE /api/users/delete/:id - Should soft delete (deactivate) user', async () => {
        // 1. Tạo user cần xóa
        const user = await User.create({
            email: 'delete-test@gmail.com', // Đặt email rõ ràng để tránh trùng
            passwordHash: 'hashed123',
            role: 'user',
            isActive: true
        });

        // 2. Gọi API Delete
        const res = await request(app).delete(`/api/users/delete/${user._id}`);

        // --- DEBUG: In lỗi ra nếu không phải 200 ---
        if (res.statusCode !== 200) {
            console.error("Lỗi DELETE User:", res.body); // Xem nó báo lỗi gì?
        }

        expect(res.statusCode).toBe(200);

        // 3. Kiểm tra DB (Soft Delete = isActive false)
        const deletedUser = await User.findById(user._id);
        expect(deletedUser.isActive).toBe(false);
    });
});