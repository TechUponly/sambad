import { WebSocketServer, WebSocket } from 'ws';
import { Server } from 'http';

let wss: WebSocketServer | null = null;

export function initWebSocketServer(server: Server) {
  wss = new WebSocketServer({ server, path: '/ws' });
  
  wss.on('connection', (ws: WebSocket) => {
    console.log('✅ WebSocket client connected');
    
    ws.on('close', () => {
      console.log('❌ WebSocket client disconnected');
    });
    
    ws.on('error', (error) => {
      console.error('❌ WebSocket error:', error);
    });
    
    // Send welcome message
    ws.send(JSON.stringify({ type: 'connected', message: 'WebSocket connected successfully' }));
  });
  
  console.log('✅ WebSocket server initialized on /ws');
  return wss;
}

export function broadcastEvent(eventType: string, data: any) {
  if (!wss) {
    console.warn('⚠️  WebSocket server not initialized');
    return;
  }
  
  const message = JSON.stringify({
    type: eventType,
    data,
    timestamp: new Date().toISOString(),
  });
  
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
  
  console.log(`📡 Broadcasted ${eventType} to ${wss.clients.size} clients`);
}

export function emitContactAdded(contact: any) {
  broadcastEvent('contact_added', contact);
}

export function emitMessageSent(message: any) {
  broadcastEvent('message_sent', message);
}

export function emitUserCreated(user: any) {
  broadcastEvent('user_created', user);
}
