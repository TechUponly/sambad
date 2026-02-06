import { Router } from 'express';
import { AppDataSource } from './db';

const router = Router();

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
    
    // Get recent messages and contacts
    const recentMessages = await messageRepo.find({
      order: { timestamp: 'DESC' },
      take: 10,
      relations: ['from', 'to']
    });
    
    const recentContacts = await contactRepo.find({
      order: { created_at: 'DESC' },
      take: 10
    });
    
    // Format activity feed
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

export default router;
