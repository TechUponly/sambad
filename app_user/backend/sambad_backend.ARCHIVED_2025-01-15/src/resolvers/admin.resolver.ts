import { AppDataSource } from '../db';
import { User } from '../models/User';
import { ContactChannel } from '../models/ContactChannel';
import { UserEvent } from '../models/UserEvent';
import { AdminUser } from '../models/AdminUser';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || process.env.ADMIN_JWT_SECRET || 'dev-secret';

// Helper to check user role from context
function hasRole(context: any, allowedRoles: string[]): boolean {
  if (!context || !context.user || !context.user.role) return false;
  return allowedRoles.includes(context.user.role);
}

export const adminResolvers = {
  Query: {
    adminUsers: async (_: any, __: any, context: any) => {
      if (!hasRole(context, ['superadmin', 'admin', 'moderator', 'viewer'])) {
        throw new Error('Unauthorized: Admin access required');
      }

      const userRepo = AppDataSource.getRepository(User);
      const users = await userRepo.find({ order: { created_at: 'DESC' as any } }).catch(() => []);
      
      return users.map((u: any) => ({
        id: u.id,
        username: u.username || u.phone || 'N/A',
        phone: u.phone || u.username || 'N/A',
        email: u.email || 'N/A',
        name: u.name || u.username || u.phone || 'N/A',
        status: u.status || 'active',
        createdAt: u.created_at?.toISOString() || new Date().toISOString(),
        lastActiveAt: u.last_active_at?.toISOString() || null,
      }));
    },

    adminAnalytics: async (_: any, __: any, context: any) => {
      if (!hasRole(context, ['superadmin', 'admin', 'moderator'])) {
        throw new Error('Unauthorized: Admin access required');
      }

      const userRepo = AppDataSource.getRepository(User);
      const contactRepo = AppDataSource.getRepository(ContactChannel);
      
      const users = await userRepo.find();
      const contacts = await contactRepo.find();
      
      const now = new Date();
      const today = now.toISOString().slice(0, 10);
      const newUsers = users.filter((u: any) => 
        u.created_at && u.created_at.toISOString().startsWith(today)
      ).length;
      
      return {
        totalUsers: users.length,
        newUsers: newUsers,
        totalContacts: contacts.length,
      };
    },

    adminActivity: async (_: any, __: any, context: any) => {
      if (!hasRole(context, ['superadmin', 'admin', 'moderator'])) {
        throw new Error('Unauthorized: Admin access required');
      }

      const eventRepo = AppDataSource.getRepository(UserEvent);
      const contactRepo = AppDataSource.getRepository(ContactChannel);
      
      const userEvents = await eventRepo.find({ 
        order: { created_at: 'DESC' as any }, 
        take: 10 
      }).catch(() => []);
      const contactChannels = await contactRepo.find({ 
        order: { created_at: 'DESC' as any }, 
        take: 10 
      }).catch(() => []);
      
      const activity = [
        ...userEvents.map((e: any) => ({
          description: `Event: ${e.event_type || 'unknown'}`,
          time: e.created_at?.toISOString() || new Date().toISOString(),
        })),
        ...contactChannels.map((c: any) => ({
          description: `Contact channel added: ${c.channel || 'unknown'} - ${c.address || 'unknown'}`,
          time: c.created_at?.toISOString() || new Date().toISOString(),
        })),
      ];
      
      return activity.sort((a, b) => b.time.localeCompare(a.time)).slice(0, 10);
    },

    adminContacts: async (_: any, __: any, context: any) => {
      if (!hasRole(context, ['superadmin', 'admin', 'moderator'])) {
        throw new Error('Unauthorized: Admin access required');
      }

      const contactRepo = AppDataSource.getRepository(ContactChannel);
      const contacts = await contactRepo.find({ order: { created_at: 'DESC' as any } }).catch(() => []);
      
      return contacts.map((c: any) => ({
        id: c.id,
        userId: c.user_id,
        channel: c.channel,
        address: c.address,
        verified: c.verified,
        createdAt: c.created_at?.toISOString() || new Date().toISOString(),
      }));
    },
  },

  Mutation: {
    adminLogin: async (_: any, args: { username: string; password: string }) => {
      const adminRepo = AppDataSource.getRepository(AdminUser);
      
      // AdminUser uses email as the identifier (username field doesn't exist)
      const admin = await adminRepo.findOne({ 
        where: { email: args.username } 
      });
      
      if (!admin) {
        throw new Error('Invalid username or password');
      }

      const isValid = await bcrypt.compare(args.password, admin.password_hash);
      if (!isValid) {
        throw new Error('Invalid username or password');
      }

      const token = jwt.sign(
        { 
          id: admin.id, 
          email: admin.email, 
          role: admin.role,
          type: 'admin' // Mark as admin token
        },
        JWT_SECRET,
        { expiresIn: '24h' }
      );

      return {
        token,
        admin: {
          id: admin.id,
          email: admin.email,
          role: admin.role,
        },
      };
    },
  },
};