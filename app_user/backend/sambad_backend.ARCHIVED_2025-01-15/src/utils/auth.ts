// Extend Express Request type to include 'user' property
declare module 'express-serve-static-core' {
  interface Request {
    user?: any;
  }
}
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'changeme';

export function signJwt(payload: object) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });
}

export function verifyJwt(token: string) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch {
    return null;
  }
}

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const auth = req.headers.authorization;
  if (auth && auth.startsWith('Bearer ')) {
    const token = auth.slice(7);
    const decoded = verifyJwt(token);
    if (decoded) {
      // Store decoded token info (includes role for admin, user info for regular users)
      req.user = decoded as any;
    }
  }
  next();
}
