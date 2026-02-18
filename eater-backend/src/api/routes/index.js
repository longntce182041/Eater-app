const express = require("express");

const authUserRoutes = require("./auth.routes");
const profileRoutes = require("./profile.routes");
// const usersRoutes = require("./users.routes");
// const preferencesRoutes = require("./preferences.routes");
// const mealPlansRoutes = require("./mealPlans.routes");
// const recipesRoutes = require("./recipes.routes");
// const reviewsRoutes = require("./reviews.routes");
// const adminRoutes = require("./admin.routes");
const authAdminRoutes = require("./auth.admin.routes");
const userRoutes = require("./user.management.routes");
const ingredientRoutes = require("./ingredient.management.routes");
<<<<<<< HEAD
const healthRoutes = require("./health.routes");
=======
const micronutrientRoutes = require("./micronutrient.management.routes");
const adminBackupRoutes = require("./admin.backup.routes");

>>>>>>> develop

const router = express.Router();
router.use("/auth/user", authUserRoutes);
router.use("/auth/admin", authAdminRoutes);
router.use("/users", userRoutes);
router.use("/profile", profileRoutes);
router.use("/ingredients", ingredientRoutes);
<<<<<<< HEAD
router.use("/health", healthRoutes);
// router.use("/preferences", preferencesRoutes);
// router.use("/meal-plans", mealPlansRoutes);
// router.use("/recipes", recipesRoutes);
// router.use("/reviews", reviewsRoutes);
// router.use("/admin", adminRoutes);
=======
router.use("/micronutrients", micronutrientRoutes);
router.use('/admin', adminBackupRoutes);

>>>>>>> develop

module.exports = router;
