import cors from 'cors';
import express from 'express';
import passport from 'passport';

import config from './config';
import middleware from './middleware/auth';
import router from './routes';

const app = express();

app.use(cors());
app.use(express.json());
app.use(passport.initialize());
app.use(router);

passport.use(middleware);

const port = config.port ? config.port : 3000;

app.listen(port);
console.log(`Listening on port ${port}...`);
