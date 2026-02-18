const request = require('supertest');
const app = require('../../app'); // Trỏ đúng đường dẫn app.js
const db = require('./db-handler');
const User = require('../../src/models/User');
const bcrypt = require('bcryptjs');

// Cấu hình chạy trước và sau test
beforeAll(async () => await db.connect());
afterEach(async () => await db.clearDatabase());
afterAll(async () => await db.closeDatabase());

describe('Auth Integration Tests', () => {

    // Test case: Đăng nhập thành công
    it('POST /api/auth/admin/login - Should login successfully', async () => {
        // 1. Mã hóa mật khẩu trước khi lưu vào DB giả
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash('123456', salt);

        // 2. Tạo User với password đã mã hóa
        await User.create({
            email: 'admin@test.com',
            passwordHash: hashedPassword, // <-- Lưu cái đã mã hóa
            role: 'admin',
            isActive: true
        });

        // 2. Gọi API Login
        const res = await request(app).post('/api/auth/admin/login').send({
            email: 'admin@test.com',
            password: '123456'
        });

        // 3. Kiểm tra kết quả
        expect(res.statusCode).toBe(200);
        expect(res.body.success).toBe(true);
        expect(res.body.data).toHaveProperty('token'); // Phải có token trả về
    });

    // Test case: Sai mật khẩu
    it('POST /api/auth/admin/login - Should fail with wrong password', async () => {
        const hashedPassword = await bcrypt.hash('123456', 10);
        await User.create({ email: 'admin@test.com', passwordHash: hashedPassword, role: 'admin' });

        const res = await request(app).post('/api/auth/admin/login').send({
            email: 'admin@test.com',
            password: 'wrongpassword'
        });

        expect(res.statusCode).toBe(401); // Hoặc 400 tùy code của bạn
        expect(res.body.success).toBe(false);
    });
});