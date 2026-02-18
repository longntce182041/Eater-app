const fs = require('fs');
const path = require('path');
const { spawn, spawnSync } = require('child_process');
const { BackupRecord } = require('../../models/backupRecord');

const MONGODUMP = process.env.MONGODUMP_PATH || 'mongodump';
const DEFAULT_BACKUP_DIR =
  process.env.BACKUP_DIR || path.resolve(process.cwd(), 'backups');

// Ensure backup dir exists
if (!fs.existsSync(DEFAULT_BACKUP_DIR)) {
  fs.mkdirSync(DEFAULT_BACKUP_DIR, { recursive: true });
}

exports.createBackup = async (req, res) => {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filename = `db-${timestamp}.archive`;
  const outPath = path.join(DEFAULT_BACKUP_DIR, filename);

  const record = new BackupRecord({
    filename,
    path: outPath,
    status: 'in-progress',
    createdBy: req.user && req.user._id
  });
  await record.save();

  // Support several env var names: MONGO_URI, MONGO_URL, MONGODB_URI
  const mongoUri = process.env.MONGO_URI || process.env.MONGO_URL || process.env.MONGODB_URI;
  if (!mongoUri) {
    record.status = 'failed';
    await record.save();
    return res.status(500).json({ success: false, message: 'MONGO_URI not configured' });
  }

  const args = [`--uri=${mongoUri}`, `--archive=${outPath}`, '--gzip'];

  // Check mongodump
  const check = spawnSync(MONGODUMP, ['--version'], { timeout: 5000 });
  if (check.error || check.status !== 0) {
    const msg = check.error ? check.error.message : 'mongodump not available';
    record.status = 'failed';
    record.note = msg;
    await record.save();
    return res.status(500).json({ success: false, message: `mongodump check failed: ${msg}` });
  }

  // Run mongodump
  const proc = spawn(MONGODUMP, args, { stdio: ['ignore', 'pipe', 'pipe'] });

  let stderr = '';
  proc.stderr.on('data', d => (stderr += d.toString()));

  proc.on('error', async err => {
    record.status = 'failed';
    record.note = err.message;
    await record.save();
    return res.status(500).json({ success: false, message: err.message });
  });

  proc.on('close', async code => {
    if (code === 0 && fs.existsSync(outPath)) {
      const { size } = fs.statSync(outPath);
      record.status = 'done';
      record.size = size;
      record.note = stderr || '';
      await record.save();
      return res.json({ success: true, message: 'Backup created', id: record._id });
    }

    record.status = 'failed';
    record.note = stderr || `exit code ${code}`;
    await record.save();
    return res.status(500).json({ success: false, message: record.note });
  });
};

exports.listBackups = async (req, res) => {
  try {
    const list = await BackupRecord.find().sort({ createdAt: -1 }).limit(100);
    return res.json({ success: true, data: list });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.downloadBackup = async (req, res) => {
  try {
    const id = req.params.id;
    const record = await BackupRecord.findById(id);
    if (!record) return res.status(404).json({ success: false, message: 'Backup not found' });
    if (!fs.existsSync(record.path)) return res.status(404).json({ success: false, message: 'File not found' });
    return res.download(record.path, record.filename);
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};
