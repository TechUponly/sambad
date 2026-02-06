import 'reflect-metadata';
import express from 'express';
import dotenv from 'dotenv';
import { DataSource } from 'typeorm';
import { authMiddleware, loginHandler, requireRole } from './middleware/auth';

dotenv.config();

const PORT = Number(process.env.ADMIN_PORT || 5050);
const USER_DB_PATH = process.env.USER_DB_PATH || '/Users/shamrai/Desktop/sambad/app_user/backend/sambad_backend/sambad.db';

const app = express();
app.use(express.json());
app.use('/test-dashboard', express.static('public'));

app.get('/', (_req, res) => {
  res.send('Sambad Admin Backend is running!');
});

app.post('/login', loginHandler);
app.use(authMiddleware);

// Lazy DB connection
let userDb: DataSource | null = null;
async function getUserDB() {
  if (!userDb) {
    userDb = new DataSource({ type: 'sqlite', database: USER_DB_PATH, synchronize: false, logging: false, entities: [] });
    if (!userDb.isInitialized) await userDb.initialize();
  }
  return userDb;
}

app.get('/analytics', requireRole(['superadmin', 'admin', 'moderator']), async (_req, res) => {
  try {
    const db = await getUserDB();
    const users = await db.query('SELECT * FROM users');
    const messages = await db.query('SELECT * FROM messages');
    const today = new Date().toISOString().slice(0, 10);
    res.json({
      totalUsers: users.length,
      newUsers: users.filter((u: any) => u.created_at?.startsWith(today)).length,
      totalMessages: messages.length,
    });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/users', requireRole(['superadmin', 'admin', 'moderator', 'viewer']), async (_req, res) => {
  try {
    const db = await getUserDB();
    const users = await db.query('SELECT * FROM users ORDER BY created_at DESC');
    res.json(users.map((u: any) => ({
      id: u.id,
      username: u.username || u.phone,
      phone: u.phone,
      email: u.email,
      name: u.name || u.username || u.phone,
      status: u.status || 'active',
      created_at: u.created_at,
    })));
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/activity', requireRole(['superadmin', 'admin', 'moderator']), async (_req, res) => {
  try {
    const db = await getUserDB();
    const messages = await db.query('SELECT * FROM messages ORDER BY created_at DESC LIMIT 10');
    const contacts = await db.query('SELECT * FROM contacts ORDER BY created_at DESC LIMIT 10');
    res.json([
      ...messages.map((m: any) => ({ description: `Message from ${m.from_user_id}`, time: m.created_at })),
      ...contacts.map((c: any) => ({ description: `Contact added: ${c.contact_user_id}`, time: c.created_at })),
    ]);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/messages', requireRole(['superadmin', 'admin', 'moderator']), async (_req, res) => {
  try {
    const db = await getUserDB();
    res.json(await db.query('SELECT * FROM messages ORDER BY created_at DESC'));
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/contacts', requireRole(['superadmin', 'admin', 'moderator']), async (_req, res) => {
  try {
    const db = await getUserDB();
    res.json(await db.query('SELECT * FROM contacts ORDER BY created_at DESC'));
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Admin backend on port ${PORT}`);
  console.log(`🌐 http://localhost:${PORT}/`);
}).on('error', (err: any) => {
  console.error('Server error:', err.message);
  process.exit(1);
});
