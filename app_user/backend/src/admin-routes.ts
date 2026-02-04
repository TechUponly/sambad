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

export default router;
