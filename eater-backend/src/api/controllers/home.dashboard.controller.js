const homeDashboardService = require("../services/home.dashboard.service");

/**
 * Get home dashboard data
 * Returns user profile, today's meals, daily nutrition stats
 */
async function getHomeDashboard(req, res, next) {
    try {
        if (!req.user || !req.user.sub) {
            return res.status(401).json({
                success: false,
                message: "Unauthorized",
                error: "User authentication required",
            });
        }

        const userId = req.user.sub;
        const data = await homeDashboardService.getHomeDashboardData(userId);

        return res.status(200).json(data);
    } catch (error) {
        console.error("Error in getHomeDashboard:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to fetch home dashboard",
            error: error.message,
        });
    }
}

/**
 * Get upcoming meals
 * Returns upcoming meals grouped by day
 */
async function getUpcomingMeals(req, res, next) {
    try {
        if (!req.user || !req.user.sub) {
            return res.status(401).json({
                success: false,
                message: "Unauthorized",
                error: "User authentication required",
            });
        }

        const userId = req.user.sub;
        const days = req.query.days ? parseInt(req.query.days) : 7;

        const data = await homeDashboardService.getUpcomingMeals(userId, days);

        return res.status(200).json(data);
    } catch (error) {
        console.error("Error in getUpcomingMeals:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to fetch upcoming meals",
            error: error.message,
        });
    }
}

module.exports = {
    getHomeDashboard,
    getUpcomingMeals,
};
