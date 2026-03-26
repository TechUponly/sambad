import { WebSocketServer, WebSocket } from 'ws';
import { Server } from 'http';
import { IncomingMessage } from 'http';
import { AppDataSource } from './db';

let wss: WebSocketServer | null = null;

// Map userId -> Set of WebSocket connections (a user can have multiple devices)
const userConnections = new Map<string, Set<WebSocket>>();

export function initWebSocketServer(server: Server) {
  wss = new WebSocketServer({ server, path: '/ws' });
  
  wss.on('connection', (ws: WebSocket, req: IncomingMessage) => {
    let userId: string | null = null;
    
    // Extract userId from query string: ws://host/ws?userId=xxx
    const url = new URL(req.url || '', `http://${req.headers.host}`);
    userId = url.searchParams.get('userId');
    
    if (userId) {
      // Register this connection for the user
      if (!userConnections.has(userId)) {
        userConnections.set(userId, new Set());
      }
      userConnections.get(userId)!.add(ws);
      console.log(`✅ WebSocket client connected: userId=${userId} (${userConnections.get(userId)!.size} connections)`);
      
      // Update last_active_at and broadcast online status
      updateUserOnlineStatus(userId, true);
    } else {
      console.log('✅ WebSocket client connected (anonymous)');
    }
    
    ws.on('message', (data) => {
      try {
        const msg = JSON.parse(data.toString());
        // Allow late registration via { type: 'register', userId: '...' }
        if (msg.type === 'register' && msg.userId) {
          // Remove from old userId if re-registering
          if (userId) {
            userConnections.get(userId)?.delete(ws);
            if (userConnections.get(userId)?.size === 0) {
              userConnections.delete(userId);
            }
          }
          userId = msg.userId;
          if (!userConnections.has(userId!)) {
            userConnections.set(userId!, new Set());
          }
          userConnections.get(userId!)!.add(ws);
          console.log(`✅ WebSocket registered: userId=${userId}`);
          ws.send(JSON.stringify({ type: 'registered', userId }));
        }
      } catch (e) {
        // ignore non-JSON messages
      }
    });
    
    ws.on('close', () => {
      if (userId) {
        userConnections.get(userId)?.delete(ws);
        if (userConnections.get(userId)?.size === 0) {
          userConnections.delete(userId);
          // Only broadcast offline if no more connections for this user
          updateUserOnlineStatus(userId, false);
        }
        console.log(`❌ WebSocket client disconnected: userId=${userId}`);
      } else {
        console.log('❌ WebSocket client disconnected (anonymous)');
      }
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

/** Send an event to a specific user (all their connected devices) */
export function sendToUser(userId: string, eventType: string, data: any) {
  const connections = userConnections.get(userId);
  if (!connections || connections.size === 0) {
    console.log(`📡 User ${userId} is offline, message queued in DB only`);
    return false;
  }
  
  const message = JSON.stringify({
    type: eventType,
    data,
    timestamp: new Date().toISOString(),
  });
  
  let sent = 0;
  connections.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
      sent++;
    }
  });
  
  console.log(`📡 Sent ${eventType} to user ${userId} (${sent} device(s))`);
  return sent > 0;
}

/** Broadcast an event to ALL connected clients */
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

/** Send a new message notification to the recipient via WebSocket */
export function emitMessageToRecipient(message: any) {
  const { toId, fromId } = message;
  // Send to recipient
  if (toId) {
    sendToUser(toId, 'new_message', message);
  }
  // Also echo back to sender (for multi-device sync)
  if (fromId && fromId !== toId) {
    sendToUser(fromId, 'message_sent', message);
  }
}

export function emitMessageSent(message: any) {
  // Use targeted delivery instead of broadcast
  emitMessageToRecipient(message);
}

export function emitUserCreated(user: any) {
  broadcastEvent('user_created', user);
}

/** Get count of online users */
export function getOnlineUserCount(): number {
  return userConnections.size;
}

/** Check if a user is online */
export function isUserOnline(userId: string): boolean {
  const connections = userConnections.get(userId);
  return !!connections && connections.size > 0;
}

/** Get all online user IDs */
export function getOnlineUserIds(): string[] {
  return Array.from(userConnections.keys());
}

/** Update user online status in DB and broadcast */
async function updateUserOnlineStatus(userId: string, online: boolean) {
  try {
    const userRepo = AppDataSource.getRepository('User');
    await userRepo.update(userId, { last_active_at: new Date() });
    
    broadcastEvent(online ? 'user_online' : 'user_offline', {
      userId,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error updating user online status:', error);
  }
}
