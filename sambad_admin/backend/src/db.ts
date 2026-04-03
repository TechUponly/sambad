import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { AdminUser } from './models/admin_user';
import { AdminLog } from './models/admin_log';
import { Setting } from './models/setting';

const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_PORT = Number(process.env.DB_PORT || 5432);
const DB_USER = process.env.DB_USER || 'shamrai';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_NAME = process.env.DB_NAME || 'sambad_unified';

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: DB_HOST,
  port: DB_PORT,
  username: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
  entities: [AdminUser, AdminLog, Setting],
  synchronize: true,
  logging: false,
});

// Also export as AdminDataSource for backward compat
export const AdminDataSource = AppDataSource;
