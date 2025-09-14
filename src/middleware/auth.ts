import { Request, Response, NextFunction } from 'express';
import { ApiResponse } from '../types';

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    name: string;
    type: 'api_key' | 'webhook';
  };
}

// Middleware de autenticación básica para API Key
export const authenticateApiKey = (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
  const apiKey = req.headers['x-api-key'] as string;
  const expectedApiKey = process.env.API_KEY || 'norte-erp-api-key-2024';

  if (!apiKey) {
    const response: ApiResponse = {
      success: false,
      message: 'API Key requerida',
      error: 'Header x-api-key es requerido',
      timestamp: new Date().toISOString()
    };
    res.status(401).json(response);
    return;
  }

  if (apiKey !== expectedApiKey) {
    const response: ApiResponse = {
      success: false,
      message: 'API Key inválida',
      error: 'API Key proporcionada no es válida',
      timestamp: new Date().toISOString()
    };
    res.status(401).json(response);
    return;
  }

  req.user = {
    id: 'api-user',
    name: 'API User',
    type: 'api_key'
  };

  next();
};

// Middleware de autenticación para webhooks (más permisivo)
export const authenticateWebhook = (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
  const webhookSecret = req.headers['x-webhook-secret'] as string;
  const expectedSecret = process.env.WEBHOOK_SECRET || 'norte-erp-webhook-secret-2024';

  // Para webhooks, permitir sin autenticación en desarrollo
  if (process.env.NODE_ENV === 'development') {
    req.user = {
      id: 'webhook-user',
      name: 'Webhook User',
      type: 'webhook'
    };
    next();
    return;
  }

  if (!webhookSecret) {
    const response: ApiResponse = {
      success: false,
      message: 'Webhook Secret requerido',
      error: 'Header x-webhook-secret es requerido',
      timestamp: new Date().toISOString()
    };
    res.status(401).json(response);
    return;
  }

  if (webhookSecret !== expectedSecret) {
    const response: ApiResponse = {
      success: false,
      message: 'Webhook Secret inválido',
      error: 'Webhook Secret proporcionado no es válido',
      timestamp: new Date().toISOString()
    };
    res.status(401).json(response);
    return;
  }

  req.user = {
    id: 'webhook-user',
    name: 'Webhook User',
    type: 'webhook'
  };

  next();
};

// Middleware opcional de autenticación (solo si se proporciona API Key)
export const optionalAuth = (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
  const apiKey = req.headers['x-api-key'] as string;
  const expectedApiKey = process.env.API_KEY || 'norte-erp-api-key-2024';

  if (apiKey && apiKey === expectedApiKey) {
    req.user = {
      id: 'api-user',
      name: 'API User',
      type: 'api_key'
    };
  }

  next();
};