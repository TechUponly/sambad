import 'dotenv/config';
import 'reflect-metadata';
import './firebase-init';
import express from 'express';
import adminRoutes from './admin-routes';
import cors from 'cors';
import { AppDataSource } from './db';
import { initWebSocketServer, emitMessageToRecipient, isUserOnline, getOnlineUserIds, sendToUser } from './websocket';
import { authenticateUser } from './middleware/auth';

console.log("DEBUG: Starting server, about to initialize DataSource...");

AppDataSource.initialize()
  .then(async () => {
    console.log('Connected to database');
    console.log('Entities loaded:', AppDataSource.entityMetadatas.map(m => m.name).join(', '));

    const app = express();
    app.use(cors());
    app.use(express.json());

    app.get('/', (req, res) => {
      res.send('<h1>Sambad Unified Backend</h1><p>Database: PostgreSQL</p>');
    });

    // Public endpoints (no auth required)
    // Login and health are open

    // Apply auth middleware to all /api/* routes EXCEPT login and health
    app.use('/api', (req, res, next) => {
      // Skip auth for login, health, and root
      const openPaths = ['/users/login', '/health', '/app-config'];
      if (openPaths.some(p => req.path === p)) return next();
      return authenticateUser(req, res, next);
    });

    // GET endpoints
    app.get('/api/users', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const limit = Math.min(parseInt(req.query.limit as string) || 50, 200);
        const offset = parseInt(req.query.offset as string) || 0;
        const users = await userRepo.find({ take: limit, skip: offset });
        res.json(users);
      } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Failed to fetch users' });
      }
    });

    app.get('/api/contacts', async (req, res) => {
      try {
        const contactRepo = AppDataSource.getRepository('Contact');
        const userId = req.query.userId as string | undefined;
        
        if (userId) {
          const contacts = await contactRepo.find({
            where: { userId },
            relations: ['user'],
          });
          return res.json(contacts);
        }
        
        // No userId — return empty (don't leak all contacts)
        res.json([]);
      } catch (error) {
        console.error('Error fetching contacts:', error);
        res.status(500).json({ error: 'Failed to fetch contacts' });
      }
    });

    app.get('/api/messages', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const userId = req.query.userId as string | undefined;
        const limit = Math.min(parseInt(req.query.limit as string) || 50, 200);
        const offset = parseInt(req.query.offset as string) || 0;
        
        if (userId) {
          const messages = await messageRepo
            .createQueryBuilder('message')
            .where('message.fromId = :userId OR message.toId = :userId', { userId })
            .orderBy('message.timestamp', 'DESC')
            .skip(offset)
            .take(limit)
            .getMany();
          return res.json(messages);
        }
        
        // No userId — return empty (don't expose all messages)
        res.json([]);
      } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: 'Failed to fetch messages' });
      }
    });

    // Get undelivered messages for a user
    app.get('/api/messages/undelivered/:userId', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const messages = await messageRepo
          .createQueryBuilder('message')
          .where('message.toId = :userId', { userId: req.params.userId })
          .andWhere('message.status = :status', { status: 'sent' })
          .orderBy('message.timestamp', 'ASC')
          .getMany();
        res.json(messages);
      } catch (error) {
        console.error('Error fetching undelivered messages:', error);
        res.status(500).json({ error: 'Failed to fetch undelivered messages' });
      }
    });

    // Mark message as delivered
    app.put('/api/messages/:id/delivered', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const message = await messageRepo.findOne({ where: { id: req.params.id } });
        if (!message) return res.status(404).json({ error: 'Message not found' });
        if (message.status === 'read') return res.json(message); // already read, don't downgrade
        
        message.status = 'delivered';
        message.delivered_at = new Date();
        const updated = await messageRepo.save(message);
        
        // Notify sender about delivery
        if (message.fromId) {
          sendToUser(message.fromId, 'message_delivered', {
            messageId: message.id,
            delivered_at: message.delivered_at
          });
        }
        
        res.json(updated);
      } catch (error) {
        console.error('Error marking delivered:', error);
        res.status(500).json({ error: 'Failed to mark as delivered' });
      }
    });

    // Mark message as read
    app.put('/api/messages/:id/read', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const message = await messageRepo.findOne({ where: { id: req.params.id } });
        if (!message) return res.status(404).json({ error: 'Message not found' });
        
        message.status = 'read';
        if (!message.delivered_at) message.delivered_at = new Date();
        message.read_at = new Date();
        const updated = await messageRepo.save(message);
        
        // Notify sender about read receipt
        if (message.fromId) {
          sendToUser(message.fromId, 'message_read', {
            messageId: message.id,
            read_at: message.read_at
          });
        }
        
        res.json(updated);
      } catch (error) {
        console.error('Error marking read:', error);
        res.status(500).json({ error: 'Failed to mark as read' });
      }
    });

    // User online/offline status
    app.get('/api/users/online', async (req, res) => {
      try {
        const onlineIds = getOnlineUserIds();
        const userRepo = AppDataSource.getRepository('User');
        
        if (onlineIds.length === 0) {
          return res.json([]);
        }
        
        const users = await userRepo
          .createQueryBuilder('user')
          .where('user.id IN (:...ids)', { ids: onlineIds })
          .getMany();
        
        res.json(users.map(u => ({
          id: u.id,
          phone: u.phone,
          name: u.name,
          online: true,
          last_active_at: u.last_active_at
        })));
      } catch (error) {
        console.error('Error fetching online users:', error);
        res.status(500).json({ error: 'Failed to fetch online users' });
      }
    });

    // POST endpoints
    app.post('/api/contacts', async (req, res) => {
      try {
        const contactRepo = AppDataSource.getRepository('Contact');
        const userRepo = AppDataSource.getRepository('User');
        
        // Handle both formats:
        // Format 1 (direct): { name, phone, userId }
        // Format 2 (Flutter): { userId, contactUserId }
        
        let contactData;
        
        if (req.body.contactUserId) {
          // Flutter format - get user details by ID
          const contactUser = await userRepo.findOne({ 
            where: { id: req.body.contactUserId } 
          });
          
          if (!contactUser) {
            return res.status(404).json({ error: 'Contact user not found' });
          }
          
          contactData = {
            name: contactUser.name || contactUser.phone,
            phone: contactUser.phone,
            userId: req.body.userId
          };
        } else {
          // Direct format
          contactData = req.body;
        }
        
        const contact = contactRepo.create(contactData);
        const saved = await contactRepo.save(contact);
        res.status(201).json(saved);
      } catch (error) {
        console.error('Error saving contact:', error);
        res.status(500).json({ error: 'Failed to save contact' });
      }
    });
    app.post('/api/users/login', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const { phone, name } = req.body;
        let user = await userRepo.findOne({ where: { phone } });
        if (!user) {
          user = userRepo.create({ phone, name: name || null, status: 'active' });
          user = await userRepo.save(user);
        } else if (name && !user.name) {
          // Update name if user exists but has no name set
          user.name = name;
          user = await userRepo.save(user);
        }
        res.json(user);
      } catch (error) {
        console.error('Error in login:', error);
        res.status(500).json({ error: 'Login failed' });
      }
    });

    // Get single user by ID
    app.get('/api/users/:id', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const user = await userRepo.findOne({ where: { id: req.params.id } });
        if (!user) return res.status(404).json({ error: 'User not found' });
        res.json({
          ...user,
          online: isUserOnline(user.id)
        });
      } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ error: 'Failed to fetch user' });
      }
    });

    // Get user online/offline status
    app.get('/api/users/:id/status', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const user = await userRepo.findOne({ where: { id: req.params.id } });
        if (!user) return res.status(404).json({ error: 'User not found' });
        res.json({
          id: user.id,
          online: isUserOnline(user.id),
          last_active_at: user.last_active_at
        });
      } catch (error) {
        console.error('Error fetching user status:', error);
        res.status(500).json({ error: 'Failed to fetch user status' });
      }
    });

    // Update user profile (name, email, etc.)
    app.put('/api/users/:id', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const user = await userRepo.findOne({ where: { id: req.params.id } });
        if (!user) return res.status(404).json({ error: 'User not found' });
        
        if (req.body.name !== undefined) user.name = req.body.name;
        if (req.body.email !== undefined) user.email = req.body.email;
        user.last_active_at = new Date();
        
        const updated = await userRepo.save(user);
        res.json(updated);
      } catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ error: 'Failed to update user' });
      }
    });

    app.post('/api/messages', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const userRepo = AppDataSource.getRepository('User');
        
        let toId = req.body.toUserId || req.body.toId;
        
        // If toId is not a UUID, try to find user by phone
        if (toId && toId.length < 30 && !toId.includes('-')) {
          const toUser = await userRepo.findOne({ where: { phone: toId } });
          if (toUser) toId = toUser.id;
        }
        
        const message = messageRepo.create({
          content: req.body.content,
          fromId: req.body.fromUserId || req.body.fromId,
          toId: toId,
        });
        const saved = await messageRepo.save(message);
        
        // Push message to recipient via WebSocket
        emitMessageToRecipient(saved);
        
        res.status(201).json(saved);
      } catch (error) {
        console.error('Error saving message:', error);
        res.status(500).json({ error: 'Failed to save message' });
      }
    });

    // Sync contacts endpoint
    app.post('/api/sync-contacts', async (req, res) => {
      try {
        const { contacts } = req.body;
        if (!contacts || !Array.isArray(contacts)) {
          return res.status(400).json({ error: 'Invalid contacts data' });
        }

        const userRepo = AppDataSource.getRepository('User');
        const contactRepo = AppDataSource.getRepository('Contact');
        
        // Find which contacts are registered Sambad users
        const phones = contacts.map(c => c.phone).filter(p => p);
        
        if (phones.length === 0) {
          return res.json({ success: true, totalContacts: contacts.length, sambadUsers: [] });
        }
        
        const registeredUsers = await userRepo
          .createQueryBuilder('user')
          .where('user.phone IN (:...phones)', { phones })
          .getMany();

        res.json({
          success: true,
          totalContacts: contacts.length,
          sambadUsers: registeredUsers.map(u => ({
            id: u.id,
            phone: u.phone,
            name: u.name
          }))
        });
      } catch (error) {
        console.error('Error syncing contacts:', error);
        res.status(500).json({ error: 'Failed to sync contacts' });
      }
    });


    app.get('/api/health', (req, res) => {
      res.json({ status: 'healthy', database: 'connected' });
    });

    // ── App Config (public, no auth) ──────────────────────────────
    // Returns client-configurable values so the app doesn't need an update
    app.get('/api/app-config', async (req, res) => {
      try {
        const settingRepo = AppDataSource.getRepository('Setting');
        const rows = await settingRepo.find();
        const config: Record<string, string> = {};
        for (const row of rows) {
          config[(row as any).key] = (row as any).value;
        }

        // Defaults (used when keys are missing from DB)
        const defaults: Record<string, string> = {
          invite_text: '🔒 Join me on Private Sambad — the secure messaging app!\n\n📱 Download now:\n▶ Android: https://play.google.com/store/apps/details?id=com.shamrai.sambad\n🍎 iOS: https://apps.apple.com/app/private-sambad/id6744640580',
        };

        res.json({ ...defaults, ...config });
      } catch (error) {
        console.error('Error fetching app config:', error);
        res.status(500).json({ error: 'Failed to fetch app config' });
      }
    });

    // Admin: update a config key
    app.put('/api/app-config', async (req, res) => {
      try {
        const settingRepo = AppDataSource.getRepository('Setting');
        const { key, value } = req.body;
        if (!key || value === undefined) {
          return res.status(400).json({ error: 'key and value are required' });
        }

        let setting = await settingRepo.findOne({ where: { key } }) as any;
        if (setting) {
          setting.value = value;
        } else {
          setting = settingRepo.create({ key, value });
        }
        const saved = await settingRepo.save(setting);
        res.json(saved);
      } catch (error) {
        console.error('Error updating app config:', error);
        res.status(500).json({ error: 'Failed to update config' });
      }
    });

    app.use('/api/admin', adminRoutes);

    const server = app.listen(4000, () => {
      console.log('Server on port 4000');
      initWebSocketServer(server);
    });
  })
  .catch((error) => {
    console.error('Database error:', error);
    process.exit(1);
  });

