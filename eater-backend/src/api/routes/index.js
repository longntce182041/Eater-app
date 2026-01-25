const express = require("express");

const authRoutes = require("./auth.routes");
const profileRoutes = require("./profile.routes");
// const usersRoutes = require("./users.routes");
// const preferencesRoutes = require("./preferences.routes");
// const mealPlansRoutes = require("./mealPlans.routes");
// const recipesRoutes = require("./recipes.routes");
// const reviewsRoutes = require("./reviews.routes");
// const adminRoutes = require("./admin.routes");
const authRoutes = require("./auth.admin.routes");
const userRoutes = require("./user.management.routes");
const ingredientRoutes = require("./ingredient.management.routes");
const healthRoutes = require("./health.routes");

const router = express.Router();
router.use("/auth", authRoutes);
// router.use("/users", usersRoutes);
// router.use("/profile", profileRoutes);
// router.use("/preferences", preferencesRoutes);
// router.use("/meal-plans", mealPlansRoutes);
// router.use("/recipes", recipesRoutes);
// router.use("/reviews", reviewsRoutes);
// router.use("/admin", adminRoutes);

module.exports = router;
