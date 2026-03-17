import React, { useEffect, useState, useRef, useCallback } from 'react';
import { Send, MessageCircle, RefreshCw } from 'lucide-react';
import { toast } from 'react-toastify';
import { chatApi } from '../../services/chatApi';
import { chatSocket } from '../../services/chatSocketService';

// ── helpers ──────────────────────────────────────────────────────────────────
function getInitials(email = '') {
    const parts = email.split('@')[0].split(/[._-]/);
    return parts.length >= 2
        ? (parts[0][0] + parts[1][0]).toUpperCase()
        : email.slice(0, 2).toUpperCase();
}

function formatTime(dateStr) {
    const d = new Date(dateStr);
    return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

function formatDate(dateStr) {
    const d = new Date(dateStr);
    return d.toLocaleDateString();
}

// ── styles ───────────────────────────────────────────────────────────────────
const S = {
    page: {
        display: 'flex',
        height: 'calc(100vh - 40px)',
        background: '#f5f5f5',
        borderRadius: 12,
        overflow: 'hidden',
        boxShadow: '0 2px 12px rgba(0,0,0,0.08)',
    },
    // Left panel
    left: {
        width: 300,
        minWidth: 280,
        background: '#fff',
        borderRight: '1px solid #eee',
        display: 'flex',
        flexDirection: 'column',
    },
    leftHeader: {
        padding: '20px 16px 12px',
        borderBottom: '1px solid #f0f0f0',
    },
    leftTitle: {
        fontSize: 16,
        fontWeight: 700,
        color: '#2d2d2d',
        marginBottom: 4,
    },
    leftSub: { fontSize: 12, color: '#999' },
    contactList: { flex: 1, overflowY: 'auto' },
    contactItem: (active) => ({
        display: 'flex',
        alignItems: 'center',
        gap: 12,
        padding: '12px 16px',
        cursor: 'pointer',
        background: active ? '#fff3e0' : 'transparent',
        borderLeft: active ? '3px solid #FF9800' : '3px solid transparent',
        transition: 'background 0.15s',
    }),
    avatar: (color = '#FF9800') => ({
        width: 42,
        height: 42,
        borderRadius: '50%',
        background: color,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#fff',
        fontWeight: 700,
        fontSize: 14,
        flexShrink: 0,
    }),
    contactInfo: { flex: 1, minWidth: 0 },
    contactEmail: {
        fontSize: 13,
        fontWeight: 600,
        color: '#333',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
    },
    contactSub: { fontSize: 11, color: '#aaa', marginTop: 2 },

    // Right panel
    right: {
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        background: '#fafafa',
    },
    chatHeader: {
        padding: '14px 20px',
        background: '#fff',
        borderBottom: '1px solid #eee',
        display: 'flex',
        alignItems: 'center',
        gap: 12,
    },
    chatHeaderInfo: { flex: 1 },
    chatHeaderName: { fontSize: 15, fontWeight: 700, color: '#2d2d2d' },
    chatHeaderSub: { fontSize: 11, color: '#999', marginTop: 2 },

    // Messages
    messages: {
        flex: 1,
        overflowY: 'auto',
        padding: '20px 24px',
        display: 'flex',
        flexDirection: 'column',
        gap: 4,
    },
    bubble: (isMe) => ({
        maxWidth: '68%',
        alignSelf: isMe ? 'flex-end' : 'flex-start',
        marginBottom: 6,
    }),
    bubbleInner: (isMe) => ({
        padding: '10px 14px',
        borderRadius: isMe
            ? '16px 16px 4px 16px'
            : '16px 16px 16px 4px',
        background: isMe ? '#FF9800' : '#fff',
        color: isMe ? '#fff' : '#333',
        fontSize: 14,
        lineHeight: 1.4,
        boxShadow: '0 1px 4px rgba(0,0,0,0.08)',
        wordBreak: 'break-word',
    }),
    bubbleTime: (isMe) => ({
        fontSize: 10,
        color: '#aaa',
        textAlign: isMe ? 'right' : 'left',
        marginTop: 3,
        paddingHorizontal: 2,
    }),
    dateDivider: {
        textAlign: 'center',
        margin: '12px 0',
        fontSize: 11,
        color: '#bbb',
    },

    // Input bar
    inputBar: {
        padding: '12px 20px',
        background: '#fff',
        borderTop: '1px solid #eee',
        display: 'flex',
        alignItems: 'flex-end',
        gap: 10,
    },
    textarea: {
        flex: 1,
        border: '1px solid #eee',
        borderRadius: 24,
        padding: '10px 16px',
        fontSize: 13,
        resize: 'none',
        outline: 'none',
        fontFamily: 'inherit',
        background: '#f9f9f9',
        maxHeight: 120,
        minHeight: 40,
    },
    sendBtn: (disabled) => ({
        width: 40,
        height: 40,
        borderRadius: '50%',
        background: disabled ? '#ddd' : '#FF9800',
        border: 'none',
        cursor: disabled ? 'not-allowed' : 'pointer',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        flexShrink: 0,
        transition: 'background 0.2s',
    }),

    // Placeholder
    emptyRight: {
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#ccc',
        gap: 12,
    },
};

// ── Main component ───────────────────────────────────────────────────────────
const ChatPage = () => {
    const [contacts, setContacts] = useState([]);
    const [contactsLoading, setContactsLoading] = useState(true);

    const [selectedUser, setSelectedUser] = useState(null);   // { id, email }
    const [messages, setMessages] = useState([]);
    const [historyLoading, setHistoryLoading] = useState(false);

    const [input, setInput] = useState('');
    const [sending, setSending] = useState(false);

    const messagesEndRef = useRef(null);
    const textareaRef = useRef(null);

    // ── Load contacts ──────────────────────────────────────────────────────
    const loadContacts = useCallback(async () => {
        setContactsLoading(true);
        try {
            const res = await chatApi.getContacts();
            if (res.data.success) setContacts(res.data.data || []);
        } catch {
            toast.error('Failed to load contacts');
        } finally {
            setContactsLoading(false);
        }
    }, []);

    useEffect(() => {
        loadContacts();
        chatSocket.connect();
        chatSocket.onMessage((msg) => {
            setMessages((prev) => {
                if (prev.find((m) => m.id === msg.id)) return prev;
                return [...prev, msg];
            });
            scrollToBottom();
        });
        return () => chatSocket.disconnect();
    }, [loadContacts]);

    // ── Select user ────────────────────────────────────────────────────────
    const selectUser = async (user) => {
        if (selectedUser?.id === user.id) return;

        setSelectedUser(user);
        setMessages([]);
        setHistoryLoading(true);

        // Leave previous room, join new one
        chatSocket.leaveRoom();
        chatSocket.joinRoomUser(user.id);

        try {
            const res = await chatApi.getHistory(user.id);
            if (res.data.success) {
                setMessages(res.data.data.messages || []);
            }
        } catch {
            toast.error('Failed to load chat history');
        } finally {
            setHistoryLoading(false);
            setTimeout(scrollToBottom, 100);
        }
    };

    // ── Send message ───────────────────────────────────────────────────────
    const sendMessage = useCallback(() => {
        const text = input.trim();
        if (!text || !selectedUser || sending) return;

        setSending(true);
        chatSocket.sendMessage(text);
        setInput('');
        setSending(false);
        textareaRef.current?.focus();
    }, [input, selectedUser, sending]);

    const handleKeyDown = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    };

    // ── Scroll helpers ─────────────────────────────────────────────────────
    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    // ── Render helpers ─────────────────────────────────────────────────────
    const renderMessages = () => {
        if (historyLoading) {
            return (
                <div style={{ textAlign: 'center', color: '#aaa', marginTop: 40 }}>
                    Loading messages…
                </div>
            );
        }

        if (messages.length === 0) {
            return (
                <div style={{ textAlign: 'center', color: '#ccc', marginTop: 60 }}>
                    <MessageCircle size={40} style={{ marginBottom: 8 }} />
                    <div>No messages yet. Say hello!</div>
                </div>
            );
        }

        let lastDate = '';
        return messages.map((msg) => {
            const isMe = msg.senderRole === 'nutritionist';
            const dateStr = formatDate(msg.createdAt);
            const showDate = dateStr !== lastDate;
            lastDate = dateStr;

            return (
                <React.Fragment key={msg.id}>
                    {showDate && (
                        <div style={S.dateDivider}>{dateStr}</div>
                    )}
                    <div style={S.bubble(isMe)}>
                        <div style={S.bubbleInner(isMe)}>{msg.content}</div>
                        <div style={S.bubbleTime(isMe)}>{formatTime(msg.createdAt)}</div>
                    </div>
                </React.Fragment>
            );
        });
    };

    // ── Render ─────────────────────────────────────────────────────────────
    return (
        <div style={S.page}>
            {/* ── LEFT PANEL ─────────────────────────────────────────── */}
            <div style={S.left}>
                <div style={S.leftHeader}>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                        <div style={S.leftTitle}>Live Chat</div>
                        <button
                            onClick={loadContacts}
                            style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#999', padding: 4 }}
                            title="Refresh contacts"
                        >
                            <RefreshCw size={15} />
                        </button>
                    </div>
                    <div style={S.leftSub}>
                        {contactsLoading ? 'Loading…' : `${contacts.length} user${contacts.length !== 1 ? 's' : ''}`}
                    </div>
                </div>

                <div style={S.contactList}>
                    {contacts.length === 0 && !contactsLoading && (
                        <div style={{ padding: '24px 16px', color: '#bbb', fontSize: 13, textAlign: 'center' }}>
                            No contacts yet. Users who have chatted with you will appear here.
                        </div>
                    )}
                    {contacts.map((user) => {
                        const initials = getInitials(user.email);
                        const isActive = selectedUser?.id === user.id;
                        return (
                            <div
                                key={user.id}
                                style={S.contactItem(isActive)}
                                onClick={() => selectUser(user)}
                            >
                                <div style={S.avatar()}>
                                    {initials}
                                </div>
                                <div style={S.contactInfo}>
                                    <div style={S.contactEmail}>{user.email}</div>
                                    <div style={S.contactSub}>Tap to chat</div>
                                </div>
                            </div>
                        );
                    })}
                </div>
            </div>

            {/* ── RIGHT PANEL ────────────────────────────────────────── */}
            <div style={S.right}>
                {!selectedUser ? (
                    <div style={S.emptyRight}>
                        <MessageCircle size={64} opacity={0.3} />
                        <div style={{ fontSize: 16, fontWeight: 600 }}>Select a user to start chatting</div>
                        <div style={{ fontSize: 13 }}>Messages are delivered in real-time</div>
                    </div>
                ) : (
                    <>
                        {/* Header */}
                        <div style={S.chatHeader}>
                            <div style={S.avatar()}>
                                {getInitials(selectedUser.email)}
                            </div>
                            <div style={S.chatHeaderInfo}>
                                <div style={S.chatHeaderName}>{selectedUser.email}</div>
                                <div style={S.chatHeaderSub}>● Online</div>
                            </div>
                        </div>

                        {/* Messages */}
                        <div style={S.messages}>
                            {renderMessages()}
                            <div ref={messagesEndRef} />
                        </div>

                        {/* Input */}
                        <div style={S.inputBar}>
                            <textarea
                                ref={textareaRef}
                                style={S.textarea}
                                value={input}
                                onChange={(e) => setInput(e.target.value)}
                                onKeyDown={handleKeyDown}
                                placeholder="Type a message… (Enter to send)"
                                rows={1}
                            />
                            <button
                                style={S.sendBtn(!input.trim())}
                                onClick={sendMessage}
                                disabled={!input.trim()}
                            >
                                <Send size={16} color="#fff" />
                            </button>
                        </div>
                    </>
                )}
            </div>
        </div>
    );
};

export default ChatPage;
