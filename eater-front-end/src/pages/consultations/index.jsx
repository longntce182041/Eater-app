import React, { useEffect, useState, useRef } from 'react';
import { MessageSquare, RefreshCw, X, Send } from 'lucide-react';
import { toast } from 'react-toastify';
import { consultationApi } from '../../services/consultationApi';

const STATUS_FILTERS = [
    { value: '', label: 'All' },
    { value: 'pending', label: 'Pending' },
    { value: 'accepted', label: 'Accepted' },
    { value: 'answered', label: 'Answered' },
    { value: 'closed', label: 'Closed' },
];

const STATUS_COLORS = {
    pending: { bg: '#fff3cd', color: '#856404' },
    accepted: { bg: '#cce5ff', color: '#004085' },
    answered: { bg: '#d4edda', color: '#155724' },
    closed: { bg: '#e2e3e5', color: '#383d41' },
};

const CATEGORY_LABELS = {
    diet: 'Diet',
    weight: 'Weight',
    health_goal: 'Health Goal',
    meal_plan: 'Meal Plan',
    other: 'Other',
};

const ConsultationsPage = () => {
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [statusFilter, setStatusFilter] = useState('');

    const [selected, setSelected] = useState(null);
    const [detail, setDetail] = useState(null);
    const [detailLoading, setDetailLoading] = useState(false);

    const [replyText, setReplyText] = useState('');
    const [replying, setReplying] = useState(false);

    const repliesEndRef = useRef(null);

    const fetchList = async (status) => {
        try {
            setLoading(true);
            const res = await consultationApi.getRequests(status ? { status } : {});
            if (res.data.success) {
                setItems(res.data.data.items || []);
            }
        } catch {
            toast.error('Failed to load consultations');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchList(statusFilter);
    }, [statusFilter]);

    const fetchDetail = async (id) => {
        setDetailLoading(true);
        setDetail(null);
        try {
            const res = await consultationApi.getDetail(id);
            if (res.data.success) {
                setDetail(res.data.data);
            }
        } catch {
            toast.error('Failed to load detail');
        } finally {
            setDetailLoading(false);
        }
    };

    const openDetail = (item) => {
        setSelected(item);
        setReplyText('');
        fetchDetail(item.id);
    };

    const closeDetail = () => {
        setSelected(null);
        setDetail(null);
    };

    useEffect(() => {
        if (detail?.replies?.length) {
            repliesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
        }
    }, [detail?.replies]);

    const handleUpdateStatus = async (id, newStatus) => {
        try {
            await consultationApi.updateStatus(id, newStatus);
            toast.success(`Status updated to ${newStatus}`);
            fetchDetail(id);
            fetchList(statusFilter);
        } catch (err) {
            toast.error(err.response?.data?.message || 'Failed to update status');
        }
    };

    const handleReply = async () => {
        if (!replyText.trim()) return;
        setReplying(true);
        try {
            await consultationApi.reply(selected.id, replyText.trim());
            toast.success('Reply sent!');
            setReplyText('');
            fetchDetail(selected.id);
            fetchList(statusFilter);
        } catch (err) {
            toast.error(err.response?.data?.message || 'Failed to send reply');
        } finally {
            setReplying(false);
        }
    };

    const handleKeyDown = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleReply();
        }
    };

    const formatDate = (d) => {
        if (!d) return '';
        const dt = new Date(d);
        return `${dt.getDate()}/${dt.getMonth() + 1}/${dt.getFullYear()} ${String(dt.getHours()).padStart(2, '0')}:${String(dt.getMinutes()).padStart(2, '0')}`;
    };

    return (
        <div style={{ display: 'flex', gap: '20px', height: 'calc(100vh - 40px)', overflow: 'hidden' }}>

            {/* LEFT: LIST */}
            <div style={{ flex: selected ? '0 0 55%' : '1', display: 'flex', flexDirection: 'column', minWidth: 0 }}>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                    <h2 style={{ color: '#30a5ff', margin: 0 }}>Consultation Requests</h2>
                    <button
                        onClick={() => fetchList(statusFilter)}
                        style={{ background: 'none', border: '1px solid #ddd', borderRadius: '4px', padding: '6px 12px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px', color: '#666' }}
                    >
                        <RefreshCw size={15} /> Refresh
                    </button>
                </div>

                <div style={{ display: 'flex', gap: '8px', marginBottom: '16px', flexWrap: 'wrap' }}>
                    {STATUS_FILTERS.map(f => (
                        <button
                            key={f.value}
                            onClick={() => setStatusFilter(f.value)}
                            style={{
                                padding: '5px 14px', borderRadius: '20px', border: 'none',
                                cursor: 'pointer', fontWeight: '500', fontSize: '13px',
                                background: statusFilter === f.value ? '#30a5ff' : '#eef2f7',
                                color: statusFilter === f.value ? 'white' : '#555',
                            }}
                        >
                            {f.label}
                        </button>
                    ))}
                </div>

                <div style={{ background: 'white', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', overflow: 'auto', flex: 1 }}>
                    {loading ? (
                        <p style={{ textAlign: 'center', padding: '40px', color: '#999' }}>Loading...</p>
                    ) : items.length === 0 ? (
                        <div style={{ textAlign: 'center', padding: '60px 20px', color: '#aaa' }}>
                            <MessageSquare size={48} style={{ marginBottom: '12px', opacity: 0.3 }} />
                            <p>No consultation requests found.</p>
                        </div>
                    ) : (
                        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                            <thead>
                                <tr style={{ borderBottom: '2px solid #eee', color: '#5f6468', textAlign: 'left' }}>
                                    <th style={{ padding: '12px 16px' }}>Title / User</th>
                                    <th style={{ padding: '12px 16px' }}>Category</th>
                                    <th style={{ padding: '12px 16px' }}>Status</th>
                                    <th style={{ padding: '12px 16px' }}>Date</th>
                                    <th style={{ padding: '12px 16px' }}>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                {items.map(item => {
                                    const sc = STATUS_COLORS[item.status] || { bg: '#eee', color: '#333' };
                                    return (
                                        <tr
                                            key={item.id}
                                            style={{
                                                borderBottom: '1px solid #f0f0f0',
                                                background: selected?.id === item.id ? '#f0f7ff' : 'white',
                                            }}
                                        >
                                            <td style={{ padding: '12px 16px', maxWidth: '200px' }}>
                                                <div style={{ fontWeight: '500', color: '#333', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{item.title}</div>
                                                <div style={{ fontSize: '12px', color: '#999', marginTop: '2px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                                                    {item.user?.email || '—'}
                                                </div>
                                            </td>
                                            <td style={{ padding: '12px 16px', fontSize: '12px', color: '#555' }}>
                                                {CATEGORY_LABELS[item.category] || item.category}
                                            </td>
                                            <td style={{ padding: '12px 16px' }}>
                                                <span style={{ padding: '3px 10px', borderRadius: '12px', fontSize: '11px', fontWeight: '600', background: sc.bg, color: sc.color }}>
                                                    {item.status}
                                                </span>
                                            </td>
                                            <td style={{ padding: '12px 16px', fontSize: '12px', color: '#888', whiteSpace: 'nowrap' }}>
                                                {new Date(item.createdAt).toLocaleDateString()}
                                            </td>
                                            <td style={{ padding: '12px 16px' }}>
                                                <button
                                                    onClick={() => openDetail(item)}
                                                    style={{ background: '#30a5ff', color: 'white', border: 'none', padding: '5px 12px', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' }}
                                                >
                                                    View
                                                </button>
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>

            {/* RIGHT: DETAIL */}
            {selected && (
                <div style={{
                    flex: '0 0 43%', background: 'white', borderRadius: '8px',
                    boxShadow: '0 1px 3px rgba(0,0,0,0.12)', display: 'flex', flexDirection: 'column',
                    overflow: 'hidden', minWidth: 0,
                }}>

                    <div style={{ padding: '16px 20px', borderBottom: '1px solid #eee', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '10px' }}>
                        <div style={{ minWidth: 0 }}>
                            <div style={{ fontWeight: 'bold', fontSize: '15px', color: '#333', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                                {selected.title}
                            </div>
                            <div style={{ fontSize: '12px', color: '#999', marginTop: '2px' }}>
                                {selected.user?.email || ''}
                            </div>
                        </div>
                        <button onClick={closeDetail} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#999', flexShrink: 0 }}>
                            <X size={20} />
                        </button>
                    </div>

                    {detailLoading ? (
                        <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#aaa' }}>Loading...</div>
                    ) : detail ? (
                        <>
                            {/* Meta */}
                            <div style={{ padding: '12px 20px', borderBottom: '1px solid #f5f5f5', display: 'flex', gap: '10px', flexWrap: 'wrap', alignItems: 'center' }}>
                                <span style={{
                                    padding: '3px 10px', borderRadius: '12px', fontSize: '11px', fontWeight: '600',
                                    background: (STATUS_COLORS[detail.status] || { bg: '#eee' }).bg,
                                    color: (STATUS_COLORS[detail.status] || { color: '#333' }).color,
                                }}>
                                    {detail.status}
                                </span>
                                <span style={{ fontSize: '12px', background: '#eef2f7', padding: '3px 10px', borderRadius: '12px', color: '#555' }}>
                                    {CATEGORY_LABELS[detail.category] || detail.category}
                                </span>
                                <span style={{ fontSize: '11px', color: '#aaa', marginLeft: 'auto' }}>{formatDate(detail.createdAt)}</span>
                            </div>

                            {/* Status actions */}
                            {detail.status !== 'closed' && (
                                <div style={{ padding: '10px 20px', borderBottom: '1px solid #f5f5f5', display: 'flex', gap: '8px' }}>
                                    {detail.status === 'pending' && (
                                        <button
                                            onClick={() => handleUpdateStatus(detail.id, 'accepted')}
                                            style={{ padding: '5px 14px', background: '#cce5ff', color: '#004085', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '12px', fontWeight: '600' }}
                                        >
                                            Accept
                                        </button>
                                    )}
                                    {(detail.status === 'accepted' || detail.status === 'answered') && (
                                        <button
                                            onClick={() => handleUpdateStatus(detail.id, 'closed')}
                                            style={{ padding: '5px 14px', background: '#e2e3e5', color: '#383d41', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '12px', fontWeight: '600' }}
                                        >
                                            Close
                                        </button>
                                    )}
                                </div>
                            )}

                            {/* Original question */}
                            <div style={{ padding: '14px 20px', borderBottom: '1px solid #f0f0f0', background: '#fafafa' }}>
                                <div style={{ fontSize: '11px', color: '#aaa', marginBottom: '6px', fontWeight: '500', textTransform: 'uppercase', letterSpacing: '0.5px' }}>User's Question</div>
                                <div style={{ fontSize: '13px', color: '#444', lineHeight: '1.6', whiteSpace: 'pre-wrap' }}>{detail.message}</div>
                            </div>

                            {/* Replies */}
                            <div style={{ flex: 1, overflowY: 'auto', padding: '14px 20px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                {!detail.replies?.length ? (
                                    <div style={{ textAlign: 'center', color: '#ccc', padding: '20px', fontSize: '13px' }}>No replies yet</div>
                                ) : (
                                    detail.replies.map((r, i) => {
                                        const isNutri = r.senderRole === 'nutritionist' || r.senderRole === 'admin';
                                        return (
                                            <div key={i} style={{ alignSelf: isNutri ? 'flex-start' : 'flex-end', maxWidth: '80%' }}>
                                                {isNutri && (
                                                    <div style={{ fontSize: '11px', color: '#30a5ff', marginBottom: '3px', fontWeight: '600' }}>
                                                        {r.sender?.email || 'Nutritionist'}
                                                    </div>
                                                )}
                                                <div style={{
                                                    padding: '10px 14px',
                                                    borderRadius: isNutri ? '4px 12px 12px 12px' : '12px 4px 12px 12px',
                                                    background: isNutri ? '#f0f7ff' : '#30a5ff',
                                                    color: isNutri ? '#333' : 'white',
                                                    fontSize: '13px',
                                                    lineHeight: '1.5',
                                                    whiteSpace: 'pre-wrap',
                                                    border: isNutri ? '1px solid #d0e8ff' : 'none',
                                                }}>
                                                    {r.content}
                                                </div>
                                                <div style={{ fontSize: '10px', color: '#bbb', marginTop: '3px', textAlign: isNutri ? 'left' : 'right' }}>
                                                    {formatDate(r.createdAt)}
                                                </div>
                                            </div>
                                        );
                                    })
                                )}
                                <div ref={repliesEndRef} />
                            </div>

                            {/* Reply input */}
                            {detail.status !== 'closed' ? (
                                <div style={{ padding: '12px 20px', borderTop: '1px solid #eee', display: 'flex', gap: '10px', alignItems: 'flex-end' }}>
                                    <textarea
                                        value={replyText}
                                        onChange={e => setReplyText(e.target.value)}
                                        onKeyDown={handleKeyDown}
                                        placeholder="Write a reply... (Enter to send, Shift+Enter for new line)"
                                        rows={2}
                                        style={{
                                            flex: 1, padding: '10px 12px', borderRadius: '8px',
                                            border: '1px solid #ddd', resize: 'none', fontSize: '13px',
                                            fontFamily: 'inherit', outline: 'none',
                                        }}
                                    />
                                    <button
                                        onClick={handleReply}
                                        disabled={replying || !replyText.trim()}
                                        style={{
                                            background: replyText.trim() ? '#30a5ff' : '#cce0f5',
                                            color: 'white', border: 'none',
                                            padding: '10px 16px', borderRadius: '8px',
                                            cursor: replyText.trim() ? 'pointer' : 'not-allowed',
                                            display: 'flex', alignItems: 'center', gap: '5px',
                                            fontWeight: '600', fontSize: '13px', flexShrink: 0,
                                        }}
                                    >
                                        <Send size={15} /> {replying ? 'Sending...' : 'Send'}
                                    </button>
                                </div>
                            ) : (
                                <div style={{ padding: '12px 20px', borderTop: '1px solid #eee', textAlign: 'center', color: '#aaa', fontSize: '13px' }}>
                                    This consultation is closed.
                                </div>
                            )}
                        </>
                    ) : null}
                </div>
            )}
        </div>
    );
};

export default ConsultationsPage;
