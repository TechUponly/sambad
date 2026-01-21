import 'reflect-metadata';
import express from 'express';
import axios from 'axios';

const USER_BACKEND = 'http://localhost:4000/api';

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.send('Sambad Admin Backend is running!');
});

// Proxy endpoints to user backend
app.get('/analytics', async (req, res) => {
  // Example analytics: total users, new users, total messages, etc.
  try {
    const [usersRes, messagesRes] = await Promise.all([
      axios.get(`${USER_BACKEND}/users`),
      axios.get(`${USER_BACKEND}/messages`),
    ]);
    const users = usersRes.data;
    const messages = messagesRes.data;
    const now = new Date();
    const today = now.toISOString().slice(0, 10);
    const newUsers = users.filter((u: any) => u.created_at && u.created_at.startsWith(today)).length;
    res.json({
      totalUsers: users.length,
      newUsers,
      totalMessages: messages.length,
    });
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch analytics', details: err.message });
  }
});

app.get('/activity', async (req, res) => {
  // Example: recent messages and contacts
  try {
    const [messagesRes, contactsRes] = await Promise.all([
      axios.get(`${USER_BACKEND}/messages`),
      axios.get(`${USER_BACKEND}/contacts`),
    ]);
    const messages = messagesRes.data.slice(0, 10).map((m: any) => ({
      description: `Message from ${m.from_user?.username || m.from_user?.id} to ${m.to_user?.username || m.to_user?.id}`,
      time: m.created_at,
    }));
    const contacts = contactsRes.data.slice(0, 10).map((c: any) => ({
      description: `Contact added: ${c.contact_user?.username || c.contact_user?.id}`,
      time: c.created_at,
    }));
    res.json([...messages, ...contacts]);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch activity', details: err.message });
  }
});

app.get('/users', async (req, res) => {
  try {
    const usersRes = await axios.get(`${USER_BACKEND}/users`);
    res.json(usersRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch users', details: err.message });
  }
});

app.get('/messages', async (req, res) => {
  try {
    const messagesRes = await axios.get(`${USER_BACKEND}/messages`);
    res.json(messagesRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch messages', details: err.message });
  }
});

app.get('/contacts', async (req, res) => {
  try {
    const contactsRes = await axios.get(`${USER_BACKEND}/contacts`);
    res.json(contactsRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch contacts', details: err.message });
  }
});

const PORT = 5050;
app.listen(PORT, () => {
  console.log(`Admin backend listening on port ${PORT}`);
});