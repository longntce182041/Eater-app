const { MealPlan } = require("../../models/meal_plans");
const { MealPlanItem } = require("../../models/meal_plan_item");
const { User_Profile } = require("../../models/User_Profile");
const { UserHealthMetrics } = require("../../models/user_heath_metrics");
const { DietaryReferences } = require("../../models/dietary_references");
const { Recipe } = require("../../models/Recipe");

/**
 * Get comprehensive home dashboard data for user
 * Includes: user profile, today's meals, daily nutrition summary, health goals
 */
async function getHomeDashboardData(userId) {
    try {
        // Fetch user profile
        const userProfile = await User_Profile.findOne({ userId }).lean();

        // Fetch user health metrics
        const healthMetrics = await UserHealthMetrics.findOne({ userId }).lean();

        // Fetch dietary references (daily targets)
        const dietaryRef = await DietaryReferences.findOne({ userId }).lean();

        // Fetch latest meal plan
        const latestMealPlan = await MealPlan.findOne({ userId })
            .sort({ createdAt: -1 })
            .lean();

        let todaysMeals = [];
        let todayNutrition = {
            calories: 0,
            protein: 0,
            carbohydrates: 0,
            fat: 0,
        };
        let mealCount = 0;

        if (latestMealPlan) {
            // Get today's meals (dayIndex = 0 for the first day of the plan)
            todaysMeals = await MealPlanItem.find({
                mealPlanId: latestMealPlan._id,
                dayIndex: 0, // First day of the meal plan
            })
                .populate("recipeId", "name imageUrl")
                .select(
                    "mealType servings calories protein carbohydrates fat recipeId userRating",
                )
                .lean();

            // Transform meals to include recipe info
            todaysMeals = todaysMeals.map((meal) => ({
                ...meal,
                recipeName: meal.recipeId?.name || "Unknown Recipe",
                recipeImageUrl: meal.recipeId?.imageUrl || null,
                recipeId: meal.recipeId?._id || meal.recipeId,
            }));

            // Calculate today's nutrition
            todaysMeals.forEach((meal) => {
                todayNutrition.calories += meal.calories || 0;
                todayNutrition.protein += meal.protein || 0;
                todayNutrition.carbohydrates += meal.carbohydrates || 0;
                todayNutrition.fat += meal.fat || 0;
            });

            mealCount = todaysMeals.length;
        }

        // Determine target daily calorie goal
        const targetCalories =
            dietaryRef?.daily_calories || healthMetrics?.tdee || 2000;
        const mealGoal = 3; // Default 3 meals per day

        return {
            success: true,
            userProfile,
            healthMetrics,
            dietaryReferences: dietaryRef,
            latestMealPlan: latestMealPlan
                ? {
                    id: latestMealPlan._id,
                    days: latestMealPlan.days,
                    createdAt: latestMealPlan.createdAt,
                }
                : null,
            todayOverview: {
                calories: {
                    consumed: Math.round(todayNutrition.calories),
                    target: targetCalories,
                    percentage: Math.round(
                        (todayNutrition.calories / targetCalories) * 100,
                    ),
                },
                meals: {
                    consumed: mealCount,
                    target: mealGoal,
                },
                macros: {
                    protein: Math.round(todayNutrition.protein),
                    carbohydrates: Math.round(todayNutrition.carbohydrates),
                    fat: Math.round(todayNutrition.fat),
                },
            },
            todaysMeals: todaysMeals.map((meal) => ({
                id: meal._id,
                mealType: meal.mealType,
                recipeName: meal.recipeName,
                recipeImageUrl: meal.recipeImageUrl,
                servings: meal.servings,
                calories: Math.round(meal.calories),
                protein: Math.round(meal.protein),
                carbohydrates: Math.round(meal.carbohydrates),
                fat: Math.round(meal.fat),
                userRating: meal.userRating,
            })),
        };
    } catch (error) {
        console.error("Error fetching home dashboard data:", error);
        throw new Error(`Failed to fetch home dashboard data: ${error.message}`);
    }
}

/**
 * Get upcoming meals for the next N days
 */
async function getUpcomingMeals(userId, days = 7) {
    try {
        const latestMealPlan = await MealPlan.findOne({ userId })
            .sort({ createdAt: -1 })
            .lean();

        if (!latestMealPlan) {
            return {
                success: true,
                mealPlan: null,
                upcomingMeals: [],
            };
        }

        // Get meals for the next N days
        let upcomingMeals = await MealPlanItem.find({
            mealPlanId: latestMealPlan._id,
            dayIndex: { $gte: 0, $lt: days },
        })
            .populate("recipeId", "name imageUrl")
            .select(
                "dayIndex mealType servings calories protein carbohydrates fat recipeId userRating",
            )
            .sort({ dayIndex: 1, mealType: 1 })
            .lean();

        // Transform meals to include recipe info
        upcomingMeals = upcomingMeals.map((meal) => ({
            ...meal,
            recipeName: meal.recipeId?.name || "Unknown Recipe",
            recipeImageUrl: meal.recipeId?.imageUrl || null,
            recipeId: meal.recipeId?._id || meal.recipeId,
        }));

        // Group meals by day
        const mealsByDay = {};
        upcomingMeals.forEach((meal) => {
            if (!mealsByDay[meal.dayIndex]) {
                mealsByDay[meal.dayIndex] = [];
            }
            mealsByDay[meal.dayIndex].push({
                id: meal._id,
                mealType: meal.mealType,
                recipeName: meal.recipeName,
                recipeImageUrl: meal.recipeImageUrl,
                servings: meal.servings,
                calories: Math.round(meal.calories),
                protein: Math.round(meal.protein),
                carbohydrates: Math.round(meal.carbohydrates),
                fat: Math.round(meal.fat),
                userRating: meal.userRating,
            });
        });

        return {
            success: true,
            mealPlan: {
                id: latestMealPlan._id,
                days: latestMealPlan.days,
                createdAt: latestMealPlan.createdAt,
            },
            upcomingMeals: mealsByDay,
        };
    } catch (error) {
        console.error("Error fetching upcoming meals:", error);
        throw new Error(`Failed to fetch upcoming meals: ${error.message}`);
    }
}

module.exports = {
    getHomeDashboardData,
    getUpcomingMeals,
};
