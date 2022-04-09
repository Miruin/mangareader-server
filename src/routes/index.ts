import express, { Request, Response } from 'express';
import passport from 'passport';

import { execute } from '../controllers/request';
import { login, register } from '../controllers/user';

const auth = passport.authenticate("jwt", { session: false });

const optionalAuth = (req: Request, res: Response, next: () => void) => {
  if (req.headers["authorization"]) {
    auth(req, res, next);
  } else next();
};

export const router = express.Router();

router.post("/login", login);
router.post("/register", register);
router.post("/execute/:function", optionalAuth, execute);

export default router;
