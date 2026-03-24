const reviewService = require("../services/recipe.review.service");

/**
 * Add or update a review for a recipe
 * POST /api/recipes/:recipeId/reviews
 */
exports.addReview = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const { rating, comment } = req.body;
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        // Validate input
        if (!rating || rating < 1 || rating > 5) {
            return res.status(400).json({
                success: false,
                message: "Rating must be between 1 and 5",
                code: "INVALID_RATING",
            });
        }

        if (typeof comment !== "string") {
            return res.status(400).json({
                success: false,
                message: "Comment must be a string",
                code: "INVALID_COMMENT",
            });
        }

        const review = await reviewService.addReview(
            userId,
            recipeId,
            rating,
            comment || ""
        );

        res.status(200).json({
            success: true,
            data: {
                review: {
                    reviewId: review._id,
                    rating: review.rating,
                    comment: review.comment,
                    createdAt: review.createdAt,
                    updatedAt: review.updatedAt,
                },
            },
        });
    } catch (error) {
        console.error("Error adding review:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Failed to add review",
            code: "ADD_REVIEW_ERROR",
        });
    }
};

/**
 * Get all reviews for a recipe
 * GET /api/recipes/:recipeId/reviews
 */
exports.getRecipeReviews = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const { page = 1, limit = 10, sortBy = "createdAt", sortOrder = "desc" } =
            req.query;

        const result = await reviewService.getRecipeReviews(recipeId, {
            page: parseInt(page),
            limit: parseInt(limit),
            sortBy,
            sortOrder,
        });

        res.status(200).json({
            success: true,
            data: {
                reviews: result.reviews,
                pagination: result.pagination,
                stats: result.stats,
            },
        });
    } catch (error) {
        console.error("Error fetching recipe reviews:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Failed to fetch reviews",
            code: "FETCH_REVIEWS_ERROR",
        });
    }
};

/**
 * Get user's review for a specific recipe
 * GET /api/recipes/:recipeId/reviews/user/mine
 */
exports.getUserRecipeReview = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        const review = await reviewService.getUserReview(userId, recipeId);

        if (!review) {
            return res.status(200).json({
                success: true,
                data: {
                    review: null,
                },
            });
        }

        res.status(200).json({
            success: true,
            data: {
                review: {
                    reviewId: review._id,
                    rating: review.rating,
                    comment: review.comment,
                    createdAt: review.createdAt,
                    updatedAt: review.updatedAt,
                },
            },
        });
    } catch (error) {
        console.error("Error fetching user review:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Failed to fetch review",
            code: "FETCH_REVIEW_ERROR",
        });
    }
};

/**
 * Get all user reviews
 * GET /api/recipes/reviews/user/list
 */
exports.getUserReviews = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }
        const { page = 1, limit = 10, sortBy = "createdAt", sortOrder = "desc" } =
            req.query;

        const result = await reviewService.getUserReviews(userId, {
            page: parseInt(page),
            limit: parseInt(limit),
            sortBy,
            sortOrder,
        });

        res.status(200).json({
            success: true,
            data: {
                reviews: result.reviews.map((review) => ({
                    reviewId: review._id,
                    rating: review.rating,
                    comment: review.comment,
                    recipe: review.recipeId,
                    createdAt: review.createdAt,
                    updatedAt: review.updatedAt,
                })),
                pagination: result.pagination,
            },
        });
    } catch (error) {
        console.error("Error fetching user reviews:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Failed to fetch reviews",
            code: "FETCH_REVIEWS_ERROR",
        });
    }
};

/**
 * Delete a review
 * DELETE /api/recipes/:recipeId/reviews/:reviewId
 */
exports.deleteReview = async (req, res) => {
    try {
        const { reviewId } = req.params;
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        await reviewService.deleteReview(reviewId, userId);

        res.status(200).json({
            success: true,
            data: {
                message: "Review deleted successfully",
            },
        });
    } catch (error) {
        console.error("Error deleting review:", error);
        const statusCode = error.message.includes("Not authorized") ? 403 : 500;
        res.status(statusCode).json({
            success: false,
            message: error.message || "Failed to delete review",
            code: "DELETE_REVIEW_ERROR",
        });
    }
};
