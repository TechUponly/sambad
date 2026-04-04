import { Router } from 'express';
import { AppDataSource } from './db';
import admin from './firebase-init';
import { getOnlineUserIds } from './websocket';

const router = Router();

// Get online user IDs
router.get('/online', (req, res) => {
  res.json({ onlineUserIds: getOnlineUserIds() });
});

// Get analytics
router.get('/analytics', async (req, res) => {
  try {
    const userRepo = AppDataSource.getRepository('User');
    const messageRepo = AppDataSource.getRepository('Message');
    const contactRepo = AppDataSource.getRepository('Contact');
    
    const totalUsers = await userRepo.count();
    const totalMessages = await messageRepo.count();
    const totalContacts = await contactRepo.count();
    
    res.json({ 
      totalUsers, 
      totalMessages, 
      totalContacts 
    });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});


// Get all users
router.get('/users', async (req, res) => {
  try {
    const userRepo = AppDataSource.getRepository('User');
    const users = await userRepo.find({
      order: { created_at: 'DESC' },
      take: 100
    });
    res.json(users);
  } catch (error) {
    console.error('Users error:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Get recent activity
router.get('/activity', async (req, res) => {
  try {
    const messageRepo = AppDataSource.getRepository('Message');
    const contactRepo = AppDataSource.getRepository('Contact');
    
    const recentMessages = await messageRepo.find({
      order: { timestamp: 'DESC' },
      take: 10,
      relations: ['from_user', 'to_user']
    });
    
    const recentContacts = await contactRepo.find({
      order: { created_at: 'DESC' },
      take: 10
    });
    
    const activity = [
      ...recentMessages.map(m => ({
        type: 'message',
        timestamp: m.timestamp,
        data: { content: m.content, from: m.fromId, to: m.toId }
      })),
      ...recentContacts.map(c => ({
        type: 'contact_added',
        timestamp: c.created_at,
        data: { contactId: c.id }
      }))
    ].sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
    
    res.json(activity);
  } catch (error) {
    console.error('Activity error:', error);
    res.status(500).json({ error: 'Failed to fetch activity' });
  }
});

// ── Push Notifications ───────────────────────────────────────

// Send notification to users via FCM
router.post('/notifications/send', async (req, res) => {
  try {
    const userRepo = AppDataSource.getRepository('User');
    const notificationRepo = AppDataSource.getRepository('Notification');
    const { title, body, audience, target_user_ids } = req.body;

    if (!title || !body) {
      return res.status(400).json({ error: 'title and body are required' });
    }

    // Get target users with FCM tokens
    let users: any[];
    if (audience === 'specific' && target_user_ids?.length) {
      users = await userRepo
        .createQueryBuilder('user')
        .where('user.id IN (:...ids)', { ids: target_user_ids })
        .andWhere('user.fcm_token IS NOT NULL')
        .getMany();
    } else {
      users = await userRepo
        .createQueryBuilder('user')
        .where('user.fcm_token IS NOT NULL')
        .getMany();
    }

    const tokens = users.map((u: any) => u.fcm_token).filter(Boolean);

    let sentCount = 0;
    let failedCount = 0;

    if (tokens.length > 0) {
      const batchSize = 500;
      for (let i = 0; i < tokens.length; i += batchSize) {
        const batch = tokens.slice(i, i + batchSize);
        try {
          const response = await admin.messaging().sendEachForMulticast({
            tokens: batch,
            notification: { title, body },
            android: { priority: 'high' as const },
            apns: { payload: { aps: { sound: 'default', badge: 1 } } },
          });
          sentCount += response.successCount;
          failedCount += response.failureCount;
        } catch (fcmError) {
          console.error('FCM batch error:', fcmError);
          failedCount += batch.length;
        }
      }
    }

    // Save notification record
    const notification = notificationRepo.create({
      title,
      body,
      audience: audience || 'all',
      target_user_ids: target_user_ids ? JSON.stringify(target_user_ids) : null,
      sent_count: sentCount,
      failed_count: failedCount,
    });
    const saved = await notificationRepo.save(notification);

    res.json({
      ...saved,
      total_tokens: tokens.length,
      sent_count: sentCount,
      failed_count: failedCount,
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ error: 'Failed to send notification' });
  }
});

// List sent notifications
router.get('/notifications', async (req, res) => {
  try {
    const notificationRepo = AppDataSource.getRepository('Notification');
    const notifications = await notificationRepo.find({
      order: { created_at: 'DESC' },
      take: 50,
    });
    res.json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// Update user status (ban/deactivate/activate)
router.put('/users/:id/status', async (req, res) => {
  try {
    const userRepo = AppDataSource.getRepository('User');
    const { status } = req.body;
    if (!['active', 'banned', 'deactivated'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status. Must be: active, banned, or deactivated' });
    }
    const user = await userRepo.findOne({ where: { id: req.params.id } });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    (user as any).status = status;
    await userRepo.save(user);
    res.json({ success: true, userId: req.params.id, status });
  } catch (error) {
    console.error('Update user status error:', error);
    res.status(500).json({ error: 'Failed to update user status' });
  }
});

export default router;
