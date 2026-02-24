import { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';

declare global {
  namespace Express {
    interface Request {
      user?: admin.auth.DecodedIdToken;
    }
  }
}

export const authenticateUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized - No token provided' });
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    
    console.log(`✅ Authenticated: ${decodedToken.phone_number || decodedToken.uid}`);
    next();
  } catch (error) {
    console.error('❌ Auth error:', error);
    return res.status(401).json({ error: 'Unauthorized - Invalid token' });
  }
};
