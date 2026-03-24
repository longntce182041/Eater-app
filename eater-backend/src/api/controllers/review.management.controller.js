const reviewService = require("../services/review.management.service");
const { validateReview } = require("../validators/review.management.validators");
const { getActionMessage } = require("../../utils/actionMessage.util");

class ReviewManagementController {
    // GET List
    async getReviews(req, res) {
        try {
            const result = await reviewService.getAllReviews(req.query);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    // GET Detail
    async getReviewDetail(req, res) {
        try {
            const review = await reviewService.getReviewById(req.params.id);
            res.json({ success: true, data: review });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    }


    // PUT Update
    async updateReview(req, res) {
        try {
            const updatedReview = await reviewService.updateReview(req.params.id, req.body);
            const message = getActionMessage('update', 'Review');
            res.json({ success: true, message, data: updatedReview });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // DELETE
    async deleteReview(req, res) {
        try {
            await reviewService.deleteReview(req.params.id);
            const message = getActionMessage('delete', 'Review');
            res.json({ success: true, message });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }
}

module.exports = new ReviewManagementController();