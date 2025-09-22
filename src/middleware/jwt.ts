import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "dev-secret-change";

export interface JWTUser {
  id: number;
  username: string;
  role: 'admin' | 'manager' | 'employee' | 'viewer' | 'gerencia' | 'ventas' | 'logistica' | 'finanzas';
}

export interface AuthenticatedRequest extends Request {
  user?: JWTUser;
}

export const authenticateJWT = (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ success: false, message: "Missing Authorization header" });
  }
  const token = authHeader.substring(7);
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    req.user = {
      id: parseInt(decoded.sub, 10),
      username: decoded.username,
      role: decoded.role
    };
    return next();
  } catch (err) {
    return res.status(401).json({ success: false, message: "Invalid or expired token" });
  }
};

export const authorizeRoles = (...roles: Array<JWTUser['role']>) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) return res.status(401).json({ success: false, message: "Unauthorized" });
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: "Forbidden: insufficient role" });
    }
    return next();
  };
};

export const optionalAuthenticateJWT = (req: AuthenticatedRequest, _res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith("Bearer ")) {
    const token = authHeader.substring(7);
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as any;
      req.user = {
        id: parseInt(decoded.sub, 10),
        username: decoded.username,
        role: decoded.role
      };
    } catch (_err) {
      // ignore invalid token in optional mode
    }
  }
  return next();
};
