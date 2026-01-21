"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolvers = void 0;
const adminAuth_resolver_1 = require("./adminAuth.resolver");
exports.resolvers = {
    Mutation: {
        ...adminAuth_resolver_1.adminAuthResolvers.Mutation,
    },
};
