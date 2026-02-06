"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.typeDefs = void 0;
const apollo_server_express_1 = require("apollo-server-express");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
exports.typeDefs = (0, apollo_server_express_1.gql)(fs_1.default.readFileSync(path_1.default.join(__dirname, 'schema.graphql'), 'utf8'));
