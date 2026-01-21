"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupWebSocketServer = setupWebSocketServer;
// WebSocket server for Sambad backend (2025-12-31)
const ws_1 = require("ws");
function setupWebSocketServer(server) {
    const wss = new ws_1.Server({ server });
    wss.on('connection', (ws) => {
        ws.send(JSON.stringify({ type: 'welcome', message: 'WebSocket connected' }));
        ws.on('message', (msg) => {
            // Optionally handle messages from clients (admin dashboard)
        });
    });
    // Broadcast helper
    wss.broadcast = (data) => {
        wss.clients.forEach((client) => {
            if (client.readyState === 1) {
                client.send(JSON.stringify(data));
            }
        });
    };
    return wss;
}
