"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.signJwt = signJwt;
exports.verifyJwt = verifyJwt;
exports.authMiddleware = authMiddleware;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const JWT_SECRET = process.env.JWT_SECRET || 'changeme';
function signJwt(payload) {
    return jsonwebtoken_1.default.sign(payload, JWT_SECRET, { expiresIn: '7d' });
}
function verifyJwt(token) {
    try {
        return jsonwebtoken_1.default.verify(token, JWT_SECRET);
    }
    catch {
        return null;
    }
}
function authMiddleware(req, res, next) {
    const auth = req.headers.authorization;
    if (auth && auth.startsWith('Bearer ')) {
        const token = auth.slice(7);
        const user = verifyJwt(token);
        if (user)
            req.user = user;
    }
    next();
}
