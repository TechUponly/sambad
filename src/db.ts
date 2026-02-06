import "reflect-metadata";
import { DataSource } from "typeorm";

import { User } from "./models/user";
import { AdminUser } from "./models/admin_user";
import { AdminLog } from "./models/admin_log";
import { Contact } from "./models/contact";
import { Message } from "./models/message";
import { Group } from "./models/group";
import { GroupMember } from "./models/group_member";
import { Setting } from "./models/setting";

const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_PORT = Number(process.env.DB_PORT || 5432);
const DB_USER = process.env.DB_USER || 'shamrai';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_NAME = process.env.DB_NAME || 'sambad';

export const AppDataSource = new DataSource({
  type: "postgres",
  host: DB_HOST,
  port: DB_PORT,
  username: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
  entities: [User, AdminUser, AdminLog, Contact, Message, Group, GroupMember, Setting],
  synchronize: false,
  logging: true,
});