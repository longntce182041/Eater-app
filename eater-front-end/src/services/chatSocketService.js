import { io } from 'socket.io-client';

const SOCKET_URL = 'http://localhost:3000';

let socket = null;
let messageCallback = null;
let connectTimer = null;

export const chatSocket = {
    connect() {
        const token = localStorage.getItem('token');
        if (!token) return;

        // Cancel any pending connection attempt
        clearTimeout(connectTimer);

        // Defer to next tick — lets React StrictMode's cleanup cancel this
        // before the WebSocket is created, avoiding the race condition
        connectTimer = setTimeout(() => {
            if (socket) {
                if (!socket.connected) socket.connect();
                return;
            }

            socket = io(SOCKET_URL, {
                transports: ['websocket'],
                query: { token },
                autoConnect: false,
            });

            socket.on('connect', () => {
                console.log('[Socket] Connected as nutritionist');
            });

            socket.on('receive_message', (msg) => {
                if (messageCallback) messageCallback(msg);
            });

            socket.on('connect_error', (err) => {
                console.error('[Socket] Connect error:', err.message);
            });

            socket.connect();
        }, 0);
    },

    joinRoomUser(userId) {
        if (!socket?.connected) this.connect();
        socket?.emit('join_room_user', { userId });
    },

    sendMessage(content) {
        socket?.emit('send_message', { content });
    },

    leaveRoom() {
        socket?.emit('leave_room');
    },

    onMessage(callback) {
        messageCallback = callback;
    },

    disconnect() {
        // Cancel pending connect, then disconnect
        clearTimeout(connectTimer);
        connectTimer = null;
        socket?.disconnect();
    },

    destroy() {
        clearTimeout(connectTimer);
        connectTimer = null;
        socket?.disconnect();
        socket = null;
        messageCallback = null;
    },
};
