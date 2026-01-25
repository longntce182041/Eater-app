const User = require("../../models/User_Profile");

async function createUser(data) {
  const user = new User(data);
  return user.save();
}

async function findByEmail(email) {
  return User.findOne({ email });
}

async function findById(id) {
  return User.findById(id);
}

// Additional methods for admin/user management, deactivation, etc.

module.exports = {
  createUser,
  findByEmail,
  findById,
};
