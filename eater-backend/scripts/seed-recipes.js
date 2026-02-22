/**
 * Recipe Database Seed Script
 *
 * This script populates the MongoDB database with sample recipes,
 * including nutrition data, diet types, ingredients, and associations.
 *
 * Run: node scripts/seed-recipes.js
 */

const mongoose = require("mongoose");
const { Recipe } = require("../src/models/Recipe");
const { RecipeNutrition } = require("../src/models/recipe_nutrion");
const { DietType } = require("../src/models/diet_types");
const { Ingredient } = require("../src/models/ingredients");
const { RecipeDietType } = require("../src/models/recipe_diet_type");
const { RecipesIngredient } = require("../src/models/recipes_ingredient");

// MongoDB connection
const MONGODB_URI =
  process.env.MONGODB_URI ||
  "mongodb://127.0.0.1:27017/ai_healthy_meal_planner";

// Sample Diet Types
const dietTypes = [
  {
    name: "balanced",
    carb_ratio: 40,
    protein_ratio: 30,
    fat_ratio: 30,
    description: "A balanced diet with moderate portions of all macronutrients",
    source: "General nutrition guidelines",
  },
  {
    name: "low_carb",
    carb_ratio: 20,
    protein_ratio: 40,
    fat_ratio: 40,
    description: "Low carbohydrate diet for weight management",
    source: "Low-carb diet principles",
  },
  {
    name: "high_protein",
    carb_ratio: 30,
    protein_ratio: 45,
    fat_ratio: 25,
    description: "High protein diet for muscle building",
    source: "Athletic nutrition guidelines",
  },
  {
    name: "low_fat",
    carb_ratio: 50,
    protein_ratio: 30,
    fat_ratio: 20,
    description: "Low fat diet for heart health",
    source: "Heart-healthy eating guidelines",
  },
  {
    name: "vegetarian",
    carb_ratio: 45,
    protein_ratio: 25,
    fat_ratio: 30,
    description: "Plant-based diet excluding meat",
    source: "Vegetarian nutrition guidelines",
  },
  {
    name: "vegan",
    carb_ratio: 50,
    protein_ratio: 20,
    fat_ratio: 30,
    description: "Plant-based diet excluding all animal products",
    source: "Vegan nutrition guidelines",
  },
];

// Sample Ingredients
const ingredients = [
  {
    name: "Chicken Breast",
    calories_per_unit: 165,
    protein: 31,
    carbs: 0,
    fats: 3.6,
    unit: "100g",
    description: "Lean protein source",
  },
  {
    name: "Brown Rice",
    calories_per_unit: 112,
    protein: 2.6,
    carbs: 24,
    fats: 0.9,
    unit: "100g",
    description: "Whole grain carbohydrate",
  },
  {
    name: "Broccoli",
    calories_per_unit: 34,
    protein: 2.8,
    carbs: 7,
    fats: 0.4,
    unit: "100g",
    description: "Nutrient-rich vegetable",
  },
  {
    name: "Olive Oil",
    calories_per_unit: 884,
    protein: 0,
    carbs: 0,
    fats: 100,
    unit: "100ml",
    description: "Healthy fat source",
  },
  {
    name: "Salmon",
    calories_per_unit: 208,
    protein: 20,
    carbs: 0,
    fats: 13,
    unit: "100g",
    description: "Omega-3 rich fish",
  },
  {
    name: "Sweet Potato",
    calories_per_unit: 86,
    protein: 1.6,
    carbs: 20,
    fats: 0.1,
    unit: "100g",
    description: "Complex carbohydrate",
  },
  {
    name: "Spinach",
    calories_per_unit: 23,
    protein: 2.9,
    carbs: 3.6,
    fats: 0.4,
    unit: "100g",
    description: "Iron-rich leafy green",
  },
  {
    name: "Eggs",
    calories_per_unit: 155,
    protein: 13,
    carbs: 1.1,
    fats: 11,
    unit: "100g",
    description: "Complete protein source",
  },
  {
    name: "Quinoa",
    calories_per_unit: 120,
    protein: 4.4,
    carbs: 21,
    fats: 1.9,
    unit: "100g",
    description: "Complete plant protein",
  },
  {
    name: "Tofu",
    calories_per_unit: 76,
    protein: 8,
    carbs: 1.9,
    fats: 4.8,
    unit: "100g",
    description: "Plant-based protein",
  },
  {
    name: "Almonds",
    calories_per_unit: 579,
    protein: 21,
    carbs: 22,
    fats: 50,
    unit: "100g",
    description: "Healthy nuts",
  },
  {
    name: "Greek Yogurt",
    calories_per_unit: 59,
    protein: 10,
    carbs: 3.6,
    fats: 0.4,
    unit: "100g",
    description: "High-protein dairy",
  },
  {
    name: "Avocado",
    calories_per_unit: 160,
    protein: 2,
    carbs: 8.5,
    fats: 15,
    unit: "100g",
    description: "Healthy fats",
  },
  {
    name: "Oats",
    calories_per_unit: 389,
    protein: 17,
    carbs: 66,
    fats: 7,
    unit: "100g",
    description: "Whole grain",
  },
  {
    name: "Lentils",
    calories_per_unit: 116,
    protein: 9,
    carbs: 20,
    fats: 0.4,
    unit: "100g",
    description: "Plant protein and fiber",
  },
];

// Sample Recipes
const recipes = [
  {
    name: "Grilled Chicken with Brown Rice",
    description:
      "Lean grilled chicken breast served with brown rice and steamed broccoli",
    imageUrl: "https://example.com/chicken-rice.jpg",
    cookingTime: 30,
    baseServings: 1, // Number of servings (not grams)
    status: "published",
    // Nutrition per serving
    nutrition: { calories: 450, protein: 42, fat: 8, carbohydrates: 48 },
    dietTypes: ["balanced", "high_protein", "low_fat"],
    ingredients: [
      { name: "Chicken Breast", base_quantity: "150", unit: "g" },
      { name: "Brown Rice", base_quantity: "100", unit: "g" },
      { name: "Broccoli", base_quantity: "100", unit: "g" },
      { name: "Olive Oil", base_quantity: "10", unit: "ml" },
    ],
  },
  {
    name: "Baked Salmon with Sweet Potato",
    description: "Omega-3 rich salmon with roasted sweet potato and spinach",
    imageUrl: "https://example.com/salmon-sweetpotato.jpg",
    cookingTime: 35,
    baseServings: 1,
    status: "published",
    nutrition: { calories: 520, protein: 38, fat: 20, carbohydrates: 45 },
    dietTypes: ["balanced", "low_carb"],
    ingredients: [
      { name: "Salmon", base_quantity: "150", unit: "g" },
      { name: "Sweet Potato", base_quantity: "200", unit: "g" },
      { name: "Spinach", base_quantity: "100", unit: "g" },
      { name: "Olive Oil", base_quantity: "15", unit: "ml" },
    ],
  },
  {
    name: "Quinoa Buddha Bowl",
    description:
      "Nutrient-packed quinoa bowl with tofu, avocado, and mixed vegetables",
    imageUrl: "https://example.com/quinoa-bowl.jpg",
    cookingTime: 25,
    baseServings: 1,
    status: "published",
    nutrition: { calories: 480, protein: 22, fat: 18, carbohydrates: 58 },
    dietTypes: ["vegetarian", "vegan", "balanced"],
    ingredients: [
      { name: "Quinoa", base_quantity: "100", unit: "g" },
      { name: "Tofu", base_quantity: "150", unit: "g" },
      { name: "Avocado", base_quantity: "50", unit: "g" },
      { name: "Spinach", base_quantity: "80", unit: "g" },
      { name: "Broccoli", base_quantity: "80", unit: "g" },
    ],
  },
  {
    name: "Protein Power Breakfast",
    description: "Scrambled eggs with oats and Greek yogurt",
    imageUrl: "https://example.com/protein-breakfast.jpg",
    cookingTime: 15,
    baseServings: 1,
    status: "published",
    nutrition: { calories: 420, protein: 32, fat: 14, carbohydrates: 42 },
    dietTypes: ["high_protein", "balanced"],
    ingredients: [
      { name: "Eggs", base_quantity: "150", unit: "g" },
      { name: "Oats", base_quantity: "50", unit: "g" },
      { name: "Greek Yogurt", base_quantity: "100", unit: "g" },
      { name: "Almonds", base_quantity: "20", unit: "g" },
    ],
  },
  {
    name: "Lentil Curry with Quinoa",
    description: "Spiced lentil curry served over quinoa",
    imageUrl: "https://example.com/lentil-curry.jpg",
    cookingTime: 40,
    baseServings: 1,
    status: "published",
    nutrition: { calories: 380, protein: 18, fat: 8, carbohydrates: 62 },
    dietTypes: ["vegan", "vegetarian", "low_fat"],
    ingredients: [
      { name: "Lentils", base_quantity: "150", unit: "g" },
      { name: "Quinoa", base_quantity: "80", unit: "g" },
      { name: "Spinach", base_quantity: "50", unit: "g" },
      { name: "Olive Oil", base_quantity: "10", unit: "ml" },
    ],
  },
  {
    name: "Keto Chicken Avocado Salad",
    description: "Low-carb chicken salad with avocado and olive oil dressing",
    imageUrl: "https://example.com/keto-salad.jpg",
    cookingTime: 20,
    baseServings: 1,
    status: "published",
    nutrition: { calories: 480, protein: 38, fat: 32, carbohydrates: 12 },
    dietTypes: ["low_carb", "high_protein"],
    ingredients: [
      { name: "Chicken Breast", base_quantity: "150", unit: "g" },
      { name: "Avocado", base_quantity: "100", unit: "g" },
      { name: "Spinach", base_quantity: "100", unit: "g" },
      { name: "Olive Oil", base_quantity: "20", unit: "ml" },
    ],
  },
  {
    name: "Mediterranean Salmon Bowl",
    description: "Grilled salmon with quinoa, olives, and feta cheese",
    imageUrl: "https://example.com/med-salmon.jpg",
    cookingTime: 30,
    baseServings: 1,
    status: "published",
    nutrition: { calories: 540, protein: 42, fat: 24, carbohydrates: 38 },
    dietTypes: ["balanced", "high_protein"],
    ingredients: [
      { name: "Salmon", base_quantity: "150", unit: "g" },
      { name: "Quinoa", base_quantity: "100", unit: "g" },
      { name: "Spinach", base_quantity: "80", unit: "g" },
      { name: "Olive Oil", base_quantity: "15", unit: "ml" },
    ],
  },
  {
    name: "Tofu Stir-Fry with Brown Rice",
    description: "Crispy tofu with mixed vegetables over brown rice",
    imageUrl: "https://example.com/tofu-stirfry.jpg",
    cookingTime: 25,
    baseServings: 1,
    status: "published",
    nutrition: { calories: 420, protein: 24, fat: 16, carbohydrates: 48 },
    dietTypes: ["vegan", "vegetarian", "balanced"],
    ingredients: [
      { name: "Tofu", base_quantity: "200", unit: "g" },
      { name: "Brown Rice", base_quantity: "100", unit: "g" },
      { name: "Broccoli", base_quantity: "100", unit: "g" },
      { name: "Olive Oil", base_quantity: "10", unit: "ml" },
    ],
  },
];

async function seedDatabase() {
  try {
    console.log("🌱 Starting database seed...\n");

    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI);
    console.log("✅ Connected to MongoDB:", MONGODB_URI);

    // Clear existing data (optional - comment out if you want to preserve existing data)
    console.log("\n🗑️  Clearing existing data...");
    await Recipe.deleteMany({});
    await RecipeNutrition.deleteMany({});
    await DietType.deleteMany({});
    await Ingredient.deleteMany({});
    await RecipeDietType.deleteMany({});
    await RecipesIngredient.deleteMany({});
    console.log("✅ Existing data cleared");

    // Create Diet Types
    console.log("\n📋 Creating diet types...");
    const dietTypeMap = {};
    for (const dietTypeData of dietTypes) {
      const dietType = await DietType.create({
        ...dietTypeData,
        Diet_TypeId: new mongoose.Types.ObjectId(),
      });
      dietTypeMap[dietType.name] = dietType._id;
      console.log(`   ✓ Created: ${dietType.name}`);
    }

    // Create Ingredients
    console.log("\n🥗 Creating ingredients...");
    const ingredientMap = {};
    for (const ingredientData of ingredients) {
      const ingredient = await Ingredient.create(ingredientData);
      ingredientMap[ingredient.name] = ingredient._id;
      console.log(`   ✓ Created: ${ingredient.name}`);
    }

    // Create Recipes with all relationships
    console.log("\n🍽️  Creating recipes with nutrition and associations...");
    let recipeCount = 0;

    for (const recipeData of recipes) {
      // Create recipe
      const recipe = await Recipe.create({
        name: recipeData.name,
        description: recipeData.description,
        imageUrl: recipeData.imageUrl,
        cookingTime: recipeData.cookingTime,
        baseServings: recipeData.baseServings,
        status: recipeData.status,
      });
      recipeCount++;

      // Create nutrition
      await RecipeNutrition.create({
        recipeId: recipe._id,
        ...recipeData.nutrition,
      });

      // Create diet type associations
      for (const dietTypeName of recipeData.dietTypes) {
        if (dietTypeMap[dietTypeName]) {
          await RecipeDietType.create({
            recipeId: recipe._id,
            dietTypeId: dietTypeMap[dietTypeName],
          });
        }
      }

      // Create ingredient associations
      for (const ingredientData of recipeData.ingredients) {
        if (ingredientMap[ingredientData.name]) {
          await RecipesIngredient.create({
            recipeId: recipe._id,
            ingredientId: ingredientMap[ingredientData.name],
            base_quantity: ingredientData.base_quantity,
            unit: ingredientData.unit,
          });
        }
      }

      console.log(`   ✓ ${recipeCount}. ${recipe.name}`);
      console.log(
        `      - Nutrition: ${recipeData.nutrition.calories} cal, ${recipeData.nutrition.protein}g protein`,
      );
      console.log(`      - Diet types: ${recipeData.dietTypes.join(", ")}`);
      console.log(`      - Ingredients: ${recipeData.ingredients.length}`);
    }

    // Summary
    console.log("\n═══════════════════════════════════════════════════════");
    console.log("✅ Database seeding complete!");
    console.log("═══════════════════════════════════════════════════════");
    console.log(`📊 Summary:`);
    console.log(`   - ${Object.keys(dietTypeMap).length} diet types`);
    console.log(`   - ${Object.keys(ingredientMap).length} ingredients`);
    console.log(`   - ${recipeCount} published recipes`);
    console.log(`   - ${recipeCount} nutrition entries`);
    console.log("═══════════════════════════════════════════════════════\n");
  } catch (error) {
    console.error("❌ Error seeding database:", error);
    throw error;
  } finally {
    await mongoose.connection.close();
    console.log("🔌 MongoDB connection closed");
  }
}

// Run the seed script
if (require.main === module) {
  seedDatabase()
    .then(() => {
      console.log("✅ Seed script completed successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("❌ Seed script failed:", error);
      process.exit(1);
    });
}

module.exports = { seedDatabase };
