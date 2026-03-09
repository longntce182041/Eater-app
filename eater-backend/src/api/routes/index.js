const express = require("express");

const authUserRoutes = require("./auth.routes");
const profileRoutes = require("./profile.routes");
// const usersRoutes = require("./users.routes");
// const preferencesRoutes = require("./preferences.routes");
// const mealPlansRoutes = require("./mealPlans.routes");
const recipesRoutes = require("./recipe.management.routes");
const reviewsRoutes = require("./review.management.routes");
//const adminRoutes = require("./admin.routes");
const authAdminRoutes = require("./auth.admin.routes");
const userRoutes = require("./user.management.routes");
const ingredientRoutes = require("./ingredient.management.routes");
const healthRoutes = require("./health.routes");
const micronutrientRoutes = require("./micronutrient.management.routes");
const adminBackupRoutes = require("./admin.backup.routes");
const aiRoutes = require("./ai.routes");

const router = express.Router();
router.use("/auth/user", authUserRoutes);
router.use("/auth/admin", authAdminRoutes);
router.use("/users", userRoutes);
router.use("/profile", profileRoutes);
router.use("/ingredients", ingredientRoutes);
router.use("/health", healthRoutes);
router.use("/ai", aiRoutes);
// router.use("/preferences", preferencesRoutes);
// router.use("/meal-plans", mealPlansRoutes);
router.use("/recipes", recipesRoutes);
router.use("/reviews", reviewsRoutes);
// router.use("/admin", adminRoutes);
router.use("/micronutrients", micronutrientRoutes);
router.use("/admin", adminBackupRoutes);

module.exports = router;
