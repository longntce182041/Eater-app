const { User_Profile } = require("../../models/User_Profile");

// Get user profile by user ID
async function getProfileByUserId(userId) {
    return User_Profile.findOne({ userId }).populate("userId", "email role isActive isEmailVerified");
}

// Create user profile
async function createProfile(profileData) {
    const profile = new User_Profile(profileData);
    return profile.save();
}

// Update user profile
async function updateProfile(userId, updateData) {
    return User_Profile.findOneAndUpdate({ userId }, updateData, {
        new: true,
        runValidators: true,
    }).populate("userId", "email role isActive isEmailVerified");
}

// Check if profile exists
async function profileExists(userId) {
    return User_Profile.findOne({ userId });
}

// Delete user profile
async function deleteProfile(userId) {
    return User_Profile.findOneAndDelete({ userId });
}

module.exports = {
    getProfileByUserId,
    createProfile,
    updateProfile,
    profileExists,
    deleteProfile,
};
