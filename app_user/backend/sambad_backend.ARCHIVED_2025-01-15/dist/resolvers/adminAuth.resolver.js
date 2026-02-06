"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminAuthResolvers = void 0;
exports.adminAuthResolvers = {
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
