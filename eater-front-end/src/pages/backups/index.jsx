import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axiosClient from '../../api/axiosClient';
import { Download, CloudUpload, RotateCcw, AlertTriangle, X } from 'lucide-react';
import { toast } from 'react-toastify';

const BackupsPage = () => {
    const [loading, setLoading] = useState(false);
    const [restoring, setRestoring] = useState(false);
    const [showRestoreModal, setShowRestoreModal] = useState(false);
    const [selectedBackupId, setSelectedBackupId] = useState(null);
    const [selectedBackupFilename, setSelectedBackupFilename] = useState('');
    const navigate = useNavigate();
    const [backups, setBackups] = useState([]);

    const fetchBackups = async () => {
        try {
            setLoading(true);
            const res = await axiosClient.get('/admin/backups');
            if (res.data && res.data.success) setBackups(res.data.data);
        } catch (err) {
            console.error(err);
            const status = err.response?.status;
            if (status === 401) {
                toast.error('Unauthorized — please login');
                return navigate('/login');
            }
            if (status === 403) {
                toast.error('Forbidden — insufficient permissions');
                return;
            }
            toast.error('Failed to load backups');
        } finally { setLoading(false); }
    };

    useEffect(() => { fetchBackups(); }, []);

    const handleCreate = async () => {
        try {
            setLoading(true);
            const res = await axiosClient.post('/admin/backup');
            if (res.data && res.data.success) {
                toast.success('Backup started');
                fetchBackups();
            }
        } catch (err) {
            console.error(err);
            const status = err.response?.status;
            if (status === 401) {
                toast.error('Unauthorized — please login');
                return navigate('/login');
            }
            if (status === 403) {
                toast.error('Forbidden — insufficient permissions');
                return;
            }
            toast.error(err.response?.data?.message || 'Backup failed');
        } finally { setLoading(false); }
    };

    const handleDownload = async (id, filename) => {
        try {
            const res = await axiosClient.get(`/admin/backups/${id}/download`, { responseType: 'blob' });
            const url = window.URL.createObjectURL(new Blob([res.data]));
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', filename || 'backup.archive');
            document.body.appendChild(link);
            link.click();
            link.parentNode.removeChild(link);
            window.URL.revokeObjectURL(url);
        } catch (err) {
            console.error(err);
            const status = err.response?.status;
            if (status === 401) {
                toast.error('Unauthorized — please login');
                return navigate('/login');
            }
            if (status === 403) {
                toast.error('Forbidden — insufficient permissions');
                return;
            }
            toast.error('Download failed');
        }
    };

    const handleRestoreClick = (id, filename) => {
        setSelectedBackupId(id);
        setSelectedBackupFilename(filename);
        setShowRestoreModal(true);
    };

    const handleRestoreConfirm = async () => {
        try {
            setRestoring(true);
            const res = await axiosClient.post(`/admin/backups/${selectedBackupId}/restore`);
            if (res.data && res.data.success) {
                toast.success('Restore started - System data being restored...');
                setShowRestoreModal(false);
                fetchBackups();
            }
        } catch (err) {
            console.error(err);
            const status = err.response?.status;
            if (status === 401) {
                toast.error('Unauthorized — please login');
                setShowRestoreModal(false);
                return navigate('/login');
            }
            if (status === 403) {
                toast.error('Forbidden — insufficient permissions');
                setShowRestoreModal(false);
                return;
            }
            toast.error(err.response?.data?.message || 'Restore failed');
        } finally {
            setRestoring(false);
        }
    };

    const handleRestoreCancel = () => {
        setShowRestoreModal(false);
        setSelectedBackupId(null);
        setSelectedBackupFilename('');
    };

    return (
        <div>
            <h2 style={{ color: '#30a5ff', marginBottom: 16 }}>System Backups</h2>
            <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
                <button onClick={handleCreate} style={{ background: '#30a5ff', color: '#fff', padding: '8px 12px', borderRadius: 6, border: 'none', cursor: 'pointer' }}>
                    <CloudUpload size={16} style={{ marginRight: 8 }} /> Create Backup
                </button>
            </div>

            {loading ? <p>Loading...</p> : (
                <div style={{ background: '#fff', padding: 12, borderRadius: 6 }}>
                    {backups.length === 0 ? <p style={{ color: '#666' }}>No backups yet.</p> : (
                        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                            <thead>
                                <tr style={{ textAlign: 'left', borderBottom: '1px solid #eee' }}>
                                    <th style={{ padding: 8 }}>Filename</th>
                                    <th style={{ padding: 8 }}>Size</th>
                                    <th style={{ padding: 8 }}>Created At</th>
                                    <th style={{ padding: 8 }}>Status</th>
                                    <th style={{ padding: 8 }}>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {backups.map(b => (
                                    <tr key={b._id} style={{ borderBottom: '1px solid #fafafa' }}>
                                        <td style={{ padding: 8 }}>{b.filename}</td>
                                        <td style={{ padding: 8 }}>{b.size ? `${(b.size/1024).toFixed(1)} KB` : '-'}</td>
                                        <td style={{ padding: 8 }}>{new Date(b.createdAt).toLocaleString()}</td>
                                        <td style={{ padding: 8 }}>{b.status}</td>
                                        <td style={{ padding: 8 }}>
                                            {b.status === 'done' && (
                                                <div style={{ display: 'flex', gap: 8 }}>
                                                    <button onClick={() => handleDownload(b._id, b.filename)} style={{ marginRight: 0, cursor: 'pointer', background: '#f0f0f0', border: 'none', padding: '6px 10px', borderRadius: 4 }}><Download size={16}/> Download</button>
                                                    <button onClick={() => handleRestoreClick(b._id, b.filename)} style={{ cursor: 'pointer', background: '#fff3cd', border: '1px solid #ffc107', padding: '6px 10px', borderRadius: 4, color: '#856404' }} disabled={restoring}><RotateCcw size={16} style={{ marginRight: 4 }} /> Restore</button>
                                                </div>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            )}

            {/* Restore Confirmation Modal */}
            {showRestoreModal && (
                <div style={{
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    background: 'rgba(0,0,0,0.5)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    zIndex: 1000
                }}>
                    <div style={{
                        background: '#fff',
                        borderRadius: 8,
                        padding: 24,
                        maxWidth: 480,
                        width: '90%',
                        boxShadow: '0 4px 16px rgba(0,0,0,0.1)'
                    }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
                            <AlertTriangle size={24} color="#f59e0b" />
                            <h3 style={{ margin: 0, color: '#1f2937', fontSize: 18, fontWeight: 600 }}>Restore System Data</h3>
                            <button onClick={handleRestoreCancel} style={{ marginLeft: 'auto', background: 'none', border: 'none', cursor: 'pointer', padding: 0 }}>
                                <X size={20} />
                            </button>
                        </div>

                        <div style={{ marginBottom: 20 }}>
                            <p style={{ color: '#6b7280', marginBottom: 12, fontSize: 14 }}>
                                <strong>Warning:</strong> This will overwrite all current system data with the backup from:
                            </p>
                            <div style={{
                                background: '#f3f4f6',
                                padding: 12,
                                borderRadius: 6,
                                marginBottom: 12,
                                fontSize: 13,
                                wordBreak: 'break-all',
                                color: '#374151'
                            }}>
                                {selectedBackupFilename}
                            </div>
                            <p style={{ color: '#dc2626', fontSize: 13, fontWeight: 600 }}>
                                ⚠️ This action is irreversible. Make sure you have a backup of your current data.
                            </p>
                        </div>

                        <div style={{ display: 'flex', gap: 12, justifyContent: 'flex-end' }}>
                            <button
                                onClick={handleRestoreCancel}
                                disabled={restoring}
                                style={{
                                    padding: '10px 16px',
                                    border: '1px solid #d1d5db',
                                    background: '#f3f4f6',
                                    borderRadius: 6,
                                    cursor: 'pointer',
                                    fontWeight: 500,
                                    color: '#374151',
                                    disabled: restoring ? 0.6 : 1
                                }}
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleRestoreConfirm}
                                disabled={restoring}
                                style={{
                                    padding: '10px 16px',
                                    background: '#dc2626',
                                    color: '#fff',
                                    border: 'none',
                                    borderRadius: 6,
                                    cursor: 'pointer',
                                    fontWeight: 500,
                                    opacity: restoring ? 0.6 : 1,
                                    pointerEvents: restoring ? 'none' : 'auto'
                                }}
                            >
                                {restoring ? 'Restoring...' : 'Restore Now'}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default BackupsPage;
