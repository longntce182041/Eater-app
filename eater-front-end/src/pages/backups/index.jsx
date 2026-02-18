import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axiosClient from '../../api/axiosClient';
import { Download, CloudUpload, Trash } from 'lucide-react';
import { toast } from 'react-toastify';

const BackupsPage = () => {
    const [loading, setLoading] = useState(false);
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
                                            {b.status === 'done' && <button onClick={() => handleDownload(b._id, b.filename)} style={{ marginRight: 8, cursor: 'pointer' }}><Download size={16}/> Download</button>}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            )}
        </div>
    );
};

export default BackupsPage;
