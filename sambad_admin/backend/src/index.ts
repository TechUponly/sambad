import 'reflect-metadata';
import express from 'express';
import axios from 'axios';
import cors from 'cors';

// Production backend URL
const USER_BACKEND = 'https://web.uponlytech.com/sambad-backend/api';

const app = express();
app.use(cors());
app.use(express.json());

const PORT = 5050;

// Health check
app.get('/', (req, res) => {
  res.send('Sambad Admin Backend is running!');
});

// ============================================
// ANALYTICS ENDPOINTS
// ============================================

// Dashboard analytics with calculated metrics
app.get('/analytics', async (req, res) => {
  try {
    const [usersRes, messagesRes] = await Promise.all([
      axios.get(`${USER_BACKEND}/users`),
      axios.get(`${USER_BACKEND}/messages`),
    ]);
    
    const users = usersRes.data;
    const messages = messagesRes.data;
    
    // Calculate date thresholds
    const now = new Date();
    const today = now.toISOString().slice(0, 10);
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    
    // Total users
    const totalUsers = users.length;
    
    // New users (created today)
    const newUsers = users.filter((u: any) => 
      u.created_at && u.created_at.startsWith(today)
    ).length;
    
    // Active users (last_active_at within 7 days OR status='active')
    const activeUsers = users.filter((u: any) => {
      if (u.last_active_at) {
        const lastActive = new Date(u.last_active_at);
        return lastActive >= sevenDaysAgo;
      }
      // Fallback: if no last_active_at, use status field
      return u.status === 'active';
    }).length;
    
    // Inactive users
    const inactiveUsers = totalUsers - activeUsers;
    
    // Growth rate (percentage of new users)
    const growth = totalUsers > 0 
      ? parseFloat(((newUsers / totalUsers) * 100).toFixed(2))
      : 0;
    
    // Total messages
    const totalMessages = messages.length;
    
    res.json({
      totalUsers,
      newUsers,
      activeUsers,
      inactiveUsers,
      growth,
      totalMessages,
    });
  } catch (e) {
    const err = e as Error;
    console.error('Analytics error:', err.message);
    res.status(500).json({ 
      error: 'Failed to fetch analytics', 
      details: err.message 
    });
  }
});

// Recent activity feed
app.get('/activity', async (req, res) => {
  try {
    const [messagesRes, contactsRes] = await Promise.all([
      axios.get(`${USER_BACKEND}/messages`),
      axios.get(`${USER_BACKEND}/contacts`),
    ]);
    
    const messages = messagesRes.data.slice(0, 10).map((m: any) => ({
      description: `Message from ${m.from_user?.phone || m.from_user_id} to ${m.to_user?.phone || m.to_user_id}`,
      time: m.created_at,
    }));
    
    const contacts = contactsRes.data.slice(0, 5).map((c: any) => ({
      description: `Contact added: ${c.name} (${c.phone})`,
      time: c.created_at || new Date().toISOString(),
    }));
    
    const activity = [...messages, ...contacts].sort((a, b) => 
      new Date(b.time).getTime() - new Date(a.time).getTime()
    );
    
    res.json(activity.slice(0, 10));
  } catch (e) {
    const err = e as Error;
    console.error('Activity error:', err.message);
    res.status(500).json({ 
      error: 'Failed to fetch activity', 
      details: err.message 
    });
  }
});

// ============================================
// PROXY ENDPOINTS (unchanged)
// ============================================

app.get('/users', async (req, res) => {
  try {
    const usersRes = await axios.get(`${USER_BACKEND}/users`);
    const rawUsers = usersRes.data;
    
    const transformedUsers = rawUsers.map((user: any) => ({
      id: user.id,
      phone: user.phone,
      name: user.name || user.phone || 'Unknown User',
      email: user.email || 'Not provided',
      location: 'Not available',
      persona: 'Not calculated',
      active: user.status === 'active',
      joined: user.created_at ? new Date(user.created_at).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      }) : 'Unknown',
      status: user.status,
      created_at: user.created_at,
    }));
    
    res.json(transformedUsers);
  } catch (e) {
    const err = e as Error;
    console.error('Users error:', err.message);
    res.status(500).json({ error: 'Failed to fetch users', details: err.message });
  }
});
app.get('/messages', async (req, res) => {
  try {
    const messagesRes = await axios.get(`${USER_BACKEND}/messages`);
    res.json(messagesRes.data);
  } catch (e) {
    const err = e as Error;
    console.error('Messages error:', err.message);
    res.status(500).json({ 
      error: 'Failed to fetch messages', 
      details: err.message 
    });
  }
});

app.get('/contacts', async (req, res) => {
  try {
    const contactsRes = await axios.get(`${USER_BACKEND}/contacts`);
    res.json(contactsRes.data);
  } catch (e) {
    const err = e as Error;
    console.error('Contacts error:', err.message);
    res.status(500).json({ 
      error: 'Failed to fetch contacts', 
      details: err.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Admin backend listening on port ${PORT}`);
});
