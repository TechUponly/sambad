import 'dotenv/config';
import 'reflect-metadata';
import express from 'express';
import axios from 'axios';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import { initAdminDataSource, loginHandler, authMiddleware, requireRole, AuthenticatedRequest } from './middleware/auth';
import { AdminUser } from './models/admin_user';
import { AdminLog } from './models/admin_log';
import { Setting } from './models/setting';
import { seedDefaultAdmin } from './seed';

// Internal backend URL (same server, no nginx proxy needed)
const USER_BACKEND = process.env.USER_BACKEND_URL || 'http://localhost:4000/api';

const app = express();
app.use(cors());
app.use(express.json());

const PORT = 5050;

// ============================================
// HEALTH CHECK (public)
// ============================================
app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'Samvad Admin Backend', version: '2.0.0' });
});

// ============================================
// AUTH ENDPOINTS (public)
// ============================================
app.post('/auth/login', loginHandler);

app.get('/auth/me', authMiddleware, (req: AuthenticatedRequest, res) => {
  if (!req.admin) return res.status(401).json({ error: 'Not authenticated' });
  res.json({
    id: req.admin.id,
    username: req.admin.username,
    email: req.admin.email,
    role: req.admin.role,
    is_active: req.admin.is_active,
    created_at: req.admin.created_at,
    last_login_at: req.admin.last_login_at,
  });
});

app.post('/auth/change-password', authMiddleware, async (req: AuthenticatedRequest, res) => {
  try {
    const { current_password, new_password } = req.body;
    if (!current_password || !new_password) {
      return res.status(400).json({ error: 'current_password and new_password are required' });
    }
    if (new_password.length < 6) {
      return res.status(400).json({ error: 'New password must be at least 6 characters' });
    }

    const ds = await initAdminDataSource();
    const repo = ds.getRepository(AdminUser);
    const admin = await repo.findOne({ where: { id: req.admin!.id } });
    if (!admin) return res.status(404).json({ error: 'Admin not found' });

    const ok = await bcrypt.compare(current_password, admin.password_hash);
    if (!ok) return res.status(401).json({ error: 'Current password is incorrect' });

    admin.password_hash = await bcrypt.hash(new_password, 12);
    await repo.save(admin);

    // Audit log
    await logAction(ds, req.admin!.id, 'CHANGE_PASSWORD', 'admin_user', req.admin!.id);

    res.json({ message: 'Password changed successfully' });
  } catch (err: any) {
    res.status(500).json({ error: 'Failed to change password', details: err.message });
  }
});

// ============================================
// ADMIN USER MANAGEMENT (super_admin only)
// ============================================

// List all admin users
app.get('/admin-users',
  authMiddleware,
  requireRole(['super_admin', 'admin']),
  async (req: AuthenticatedRequest, res) => {
    try {
      const ds = await initAdminDataSource();
      const repo = ds.getRepository(AdminUser);
      const users = await repo.find({ order: { created_at: 'DESC' } });
      // Strip password hashes from response
      const safe = users.map(u => ({
        id: u.id,
        username: u.username,
        email: u.email,
        role: u.role,
        is_active: u.is_active,
        created_at: u.created_at,
        updated_at: u.updated_at,
        last_login_at: u.last_login_at,
      }));
      res.json(safe);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch admin users', details: err.message });
    }
  }
);

// Create admin user
app.post('/admin-users',
  authMiddleware,
  requireRole(['super_admin']),
  async (req: AuthenticatedRequest, res) => {
    try {
      const { username, email, password, role } = req.body;
      if (!username || !password) {
        return res.status(400).json({ error: 'username and password are required' });
      }
      const validRoles = ['super_admin', 'admin', 'moderator', 'viewer'];
      if (role && !validRoles.includes(role)) {
        return res.status(400).json({ error: `Invalid role. Must be one of: ${validRoles.join(', ')}` });
      }

      const ds = await initAdminDataSource();
      const repo = ds.getRepository(AdminUser);

      // Check duplicate username
      const existing = await repo.findOne({ where: { username } });
      if (existing) return res.status(409).json({ error: 'Username already exists' });

      const passwordHash = await bcrypt.hash(password, 12);
      const admin = repo.create({
        username,
        email: email || null,
        password_hash: passwordHash,
        role: role || 'moderator',
        is_active: true,
      });
      const saved = await repo.save(admin);

      // Audit log
      await logAction(ds, req.admin!.id, 'CREATE_ADMIN', 'admin_user', saved.id, { username, role: role || 'moderator' });

      res.status(201).json({
        id: saved.id,
        username: saved.username,
        email: saved.email,
        role: saved.role,
        is_active: saved.is_active,
        created_at: saved.created_at,
      });
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to create admin user', details: err.message });
    }
  }
);

// Update admin user
app.put('/admin-users/:id',
  authMiddleware,
  requireRole(['super_admin']),
  async (req: AuthenticatedRequest, res) => {
    try {
      const ds = await initAdminDataSource();
      const repo = ds.getRepository(AdminUser);
      const admin = await repo.findOne({ where: { id: req.params.id as string } });
      if (!admin) return res.status(404).json({ error: 'Admin user not found' });

      const { email, role, is_active, password } = req.body;
      const validRoles = ['super_admin', 'admin', 'moderator', 'viewer'];

      if (role !== undefined) {
        if (!validRoles.includes(role)) {
          return res.status(400).json({ error: `Invalid role. Must be one of: ${validRoles.join(', ')}` });
        }
        admin.role = role;
      }
      if (email !== undefined) admin.email = email;
      if (is_active !== undefined) admin.is_active = is_active;
      if (password) admin.password_hash = await bcrypt.hash(password, 12);

      await repo.save(admin);

      // Audit log
      await logAction(ds, req.admin!.id, 'UPDATE_ADMIN', 'admin_user', admin.id, { role, is_active });

      res.json({
        id: admin.id,
        username: admin.username,
        email: admin.email,
        role: admin.role,
        is_active: admin.is_active,
      });
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to update admin user', details: err.message });
    }
  }
);

// Delete admin user
app.delete('/admin-users/:id',
  authMiddleware,
  requireRole(['super_admin']),
  async (req: AuthenticatedRequest, res) => {
    try {
      // Can't delete yourself
      if (req.params.id === req.admin!.id) {
        return res.status(400).json({ error: 'Cannot delete your own account' });
      }

      const ds = await initAdminDataSource();
      const repo = ds.getRepository(AdminUser);
      const admin = await repo.findOne({ where: { id: req.params.id as string } });
      if (!admin) return res.status(404).json({ error: 'Admin user not found' });

      // Can't delete the last super_admin
      if (admin.role === 'super_admin') {
        const superAdminCount = await repo.count({ where: { role: 'super_admin' } });
        if (superAdminCount <= 1) {
          return res.status(400).json({ error: 'Cannot delete the last super_admin' });
        }
      }

      await repo.remove(admin);

      // Audit log
      await logAction(ds, req.admin!.id, 'DELETE_ADMIN', 'admin_user', req.params.id as string, { username: admin.username });

      res.json({ message: 'Admin user deleted' });
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to delete admin user', details: err.message });
    }
  }
);

// ============================================
// ANALYTICS ENDPOINTS (authenticated)
// ============================================

app.get('/analytics', authMiddleware, async (req, res) => {
  try {
    const [usersRes, analyticsRes] = await Promise.all([
      axios.get(`${USER_BACKEND}/admin/users`),
      axios.get(`${USER_BACKEND}/admin/analytics`),
    ]);
    const users = usersRes.data as any[];
    const analytics = analyticsRes.data as any;

    const now = new Date();
    const today = now.toISOString().slice(0, 10);
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const totalUsers = users.length;
    const newUsers = users.filter((u: any) =>
      u.created_at && u.created_at.startsWith(today)
    ).length;
    const activeUsers = users.filter((u: any) => {
      if (u.last_active_at) return new Date(u.last_active_at) >= sevenDaysAgo;
      return u.status === 'active';
    }).length;
    const inactiveUsers = totalUsers - activeUsers;
    const growth = totalUsers > 0
      ? parseFloat(((newUsers / totalUsers) * 100).toFixed(2))
      : 0;
    const totalMessages = analytics.totalMessages || 0;
    const totalContacts = analytics.totalContacts || 0;

    res.json({ totalUsers, newUsers, activeUsers, inactiveUsers, growth, totalMessages, totalContacts });
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch analytics', details: err.message });
  }
});

app.get('/activity', authMiddleware, async (req, res) => {
  try {
    const activityRes = await axios.get(`${USER_BACKEND}/admin/activity`);
    res.json(activityRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch activity', details: err.message });
  }
});

// ============================================
// PROXY ENDPOINTS (authenticated)
// ============================================

app.get('/users', authMiddleware, async (req, res) => {
  try {
    const usersRes = await axios.get(`${USER_BACKEND}/admin/users`);
    const rawUsers = usersRes.data as any[];
    const transformedUsers = rawUsers.map((user: any) => ({
      id: user.id,
      phone: user.phone,
      name: user.name || user.phone || 'Unknown User',
      email: user.email || 'Not provided',
      location: 'Not available',
      persona: 'Not calculated',
      active: user.status === 'active',
      joined: user.created_at ? new Date(user.created_at).toLocaleDateString('en-US', {
        year: 'numeric', month: 'long', day: 'numeric'
      }) : 'Unknown',
      status: user.status,
      created_at: user.created_at,
    }));
    res.json(transformedUsers);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch users', details: err.message });
  }
});

app.put('/users/:id/status',
  authMiddleware,
  requireRole(['super_admin', 'admin']),
  async (req: AuthenticatedRequest, res) => {
    try {
      const { status } = req.body;
      const userId = req.params.id as string;
      const result = await axios.put(`${USER_BACKEND}/admin/users/${userId}/status`, { status });
      await logAction(await initAdminDataSource(), req.admin!.id, 'UPDATE_USER_STATUS', 'user', userId, { status });
      res.json(result.data);
    } catch (e) {
      const err = e as Error;
      res.status(500).json({ error: 'Failed to update user status', details: err.message });
    }
  }
);

app.get('/messages', authMiddleware, async (req, res) => {
  try {
    const messagesRes = await axios.get(`${USER_BACKEND}/admin/analytics`);
    res.json(messagesRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch messages', details: err.message });
  }
});

app.get('/contacts', authMiddleware, async (req, res) => {
  try {
    const contactsRes = await axios.get(`${USER_BACKEND}/admin/activity`);
    res.json(contactsRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch contacts', details: err.message });
  }
});

// ── Feedback proxy ──────────────────────────────────────
app.get('/feedback', authMiddleware, async (req, res) => {
  try {
    const fbRes = await axios.get(`${USER_BACKEND}/admin/feedback`);
    res.json(fbRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to fetch feedback', details: err.message });
  }
});

app.put('/feedback/:id', authMiddleware, async (req, res) => {
  try {
    const fbRes = await axios.put(`${USER_BACKEND}/admin/feedback/${req.params.id}`, req.body);
    res.json(fbRes.data);
  } catch (e) {
    const err = e as Error;
    res.status(500).json({ error: 'Failed to update feedback', details: err.message });
  }
});

// ============================================
// NOTIFICATION ENDPOINTS (admin+ only)
// ============================================

app.post('/notifications/send',
  authMiddleware,
  requireRole(['super_admin', 'admin']),
  async (req: AuthenticatedRequest, res) => {
    try {
      const response = await axios.post(`${USER_BACKEND}/admin/notifications/send`, req.body);
      // Audit log
      const ds = await initAdminDataSource();
      await logAction(ds, req.admin!.id, 'SEND_NOTIFICATION', 'notification', '', { title: req.body.title, audience: req.body.audience });
      res.json(response.data);
    } catch (e) {
      const err = e as any;
      res.status(err.response?.status || 500).json({
        error: 'Failed to send notification',
        details: err.response?.data || err.message
      });
    }
  }
);

app.get('/notifications', authMiddleware, async (req, res) => {
  try {
    const response = await axios.get(`${USER_BACKEND}/admin/notifications`);
    res.json(response.data);
  } catch (e) {
    const err = e as any;
    res.status(err.response?.status || 500).json({
      error: 'Failed to fetch notifications',
      details: err.response?.data || err.message
    });
  }
});

// ============================================
// AUDIT LOG ENDPOINTS (admin+ only)
// ============================================

app.get('/audit-logs',
  authMiddleware,
  requireRole(['super_admin', 'admin']),
  async (req, res) => {
    try {
      const ds = await initAdminDataSource();
      const repo = ds.getRepository(AdminLog);
      const logs = await repo.find({
        order: { timestamp: 'DESC' },
        take: 100,
        relations: ['admin_user'],
      });
      res.json(logs.map(l => ({
        id: l.id,
        action: l.action,
        target_type: l.target_type,
        target_id: l.target_id,
        details: l.details,
        timestamp: l.timestamp,
        admin_username: l.admin_user?.username || 'Unknown',
      })));
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch audit logs', details: err.message });
    }
  }
);

// ============================================
// SETTINGS ENDPOINTS (super_admin only)
// ============================================

app.get('/settings',
  authMiddleware,
  requireRole(['super_admin']),
  async (req, res) => {
    try {
      const ds = await initAdminDataSource();
      const repo = ds.getRepository(Setting);
      const settings = await repo.find();
      res.json(settings);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch settings', details: err.message });
    }
  }
);

app.put('/settings/:key',
  authMiddleware,
  requireRole(['super_admin']),
  async (req: AuthenticatedRequest, res) => {
    try {
      const ds = await initAdminDataSource();
      const repo = ds.getRepository(Setting);
      const key = req.params.key as string;
      let setting = await repo.findOne({ where: { key } });
      if (!setting) {
        setting = repo.create({ key, value: req.body.value });
      } else {
        setting.value = req.body.value;
      }
      await repo.save(setting);
      await logAction(ds, req.admin!.id, 'UPDATE_SETTING', 'setting', key, { value: req.body.value });
      res.json(setting);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to update setting', details: err.message });
    }
  }
);

// ============================================
// HELPER: Audit logging
// ============================================

async function logAction(ds: any, adminId: string, action: string, targetType: string, targetId: string, details?: any) {
  try {
    const repo = ds.getRepository(AdminLog);
    const log = repo.create({
      admin_id: adminId,
      action,
      target_type: targetType,
      target_id: targetId,
      details: details || null,
    });
    await repo.save(log);
  } catch (e: any) {
    console.error('Audit log failed:', e.message);
  }
}

// ============================================
// STARTUP
// ============================================

async function start() {
  try {
    await initAdminDataSource();
    await seedDefaultAdmin();

    app.listen(PORT, () => {
      console.log(`\n🚀 Admin backend listening on port ${PORT}`);
      console.log(`   Auth:    POST /auth/login`);
      console.log(`   Users:   GET /admin-users`);
      console.log(`   Audit:   GET /audit-logs`);
      console.log(`   All endpoints require JWT (except /auth/login)\n`);
    });
  } catch (error: any) {
    console.error('Failed to start admin backend:', error.message);
    process.exit(1);
  }
}

start();
