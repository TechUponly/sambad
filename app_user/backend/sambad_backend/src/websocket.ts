// WebSocket server for Sambad backend (2025-12-31)
import { Server } from 'ws';
import type { WebSocket, Data } from 'ws';

export function setupWebSocketServer(server: any) {
  const wss = new Server({ server });
  wss.on('connection', (ws: WebSocket) => {
    ws.send(JSON.stringify({ type: 'welcome', message: 'WebSocket connected' }));
    ws.on('message', (msg: Data) => {
      // Optionally handle messages from clients (admin dashboard)
    });
  });
  // Broadcast helper
  (wss as any).broadcast = (data: any) => {
    wss.clients.forEach((client: WebSocket) => {
      if (client.readyState === 1) {
        client.send(JSON.stringify(data));
      }
    });
  };
  return wss;
}
