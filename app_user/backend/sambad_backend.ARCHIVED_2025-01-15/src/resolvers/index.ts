import { adminAuthResolvers } from './adminAuth.resolver';
import { contactResolvers } from './contact.resolver';
import { adminResolvers } from './admin.resolver';

export const resolvers = {
  Query: {
    ...contactResolvers.Query,
    ...adminResolvers.Query,
  },
  Mutation: {
    ...adminAuthResolvers.Mutation,
    ...adminResolvers.Mutation,
    ...contactResolvers.Mutation,
  },
};
