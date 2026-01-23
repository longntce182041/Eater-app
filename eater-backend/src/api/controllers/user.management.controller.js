const userService = require("../services/user.management.service");
const { validateCreateUser, validateUpdateUser } = require("../validators/user.management.validators");

class UserManagementController {
    // GET /api/users (List, Search, Filter)
    async getUsers(req, res) {
        try {
            const result = await userService.getAllUsers(req.query);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    // GET /api/users/:id (Detail)
    async getUserDetail(req, res) {
        try {
            const user = await userService.getUserById(req.params.id);
            res.json({ success: true, data: user });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    }

    // POST /api/users (Create)
    async createUser(req, res) {
        try {
            const { errors, isValid } = validateCreateUser(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const newUser = await userService.createUser(req.body);
            res.status(201).json({ success: true, message: "User created successfully", data: newUser });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // PUT /api/users/:id (Update)
    async updateUser(req, res) {
        try {
            const { errors, isValid } = validateUpdateUser(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const updatedUser = await userService.updateUser(req.params.id, req.body);
            res.json({ success: true, message: "User updated successfully", data: updatedUser });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // DELETE /api/users/:id (Soft Delete)
    async deleteUser(req, res) {
        try {
            await userService.softDeleteUser(req.params.id);
            res.json({ success: true, message: "User has been deactivated (Soft deleted)" });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }
}

module.exports = new UserManagementController();