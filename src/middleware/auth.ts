import { ExtractJwt, Strategy } from 'passport-jwt';

import config from '../config';

const options = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: config.secretKey,
};

export default new Strategy(options, (id, done) => done(null, id));
