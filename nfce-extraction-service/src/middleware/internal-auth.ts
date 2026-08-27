import { NextFunction, Request, Response } from 'express';

const INTERNAL_KEY_HEADER = 'x-internal-key';

// Fails closed: a missing X_INTERNAL_KEY env var must never be treated as
// "no key required" (an unset expected key would otherwise match an absent header).
export function internalAuth(req: Request, res: Response, next: NextFunction): void {
  const expectedKey = process.env.X_INTERNAL_KEY;
  const providedKey = req.header(INTERNAL_KEY_HEADER);

  if (!expectedKey || providedKey !== expectedKey) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }

  next();
}
