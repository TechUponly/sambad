
import { getRepository } from 'typeorm';
import { User } from '../models/User';
import { UserConsent } from '../models/UserConsent';
import { ContactChannel } from '../models/ContactChannel';
import { UserEvent } from '../models/UserEvent';
import { AdminUser } from '../models/AdminUser';
import { AdminAuditLog } from '../models/AdminAuditLog';

export const resolvers = {
  Query: {
    users: async () => getRepository(User).find(),
    user: async (_parent: any, { id }: any) => getRepository(User).findOne(id),
    userConsents: async () => getRepository(UserConsent).find(),
    contactChannels: async () => getRepository(ContactChannel).find(),
    userEvents: async () => getRepository(UserEvent).find(),
    adminUsers: async () => getRepository(AdminUser).find(),
    adminAuditLogs: async () => getRepository(AdminAuditLog).find(),
  },
  Mutation: {
    createUser: async (_parent: any, args: any) => {
      const repo = getRepository(User);
      const user = repo.create(args);
      await repo.save(user);
      return user;
    },
    updateUser: async (_parent: any, { id, ...args }: any) => {
      const repo = getRepository(User);
      await repo.update(id, args);
      return repo.findOne(id);
    },
    createUserConsent: async (_parent: any, args: any) => {
      const repo = getRepository(UserConsent);
      const consent = repo.create(args);
      await repo.save(consent);
      return consent;
    },
    createContactChannel: async (_parent: any, args: any) => {
      const repo = getRepository(ContactChannel);
      const channel = repo.create(args);
      await repo.save(channel);
      return channel;
    },
    createUserEvent: async (_parent: any, args: any) => {
      const repo = getRepository(UserEvent);
      const event = repo.create(args);
      await repo.save(event);
      return event;
    },
    createAdminUser: async (_parent: any, args: any) => {
      const repo = getRepository(AdminUser);
      const admin = repo.create(args);
      await repo.save(admin);
      return admin;
    },
    createAdminAuditLog: async (_parent: any, args: any) => {
      const repo = getRepository(AdminAuditLog);
      const log = repo.create(args);
      await repo.save(log);
      return log;
    },
  },
};
