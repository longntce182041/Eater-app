const express = require('express');
const router = express.Router();
const healthGuidesController = require('../controllers/health-guides.controller');
const { protect, authorize } = require('../../middleware/authMiddleware');

/**
 * Get guides by category
 * Query param: ?category=fasting
 * GET /api/health-guides
 */
router.get('/', protect, healthGuidesController.getGuidesByCategory);

/**
 * Get single guide with full content
 * GET /api/health-guides/:id
 */
router.get('/:id', protect, healthGuidesController.getGuideDetail);

/**
 * Create new health guide (ADMIN ONLY)
 * POST /api/health-guides
 */
router.post('/', protect, authorize('admin'), healthGuidesController.createGuide);

/**
 * Update health guide (ADMIN ONLY)
 * PUT /api/health-guides/:id
 */
router.put('/:id', protect, authorize('admin'), healthGuidesController.updateGuide);

/**
 * Delete health guide (ADMIN ONLY)
 * DELETE /api/health-guides/:id
 */
router.delete('/:id', protect, authorize('admin'), healthGuidesController.deleteGuide);

module.exports = router;
