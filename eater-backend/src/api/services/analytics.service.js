const User = require("../../models/User");
const UserPro = require("../../models/userPro");
const { Recipe } = require("../../models/Recipe");
const { FavoriteRecipe } = require("../../models/favorite_recipes");
const { RecipesReview } = require("../../models/recipes_review");
const Consultation = require("../../models/Consultation");
const { ChatMessage } = require("../../models/chat_message");

const PRO_MONTHLY_PRICE = Number(
    process.env.PRO_MONTHLY_PRICE || process.env.PRO_PLAN_PRICE || 49000,
);
const PRO_YEARLY_PRICE = Number(
    process.env.PRO_YEARLY_PRICE || PRO_MONTHLY_PRICE * 12 * 0.8,
);

class AnalyticsService {
    async getOverview() {
        const now = new Date();
        const thirtyDaysAgo = new Date(now);
        thirtyDaysAgo.setDate(now.getDate() - 30);

        const [
            totalUsers,
            newUsersLast30Days,
            totalRecipes,
            publishedRecipes,
            totalConsultations,
            consultationsLast30Days,
            chatMessagesLast30Days,
            activeProUsers,
            totalTransactions,
            recipeRatings,
            topRecipesByFavorites,
            monthlyRegistrationTrend,
            monthlyRevenueTrend,
            revenueSummary,
            revenueByPlan,
        ] = await Promise.all([
            User.countDocuments({ role: "user" }),
            User.countDocuments({ role: "user", createdAt: { $gte: thirtyDaysAgo } }),
            Recipe.countDocuments({}),
            Recipe.countDocuments({ $or: [{ status: "published" }, { isPublished: true }] }),
            Consultation.countDocuments({}),
            Consultation.countDocuments({ createdAt: { $gte: thirtyDaysAgo } }),
            ChatMessage.countDocuments({ createdAt: { $gte: thirtyDaysAgo } }),
            UserPro.countDocuments({ isActive: true, endDate: { $gte: now } }),
            UserPro.countDocuments({}),
            RecipesReview.aggregate([
                {
                    $group: {
                        _id: null,
                        avgRating: { $avg: "$rating" },
                        totalReviews: { $sum: 1 },
                    },
                },
            ]),
            FavoriteRecipe.aggregate([
                { $group: { _id: "$recipeId", favorites: { $sum: 1 } } },
                { $sort: { favorites: -1 } },
                { $limit: 5 },
                {
                    $lookup: {
                        from: "recipes",
                        localField: "_id",
                        foreignField: "_id",
                        as: "recipe",
                    },
                },
                {
                    $project: {
                        _id: 0,
                        recipeId: "$_id",
                        favorites: 1,
                        recipe: { $arrayElemAt: ["$recipe", 0] },
                    },
                },
            ]),
            User.aggregate([
                {
                    $match: {
                        role: "user",
                        createdAt: {
                            $gte: new Date(new Date().setMonth(new Date().getMonth() - 5)),
                        },
                    },
                },
                {
                    $group: {
                        _id: {
                            year: { $year: "$createdAt" },
                            month: { $month: "$createdAt" },
                        },
                        count: { $sum: 1 },
                    },
                },
                { $sort: { "_id.year": 1, "_id.month": 1 } },
            ]),
            UserPro.aggregate([
                {
                    $match: {
                        createdAt: {
                            $gte: new Date(new Date().setMonth(new Date().getMonth() - 5)),
                        },
                    },
                },
                {
                    $group: {
                        _id: {
                            year: { $year: "$createdAt" },
                            month: { $month: "$createdAt" },
                        },
                        revenue: {
                            $sum: {
                                $ifNull: ["$plan_amount", 0],
                            },
                        },
                    },
                },
                { $sort: { "_id.year": 1, "_id.month": 1 } },
            ]),
            UserPro.aggregate([
                {
                    $group: {
                        _id: null,
                        totalRevenue: {
                            $sum: {
                                $ifNull: [
                                    "$plan_amount",
                                    {
                                        $cond: [
                                            { $eq: ["$plan_type", "yearly"] },
                                            PRO_YEARLY_PRICE,
                                            PRO_MONTHLY_PRICE,
                                        ],
                                    },
                                ],
                            },
                        },
                        avgTransactionValue: {
                            $avg: {
                                $ifNull: [
                                    "$plan_amount",
                                    {
                                        $cond: [
                                            { $eq: ["$plan_type", "yearly"] },
                                            PRO_YEARLY_PRICE,
                                            PRO_MONTHLY_PRICE,
                                        ],
                                    },
                                ],
                            },
                        },
                    },
                },
            ]),
            UserPro.aggregate([
                {
                    $group: {
                        _id: "$plan_type",
                        revenue: {
                            $sum: {
                                $ifNull: [
                                    "$plan_amount",
                                    {
                                        $cond: [
                                            { $eq: ["$plan_type", "yearly"] },
                                            PRO_YEARLY_PRICE,
                                            PRO_MONTHLY_PRICE,
                                        ],
                                    },
                                ],
                            },
                        },
                        transactions: { $sum: 1 },
                    },
                },
            ]),
        ]);

        const ratingSummary = recipeRatings?.[0] || { avgRating: 0, totalReviews: 0 };
        const revenueStats = revenueSummary?.[0] || {
            totalRevenue: 0,
            avgTransactionValue: 0,
        };

        const recipeIds = topRecipesByFavorites.map((item) => item.recipeId);
        const reviewCountsByRecipe = await RecipesReview.aggregate([
            { $match: { recipeId: { $in: recipeIds } } },
            {
                $group: {
                    _id: "$recipeId",
                    reviewCount: { $sum: 1 },
                    avgRating: { $avg: "$rating" },
                },
            },
        ]);

        const reviewMap = reviewCountsByRecipe.reduce((acc, item) => {
            acc[String(item._id)] = {
                reviewCount: item.reviewCount,
                avgRating: Number(item.avgRating || 0),
            };
            return acc;
        }, {});

        const topRecipes = topRecipesByFavorites.map((item) => {
            const recipeId = String(item.recipeId);
            return {
                recipeId,
                name: item.recipe?.name || "Unknown recipe",
                favorites: item.favorites,
                reviewCount: reviewMap[recipeId]?.reviewCount || 0,
                avgRating: Number((reviewMap[recipeId]?.avgRating || item.recipe?.rating || 0).toFixed(2)),
            };
        });

        return {
            userActivity: {
                totalUsers,
                newUsersLast30Days,
                activeProUsers,
                totalConsultations,
                consultationsLast30Days,
                chatMessagesLast30Days,
            },
            recipePopularity: {
                totalRecipes,
                publishedRecipes,
                totalReviews: ratingSummary.totalReviews || 0,
                avgRating: Number((ratingSummary.avgRating || 0).toFixed(2)),
                topRecipes,
            },
            financialPerformance: {
                totalRevenue: Number(revenueStats.totalRevenue || 0),
                avgTransactionValue: Number((revenueStats.avgTransactionValue || 0).toFixed(0)),
                totalTransactions,
                revenueByPlan: revenueByPlan.map((item) => ({
                    planType: item._id || "unknown",
                    revenue: Number(item.revenue || 0),
                    transactions: item.transactions || 0,
                })),
            },
            trends: {
                monthlyRegistrations: this.normalizeMonthlyRegistrationTrend(monthlyRegistrationTrend),
                monthlyRevenue: this.normalizeMonthlyRevenueTrend(monthlyRevenueTrend),
            },
            generatedAt: new Date().toISOString(),
        };
    }

    normalizeMonthlyRegistrationTrend(registrationRows) {
        const keys = this.getLastSixMonthKeys();
        const map = registrationRows.reduce((acc, item) => {
            const key = `${item._id.year}-${item._id.month}`;
            acc[key] = item.count;
            return acc;
        }, {});

        return keys.map((item) => ({
            month: item.label,
            value: map[item.key] || 0,
        }));
    }

    normalizeMonthlyRevenueTrend(revenueRows) {
        const keys = this.getLastSixMonthKeys();
        const map = revenueRows.reduce((acc, item) => {
            const key = `${item._id.year}-${item._id.month}`;
            acc[key] = Number(item.revenue || 0);
            return acc;
        }, {});

        return keys.map((item) => ({
            month: item.label,
            value: map[item.key] || 0,
        }));
    }

    getLastSixMonthKeys() {
        const now = new Date();
        const output = [];

        for (let i = 5; i >= 0; i -= 1) {
            const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
            output.push({
                key: `${d.getFullYear()}-${d.getMonth() + 1}`,
                label: d.toLocaleDateString("en-US", { month: "short" }),
            });
        }

        return output;
    }
}

module.exports = new AnalyticsService();
