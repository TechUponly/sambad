import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { AppDataSource } from '../data-source';
import { AdminUser } from '../models/admin_user';
import { AdminLog } from '../models/admin_log';

export interface AuthenticatedRequest extends Request {
  admin?: AdminUser;
}

const JWT_SECRET = process.env.ADMIN_JWT_SECRET || 'dev-admin-secret';

export async function initDataSource() {
  try {
    if (!AppDataSource.isInitialized) {
      console.log('🔄 Initializing database connection...');
      await AppDataSource.initialize();
      console.log('✅ Database connected successfully');
    }
    return AppDataSource;
  } catch (error: any) {
    console.error('❌ Database connection failed:', error.message);
    if (error.message.includes('jsonb')) {
      console.error('   SQLite compatibility issue - trying to fix...');
    } else {
      console.error('   Check your database is running and credentials are correct');
    }
    throw error;
  }
}

export async function loginHandler(req: Request, res: Response) {
  const { username, password } = req.body || {};

  if (typeof username !== 'string' || typeof password !== 'string') {
    return res.status(400).json({ error: 'INVALID_INPUT', message: 'Username and password are required.' });
  }

  try {
    let ds;
    try {
      ds = await initDataSource();
    } catch (dbError: any) {
      console.error('⚠️  Database not connected:', dbError.message);
      return res.status(503).json({ 
        error: 'DATABASE_ERROR', 
        message: 'Database connection is required for login. Please check your PostgreSQL database is running and configured.' 
      });
    }
    
    const repo = ds.getRepository(AdminUser);

    const admin = await repo.findOne({ where: { username } });
    if (!admin) {
      return res.status(401).json({ error: 'INVALID_CREDENTIALS', message: 'Invalid username or password.' });
    }

    const ok = await bcrypt.compare(password, admin.password_hash);
    if (!ok) {
      return res.status(401).json({ error: 'INVALID_CREDENTIALS', message: 'Invalid username or password.' });
    }

    const token = jwt.sign(
      {
        sub: admin.id,
        role: admin.role,
        username: admin.username,
      },
      JWT_SECRET,
      { expiresIn: '8h' }
    );

    // Basic audit log for login
    try {
      const logRepo = ds.getRepository(AdminLog);
      const log = logRepo.create({
        admin_user_id: admin.id,
        action: 'LOGIN',
        target_type: 'admin_user',
        target_id: admin.id,
        details: JSON.stringify({ username: admin.username }),
      });
      await logRepo.save(log);
    } catch (logError: any) {
      // Log error but don't fail login
      console.error('Failed to create audit log:', logError.message);
    }

    return res.json({
      token,
      admin: {
        id: admin.id,
        username: admin.username,
        email: admin.email,
        role: admin.role,
      },
    });
  } catch (err) {
    // Avoid leaking internals
    return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to login admin.' });
  }
}

export async function authMiddleware(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Missing or invalid Authorization header.' });
  }

  const token = authHeader.substring('Bearer '.length);

  try {
    const payload = jwt.verify(token, JWT_SECRET) as { sub: string; role: string };
    const ds = await initDataSource();
    const repo = ds.getRepository(AdminUser);
    const admin = await repo.findOne({ where: { id: payload.sub } });

    if (!admin) {
      return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Admin not found.' });
    }

    req.admin = admin;
    return next();
  } catch {
    return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Invalid or expired token.' });
  }
}

export function requireRole(allowedRoles: string[]) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.admin) {
      return res.status(401).json({ error: 'UNAUTHORIZED', message: 'Admin not authenticated.' });
    }
    if (!allowedRoles.includes(req.admin.role)) {
      return res.status(403).json({ error: 'FORBIDDEN', message: 'Insufficient permissions.' });
    }
    return next();
  };
}
