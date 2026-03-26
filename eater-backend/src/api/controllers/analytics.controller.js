const analyticsService = require("../services/analytics.service");

class AnalyticsController {
    async getOverview(req, res) {
        try {
            const data = await analyticsService.getOverview();
            res.json({ success: true, data });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }
}

module.exports = new AnalyticsController();
