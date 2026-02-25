const express = require('express');
const router = express.Router();
const backupController = require('../controllers/admin.backup.controller');
const { protect, authorize } = require('../../middleware/authMiddleware');

// Create backup (admin only)
router.post('/backup', protect, authorize('admin'), backupController.createBackup);

// List backups
router.get('/backups', protect, authorize('admin'), backupController.listBackups);

// Download backup file
router.get('/backups/:id/download', protect, authorize('admin'), backupController.downloadBackup);

// Restore backup (admin only) - DESTRUCTIVE OPERATION
router.post('/backups/:id/restore', protect, authorize('admin'), backupController.restoreBackup);

module.exports = router;
