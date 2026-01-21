import { AppDataSource } from '../db';
import { ContactChannel } from '../models/ContactChannel';
import { User } from '../models/User';

export const contactResolvers = {
  Query: {
    contactChannels: async (_: any, args: { userId?: string }) => {
      const repo = AppDataSource.getRepository(ContactChannel);
      if (args.userId) {
        return await repo.find({ where: { user_id: args.userId } });
      }
      return await repo.find();
    },
  },
  Mutation: {
    createContactChannel: async (
      _: any,
      args: { userId: string; channel: string; address: string }
    ) => {
      const contactRepo = AppDataSource.getRepository(ContactChannel);
      const userRepo = AppDataSource.getRepository(User);
      
      // Verify user exists
      const user = await userRepo.findOne({ where: { id: args.userId } });
      if (!user) {
        throw new Error('User not found');
      }

      // Create contact channel
      const contact = contactRepo.create({
        user_id: args.userId,
        channel: args.channel,
        address: args.address,
        verified: false,
      });

      const saved = await contactRepo.save(contact);
      return {
        id: saved.id,
        userId: saved.user_id,
        channel: saved.channel,
        address: saved.address,
        verified: saved.verified,
        createdAt: saved.created_at.toISOString(),
      };
    },
  },
};