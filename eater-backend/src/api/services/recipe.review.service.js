const { RecipesReview } = require("../../models/recipes_review");
const { Recipe } = require("../../models/Recipe");
const mongoose = require("mongoose");

/**
 * Add or update a review for a recipe
 */
async function addReview(userId, recipeId, rating, comment = "") {
    // Validate rating
    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
        throw new Error("Rating must be an integer between 1 and 5");
    }

    // Check if recipe exists
    const recipe = await Recipe.findById(recipeId);
    if (!recipe) {
        throw new Error("Recipe not found");
    }

    // Check if review already exists
    let review = await RecipesReview.findOne({
        userId,
        recipeId,
    });

    if (review) {
        // Update existing review
        review.rating = rating;
        review.comment = comment;
        review.updatedAt = new Date();
        await review.save();
    } else {
        // Create new review
        review = new RecipesReview({
            userId,
            recipeId,
            rating,
            comment,
        });
        await review.save();
    }

    return review;
}

/**
 * Get review details for a specific recipe
 */
async function getReviewById(reviewId) {
    const review = await RecipesReview.findById(reviewId)
        .populate({
            path: "userId",
            select: "name email profileImage",
        })
        .populate({
            path: "recipeId",
            select: "_id name",
        });

    if (!review) {
        throw new Error("Review not found");
    }

    return review;
}

/**
 * Get user's review for a specific recipe
 */
async function getUserReview(userId, recipeId) {
    const review = await RecipesReview.findOne({
        userId,
        recipeId,
    });

    return review;
}

/**
 * Get all reviews for a recipe with pagination
 */
async function getRecipeReviews(
    recipeId,
    options = { page: 1, limit: 10, sortBy: "createdAt", sortOrder: "desc" }
) {
    const { page = 1, limit = 10, sortBy = "createdAt", sortOrder = "desc" } =
        options;

    const skip = (page - 1) * limit;
    const sort = { [sortBy]: sortOrder === "desc" ? -1 : 1 };

    // Get reviews with user details
    const reviews = await RecipesReview.find({ recipeId })
        .populate({
            path: "userId",
            select: "_id name email profileImage",
        })
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .lean();

    const normalizedReviews = reviews.map((review) => {
        const reviewer = review.userId;

        if (!reviewer || typeof reviewer !== "object") {
            return {
                ...review,
                userId: {
                    _id: review.userId || null,
                    name: "User",
                },
            };
        }

        const fallbackName =
            reviewer.name ||
            (typeof reviewer.email === "string"
                ? reviewer.email.split("@")[0]
                : null) ||
            "User";

        return {
            ...review,
            userId: {
                ...reviewer,
                name: fallbackName,
            },
        };
    });

    // Get total count
    const total = await RecipesReview.countDocuments({ recipeId });

    // Calculate average rating
    const avgRatingResult = await RecipesReview.aggregate([
        { $match: { recipeId: new mongoose.Types.ObjectId(recipeId) } },
        {
            $group: {
                _id: "$recipeId",
                avgRating: { $avg: "$rating" },
                totalReviews: { $sum: 1 },
                ratingDistribution: {
                    $push: "$rating",
                },
            },
        },
    ]);

    const avgRating = avgRatingResult.length > 0 ? avgRatingResult[0].avgRating : 0;
    const ratingDistribution = calculateRatingDistribution(
        avgRatingResult.length > 0 ? avgRatingResult[0].ratingDistribution : []
    );

    return {
        reviews: normalizedReviews,
        pagination: {
            total,
            page,
            limit,
            totalPages: Math.ceil(total / limit),
            hasMore: page * limit < total,
        },
        stats: {
            avgRating: parseFloat(avgRating.toFixed(1)),
            totalReviews: total,
            ratingDistribution,
        },
    };
}

/**
 * Get user's reviews across all recipes
 */
async function getUserReviews(
    userId,
    options = { page: 1, limit: 10, sortBy: "createdAt", sortOrder: "desc" }
) {
    const { page = 1, limit = 10, sortBy = "createdAt", sortOrder = "desc" } =
        options;

    const skip = (page - 1) * limit;
    const sort = { [sortBy]: sortOrder === "desc" ? -1 : 1 };

    const reviews = await RecipesReview.find({ userId })
        .populate({
            path: "recipeId",
            select: "_id name imageUrl cookingTime baseServings status description",
        })
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .lean();

    const total = await RecipesReview.countDocuments({ userId });

    return {
        reviews,
        pagination: {
            total,
            page,
            limit,
            totalPages: Math.ceil(total / limit),
            hasMore: page * limit < total,
        },
    };
}

/**
 * Delete a review
 */
async function deleteReview(reviewId, userId) {
    const review = await RecipesReview.findById(reviewId);

    if (!review) {
        throw new Error("Review not found");
    }

    // Check if user owns the review
    if (review.userId.toString() !== userId.toString()) {
        throw new Error("Not authorized to delete this review");
    }

    await RecipesReview.findByIdAndDelete(reviewId);

    return review;
}

/**
 * Helper function to calculate rating distribution
 */
function calculateRatingDistribution(ratings) {
    const distribution = {
        5: 0,
        4: 0,
        3: 0,
        2: 0,
        1: 0,
    };

    ratings.forEach((rating) => {
        distribution[rating]++;
    });

    const total = ratings.length;
    if (total > 0) {
        Object.keys(distribution).forEach((key) => {
            distribution[key] = parseFloat(
                ((distribution[key] / total) * 100).toFixed(1)
            );
        });
    }

    return distribution;
}

module.exports = {
    addReview,
    getReviewById,
    getUserReview,
    getRecipeReviews,
    getUserReviews,
    deleteReview,
};
