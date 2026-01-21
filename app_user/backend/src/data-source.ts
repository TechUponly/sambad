import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { SnakeNamingStrategy } from 'typeorm-naming-strategies';
import { User } from './models/user';
import { Contact } from './models/contact';
import { Group } from './models/group';
import { GroupMember } from './models/group_member';
import { Message } from './models/message';
import { AdminUser } from './models/admin_user';
import { AdminLog } from './models/admin_log';
import { Setting } from './models/setting';

// Use SQLite for development, PostgreSQL for production
const useSqlite = process.env.DB_TYPE === 'sqlite' || !process.env.DB_HOST || process.env.DB_HOST === 'localhost' && !process.env.DB_USER;

export const AppDataSource = new DataSource({
  type: useSqlite ? 'better-sqlite3' : 'postgres',
  // SQLite configuration
  ...(useSqlite ? {
    database: process.env.DB_NAME || 'sambad_user.db',
  } : {
    // PostgreSQL configuration
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 5432),
    username: process.env.DB_USER || 'your_db_user',
    password: process.env.DB_PASSWORD || 'your_db_password',
    database: process.env.DB_NAME || 'sambad_user',
  }),
  synchronize: true, // Auto-create tables for SQLite dev
  logging: process.env.NODE_ENV !== 'production',
  entities: [User, Contact, Group, GroupMember, Message, AdminUser, AdminLog, Setting],
  migrations: ['src/migration/**/*.ts'],
  namingStrategy: new SnakeNamingStrategy(),
});
