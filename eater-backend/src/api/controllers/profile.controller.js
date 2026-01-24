const profileService = require("../services/profile.service");

/**
 * @controller Get user profile
 * @desc Retrieve the current user's profile information
 * @param {Request} req - Express request object with user info in req.user
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function getProfile(req, res, next) {
    try {
        const userId = req.user.sub; // From JWT token
        const result = await profileService.getProfile(userId);

        return res.status(200).json({
            status: "success",
            message: "Profile retrieved successfully",
            data: result.profile,
        });
    } catch (err) {
        return next(err);
    }
}

/**
 * @controller Create user profile
 * @desc Create a new profile for the current user (typically after registration)
 * @param {Request} req - Express request object with profile data in req.body
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function createProfile(req, res, next) {
    try {
        const userId = req.user.sub; // From JWT token
        const result = await profileService.createProfile(userId, req.body);

        return res.status(201).json({
            status: "success",
            message: result.message,
            data: result.profile,
        });
    } catch (err) {
        return next(err);
    }
}

/**
 * @controller Update user profile
 * @desc Update the current user's profile information
 * @param {Request} req - Express request object with updated profile data in req.body
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function updateProfile(req, res, next) {
    try {
        const userId = req.user.sub; // From JWT token
        const result = await profileService.updateProfile(userId, req.body);

        return res.status(200).json({
            status: "success",
            message: result.message,
            data: result.profile,
        });
    } catch (err) {
        return next(err);
    }
}

module.exports = {
    getProfile,
    createProfile,
    updateProfile,
};
