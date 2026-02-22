const express = require("express");
const router = express.Router();
const recipeController = require("../controllers/recipe.management.controller");

// Middleware bảo vệ (Auth)
// const { protect, authorize } = require("../../middleware/auth.middleware");

// GET List & Search
router.get("/", recipeController.getRecipes);

// GET Detail
router.get("/:id", recipeController.getRecipeDetail);

// CREATE
router.post("/create", recipeController.createRecipe);
// (Lưu ý: Nếu bạn vẫn muốn dùng path /create thì sửa thành router.post("/create", ...) nhé)

// UPDATE
router.put("/update/:id", recipeController.updateRecipe);
// (Nếu dùng path update cũ: router.put("/update/:id", ...))

// DELETE
router.delete("/delete/:id", recipeController.deleteRecipe);
// (Nếu dùng path delete cũ: router.delete("/delete/:id", ...))

module.exports = router;