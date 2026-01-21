export const adminAuthResolvers = {
  Mutation: {
    adminLogin: async () => {
      return {
        token: "TEMP_TOKEN",
        admin: {
          id: "temp-id",
          email: "admin@example.com",
          role: "super_admin",
        },
      };
    },
  },
};
