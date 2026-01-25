const mongoose = require('mongoose');
const BackupRecordSchema = new mongoose.Schema({
  filename: { type: String, required: true },
  path: { type: String, required: true },
  size: { type: Number, default: 0 },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  status: { type: String, enum: ['in-progress','done','failed'], default: 'in-progress' },
  note: { type: String },
  createdAt: { type: Date, default: Date.now }
});

const BackupRecord = mongoose.model('BackupRecord', BackupRecordSchema);
module.exports = { BackupRecord };
