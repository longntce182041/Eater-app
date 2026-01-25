const User = require("../../models/User");

async function createUser(data) {
  const user = new User(data);
  return user.save();
}

async function findByEmail(email) {
  return User.findOne({ email: email.toLowerCase().trim() });
}

async function findById(id) {
  return User.findById(id);
}

async function findByEmailVerificationToken(token) {
  return User.findOne({
    emailVerificationToken: token,
    emailVerificationTokenExpires: { $gt: new Date() },
  });
}

async function findByPasswordResetToken(token) {
  return User.findOne({
    passwordResetToken: token,
    passwordResetTokenExpires: { $gt: new Date() },
  });
}

async function findByPasswordResetOtp(otp) {
  return User.findOne({
    passwordResetOtp: otp,
    passwordResetOtpExpires: { $gt: new Date() },
  });
}

async function updateUser(userId, updateData) {
  return User.findByIdAndUpdate(userId, updateData, { new: true });
}

async function updateUserByEmail(email, updateData) {
  return User.findOneAndUpdate({ email: email.toLowerCase().trim() }, updateData, {
    new: true,
  });
}

// Additional methods for admin/user management, deactivation, etc.

module.exports = {
  createUser,
  findByEmail,
  findById,
  findByEmailVerificationToken,
  findByPasswordResetToken,
  findByPasswordResetOtp,
  updateUser,
  updateUserByEmail,
};
