const profileRepository = require("../repositories/profile.repository");
const userRepository = require("../repositories/user.repository");
const { AppError } = require("../../utils/errors");

// Get user profile
async function getProfile(userId) {
    // Verify user exists
    const user = await userRepository.findById(userId);
    if (!user) {
        throw new AppError("User not found", 404);
    }

    // Get profile
    const profile = await profileRepository.getProfileByUserId(userId);
    if (!profile) {
        throw new AppError("User profile not found. Please complete your profile setup.", 404);
    }

    return {
        profile,
    };
}

// Create user profile (for new users)
async function createProfile(userId, profileData) {
    // Verify user exists
    const user = await userRepository.findById(userId);
    if (!user) {
        throw new AppError("User not found", 404);
    }

    // Check if profile already exists
    const existingProfile = await profileRepository.profileExists(userId);
    if (existingProfile) {
        throw new AppError("User profile already exists", 409);
    }

    // Create new profile
    const profile = await profileRepository.createProfile({
        userId,
        ...profileData,
    });

    return {
        message: "Profile created successfully",
        profile,
    };
}

// Update user profile
async function updateProfile(userId, updateData) {
    // Verify user exists
    const user = await userRepository.findById(userId);
    if (!user) {
        throw new AppError("User not found", 404);
    }

    // Check if profile exists
    const existingProfile = await profileRepository.profileExists(userId);
    if (!existingProfile) {
        throw new AppError("User profile not found. Please complete your profile setup first.", 404);
    }

    // Update profile
    const profile = await profileRepository.updateProfile(userId, updateData);

    return {
        message: "Profile updated successfully",
        profile,
    };
}

module.exports = {
    getProfile,
    createProfile,
    updateProfile,
};
