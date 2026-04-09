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
      res.send('<h1>Samvad Unified Backend</h1><p>Database: PostgreSQL</p>');
    });

    // Public endpoints (no auth required)
    // Login and health are open

    // Apply auth middleware to all /api/* routes EXCEPT login, health, and admin
    app.use('/api', (req, res, next) => {
      // Skip auth for login, health, app-config, and admin routes
      // (admin routes are called by the admin backend which has its own auth)
      const openPaths = ['/users/login', '/health', '/app-config', '/feedback'];
      if (openPaths.some(p => req.path === p)) return next();
      if (req.path.startsWith('/admin')) return next();
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
        let { phone, name } = req.body;
        
        // Normalize phone: ensure it has country code prefix
        if (phone && !phone.startsWith('+')) {
          const digits = phone.replace(/[^\d]/g, '');
          // If 10 digits, assume India (+91)
          if (digits.length === 10) {
            phone = '+91' + digits;
          } else if (digits.length > 10) {
            phone = '+' + digits;
          }
        }
        
        let user = await userRepo.findOne({ where: { phone } });
        if (!user) {
          // Also try to find without country code (backwards compatibility)
          const digits = phone.replace(/[^\d]/g, '');
          if (digits.length > 10) {
            const shortPhone = digits.substring(digits.length - 10);
            const existing = await userRepo
              .createQueryBuilder('user')
              .where("REPLACE(REPLACE(user.phone, '+', ''), '-', '') LIKE :pattern", { 
                pattern: `%${shortPhone}` 
              })
              .getOne();
            if (existing) {
              user = existing;
              // Update to normalized phone
              user.phone = phone;
              user = await userRepo.save(user);
            }
          }
          
          if (!user) {
            user = userRepo.create({ phone, name: name || null, status: 'active' });
            user = await userRepo.save(user);
          }
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

    // Delete user account and all associated data (self-delete only)
    app.delete('/api/users/:id', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const contactRepo = AppDataSource.getRepository('Contact');
        const messageRepo = AppDataSource.getRepository('Message');
        
        // Ownership check: users can only delete their own account
        const authUserId = (req as any).userId;
        if (authUserId && authUserId !== req.params.id) {
          return res.status(403).json({ error: 'You can only delete your own account' });
        }
        
        const user = await userRepo.findOne({ where: { id: req.params.id } });
        if (!user) return res.status(404).json({ error: 'User not found' });
        
        // Delete user's contacts
        await contactRepo
          .createQueryBuilder()
          .delete()
          .where('userId = :id', { id: req.params.id })
          .execute();
        
        // Delete user's messages
        await messageRepo
          .createQueryBuilder()
          .delete()
          .where('fromId = :id OR toId = :id', { id: req.params.id })
          .execute();
        
        // Delete the user
        await userRepo.remove(user);
        
        console.log(`User ${req.params.id} deleted with all associated data`);
        res.json({ success: true, message: 'Account deleted successfully' });
      } catch (error) {
        console.error('Error deleting user:', error);
        res.status(500).json({ error: 'Failed to delete account' });
      }
    });

    // Save FCM token for push notifications
    app.post('/api/users/fcm-token', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const { userId, fcm_token } = req.body;
        if (!userId || !fcm_token) {
          return res.status(400).json({ error: 'userId and fcm_token are required' });
        }
        const user = await userRepo.findOne({ where: { id: userId } });
        if (!user) return res.status(404).json({ error: 'User not found' });
        (user as any).fcm_token = fcm_token;
        await userRepo.save(user);
        res.json({ success: true });
      } catch (error) {
        console.error('Error saving FCM token:', error);
        res.status(500).json({ error: 'Failed to save FCM token' });
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
        if (req.body.age !== undefined) (user as any).age = req.body.age;
        if (req.body.gender !== undefined) (user as any).gender = req.body.gender;
        if (req.body.profile_pic_url !== undefined) (user as any).profile_pic_url = req.body.profile_pic_url;
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
        
        // Enrich with sender's phone for WebSocket receivers
        let enrichedMessage: any = { ...saved };
        if (saved.fromId) {
          const fromUser = await userRepo.findOne({ where: { id: saved.fromId } });
          if (fromUser) enrichedMessage.fromPhone = fromUser.phone;
        }
        
        // Push message to recipient via WebSocket
        emitMessageToRecipient(enrichedMessage);
        
        res.status(201).json(saved);
      } catch (error) {
        console.error('Error saving message:', error);
        res.status(500).json({ error: 'Failed to save message' });
      }
    });

    // ═══════════════════════════════════════════════
    //  GROUP API ENDPOINTS (Full-featured)
    // ═══════════════════════════════════════════════

    // Create a new group — creator is auto-admin
    app.post('/api/groups', async (req, res) => {
      try {
        const groupRepo = AppDataSource.getRepository('Group');
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const { name, description, createdBy, memberIds } = req.body;
        if (!name || !createdBy) return res.status(400).json({ error: 'name and createdBy required' });

        const group = groupRepo.create({ name, description: description || '', created_by: createdBy });
        const saved = await groupRepo.save(group);

        // Add creator as admin
        await memberRepo.save(memberRepo.create({ group_id: saved.id, user_id: createdBy, role: 'admin' }));
        const addedMembers = [createdBy];

        if (memberIds && Array.isArray(memberIds)) {
          for (const mid of memberIds) {
            if (mid !== createdBy) {
              await memberRepo.save(memberRepo.create({ group_id: saved.id, user_id: mid, role: 'member' }));
              addedMembers.push(mid);
              sendToUser(mid, 'group_added', { groupId: saved.id, groupName: name });
            }
          }
        }

        console.log(`✅ Group created: ${name} (${saved.id}), members: ${addedMembers.length}`);
        res.status(201).json({ ...saved, memberCount: addedMembers.length });
      } catch (error) {
        console.error('Error creating group:', error);
        res.status(500).json({ error: 'Failed to create group' });
      }
    });

    // List groups for a user (with role + member count)
    app.get('/api/groups', async (req, res) => {
      try {
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const groupRepo = AppDataSource.getRepository('Group');
        const userId = req.query.userId as string;
        if (!userId) return res.status(400).json({ error: 'userId required' });

        const memberships = await memberRepo.find({ where: { user_id: userId } });
        const groups = [];
        for (const m of memberships) {
          const group = await groupRepo.findOne({ where: { id: (m as any).group_id } });
          if (group) {
            const count = await memberRepo.count({ where: { group_id: (m as any).group_id } });
            groups.push({ ...group, memberCount: count, myRole: (m as any).role });
          }
        }
        res.json(groups);
      } catch (error) {
        console.error('Error fetching groups:', error);
        res.status(500).json({ error: 'Failed to fetch groups' });
      }
    });

    // Get group details with full member list
    app.get('/api/groups/:id', async (req, res) => {
      try {
        const groupRepo = AppDataSource.getRepository('Group');
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const userRepo = AppDataSource.getRepository('User');

        const group = await groupRepo.findOne({ where: { id: req.params.id } });
        if (!group) return res.status(404).json({ error: 'Group not found' });

        const memberships = await memberRepo.find({ where: { group_id: req.params.id } });
        const members = [];
        for (const m of memberships) {
          const user = await userRepo.findOne({ where: { id: (m as any).user_id } });
          members.push({
            userId: (m as any).user_id,
            role: (m as any).role,
            joinedAt: (m as any).joined_at,
            name: user ? ((user as any).username || (user as any).name || 'Unknown') : 'Unknown',
            phone: user ? (user as any).phone : '',
          });
        }
        res.json({ ...group, members, memberCount: members.length });
      } catch (error) {
        console.error('Error fetching group details:', error);
        res.status(500).json({ error: 'Failed to fetch group details' });
      }
    });

    // Update group name/description (admin only)
    app.put('/api/groups/:id', async (req, res) => {
      try {
        const groupRepo = AppDataSource.getRepository('Group');
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const { name, description, userId } = req.body;
        if (!userId) return res.status(400).json({ error: 'userId required' });

        const membership = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: userId } });
        if (!membership || (membership as any).role !== 'admin') return res.status(403).json({ error: 'Admin only' });

        const group = await groupRepo.findOne({ where: { id: req.params.id } });
        if (!group) return res.status(404).json({ error: 'Group not found' });

        if (name) (group as any).name = name;
        if (description !== undefined) (group as any).description = description;
        const updated = await groupRepo.save(group);

        const allMembers = await memberRepo.find({ where: { group_id: req.params.id } });
        for (const m of allMembers) {
          if ((m as any).user_id !== userId) {
            sendToUser((m as any).user_id, 'group_updated', { groupId: req.params.id, name: (updated as any).name, description: (updated as any).description });
          }
        }
        res.json(updated);
      } catch (error) {
        console.error('Error updating group:', error);
        res.status(500).json({ error: 'Failed to update group' });
      }
    });

    // Add member (admin only)
    app.post('/api/groups/:id/members', async (req, res) => {
      try {
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const { userId, addedBy } = req.body;
        if (!userId || !addedBy) return res.status(400).json({ error: 'userId and addedBy required' });

        const admin = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: addedBy } });
        if (!admin || (admin as any).role !== 'admin') return res.status(403).json({ error: 'Admin only' });

        const existing = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: userId } });
        if (existing) return res.status(409).json({ error: 'Already a member' });

        const member = await memberRepo.save(memberRepo.create({ group_id: req.params.id, user_id: userId, role: 'member' }));
        const groupRepo = AppDataSource.getRepository('Group');
        const group = await groupRepo.findOne({ where: { id: req.params.id } });
        sendToUser(userId, 'group_added', { groupId: req.params.id, groupName: (group as any)?.name });
        res.status(201).json(member);
      } catch (error) {
        console.error('Error adding member:', error);
        res.status(500).json({ error: 'Failed to add member' });
      }
    });

    // Remove member (admin only)
    app.delete('/api/groups/:id/members/:userId', async (req, res) => {
      try {
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const removedBy = req.query.removedBy as string;
        if (removedBy) {
          const admin = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: removedBy } });
          if (!admin || (admin as any).role !== 'admin') return res.status(403).json({ error: 'Admin only' });
        }
        await memberRepo.delete({ group_id: req.params.id, user_id: req.params.userId });
        sendToUser(req.params.userId, 'group_removed', { groupId: req.params.id });
        res.json({ success: true });
      } catch (error) {
        console.error('Error removing member:', error);
        res.status(500).json({ error: 'Failed to remove member' });
      }
    });

    // Change member role (admin only)
    app.put('/api/groups/:id/members/:userId/role', async (req, res) => {
      try {
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const { role, changedBy } = req.body;
        if (!changedBy || !['admin', 'member'].includes(role)) return res.status(400).json({ error: 'Invalid params' });

        const admin = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: changedBy } });
        if (!admin || (admin as any).role !== 'admin') return res.status(403).json({ error: 'Admin only' });

        const membership = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: req.params.userId } });
        if (!membership) return res.status(404).json({ error: 'Member not found' });

        (membership as any).role = role;
        await memberRepo.save(membership);
        sendToUser(req.params.userId, 'group_role_changed', { groupId: req.params.id, role });
        res.json({ success: true, role });
      } catch (error) {
        console.error('Error changing role:', error);
        res.status(500).json({ error: 'Failed to change role' });
      }
    });

    // Exit group (self-remove, auto-promote next admin)
    app.post('/api/groups/:id/exit', async (req, res) => {
      try {
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const { userId } = req.body;
        if (!userId) return res.status(400).json({ error: 'userId required' });

        await memberRepo.delete({ group_id: req.params.id, user_id: userId });

        // If last admin, promote next member
        const admins = await memberRepo.find({ where: { group_id: req.params.id, role: 'admin' } });
        if (admins.length === 0) {
          const next = await memberRepo.findOne({ where: { group_id: req.params.id } });
          if (next) {
            (next as any).role = 'admin';
            await memberRepo.save(next);
            sendToUser((next as any).user_id, 'group_role_changed', { groupId: req.params.id, role: 'admin' });
          } else {
            // No members left — delete group
            await AppDataSource.getRepository('Group').delete({ id: req.params.id });
          }
        }

        // Notify remaining
        const remaining = await memberRepo.find({ where: { group_id: req.params.id } });
        for (const m of remaining) {
          sendToUser((m as any).user_id, 'member_exited', { groupId: req.params.id, userId });
        }
        res.json({ success: true });
      } catch (error) {
        console.error('Error exiting group:', error);
        res.status(500).json({ error: 'Failed to exit group' });
      }
    });

    // Delete group (admin only)
    app.delete('/api/groups/:id', async (req, res) => {
      try {
        const groupRepo = AppDataSource.getRepository('Group');
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const userId = req.query.userId as string;
        if (!userId) return res.status(400).json({ error: 'userId required' });

        const membership = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: userId } });
        if (!membership || (membership as any).role !== 'admin') return res.status(403).json({ error: 'Admin only' });

        const allMembers = await memberRepo.find({ where: { group_id: req.params.id } });
        for (const m of allMembers) {
          if ((m as any).user_id !== userId) sendToUser((m as any).user_id, 'group_deleted', { groupId: req.params.id });
        }

        await memberRepo.delete({ group_id: req.params.id });
        await groupRepo.delete({ id: req.params.id });
        res.json({ success: true });
      } catch (error) {
        console.error('Error deleting group:', error);
        res.status(500).json({ error: 'Failed to delete group' });
      }
    });

    // Send group message (with sender info broadcast)
    app.post('/api/groups/:id/messages', async (req, res) => {
      try {
        const msgRepo = AppDataSource.getRepository('Message');
        const memberRepo = AppDataSource.getRepository('GroupMember');
        const userRepo = AppDataSource.getRepository('User');
        const { fromId, content } = req.body;
        if (!fromId || !content) return res.status(400).json({ error: 'fromId and content required' });

        const senderMembership = await memberRepo.findOne({ where: { group_id: req.params.id, user_id: fromId } });
        if (!senderMembership) return res.status(403).json({ error: 'Not a member' });

        const message = msgRepo.create({ from_id: fromId, to_id: req.params.id, content, status: 'sent' });
        const saved = await msgRepo.save(message);

        const sender = await userRepo.findOne({ where: { id: fromId } });
        const members = await memberRepo.find({ where: { group_id: req.params.id } });

        const enriched = {
          ...saved,
          groupId: req.params.id,
          fromPhone: (sender as any)?.phone,
          fromName: (sender as any)?.username || (sender as any)?.name || 'Unknown',
          senderRole: (senderMembership as any).role,
          isGroupMessage: true,
        };

        for (const m of members) {
          if ((m as any).user_id !== fromId) sendToUser((m as any).user_id, 'group_message', enriched);
        }
        sendToUser(fromId, 'group_message_sent', enriched);
        res.status(201).json(saved);
      } catch (error) {
        console.error('Error sending group message:', error);
        res.status(500).json({ error: 'Failed to send group message' });
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
        
        // Find which contacts are registered Samvad users
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
          invite_text: '🔒 Join me on Private Samvad — the secure messaging app!\n\n📱 Download now:\n▶ Android: https://play.google.com/store/apps/details?id=com.shamrai.sambad\n🍎 iOS: https://apps.apple.com/app/private-samvad/id6744640580',
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

    // ── User Feedback (public, auth required) ─────────────────
    app.post('/api/feedback', async (req, res) => {
      try {
        // Check if feedback is enabled via settings
        const settingRepo = AppDataSource.getRepository('Setting');
        const feedbackSetting = await settingRepo.findOne({ where: { key: 'feedback_enabled' } }) as any;
        if (feedbackSetting && feedbackSetting.value === 'false') {
          return res.status(403).json({ error: 'Feedback is currently disabled' });
        }

        const { userId, userName, userPhone, message, category, rating } = req.body;
        if (!message || !message.trim()) {
          return res.status(400).json({ error: 'Feedback message is required' });
        }

        // 100 word limit
        const wordCount = message.trim().split(/\s+/).length;
        if (wordCount > 100) {
          return res.status(400).json({ error: `Feedback must be 100 words or less (you wrote ${wordCount} words)` });
        }

        const feedbackRepo = AppDataSource.getRepository('UserFeedback');
        const fb = feedbackRepo.create({
          userId: userId || null,
          userName: userName || null,
          userPhone: userPhone || null,
          message: message.trim(),
          category: category || 'general',
          rating: Math.min(5, Math.max(1, parseInt(rating) || 5)),
          status: 'new',
        });
        const saved = await feedbackRepo.save(fb);
        res.status(201).json({ success: true, id: (saved as any).id });
      } catch (error) {
        console.error('Error saving feedback:', error);
        res.status(500).json({ error: 'Failed to save feedback' });
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

