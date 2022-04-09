import { readFileSync } from 'fs';
import * as path from 'path';

interface databaseT {
  host: string;
  user: string;
  password: string;
  database: string;
  port: string;
}

interface configT {
  secretKey: string;
  port?: string;
  database: {
    development: databaseT;
    test: databaseT;
    production: databaseT;
  };
}

function makeConfig(): configT {
  try {
    const json: configT = JSON.parse(
      readFileSync(path.join(__dirname, "../config.json"), {
        encoding: "utf-8",
      })
    );
    return json;
  } catch (e) {
    console.error(`Error loading config file: ${e.toString()}`);
    return undefined;
  }
}

const config: configT = process.env.USE_ENV ? undefined : makeConfig();

if (!process.env.USE_ENV) {
  const required = ["database", "secretKey"];

  for (const key of required)
    if (!config[key]) throw new Error(`${key} is required in config.json`);
}

export default process.env.USE_ENV
  ? {
      secretKey: process.env.SECRET_KEY,
      port: process.env.PORT,
      database: {
        development: {
          user: process.env.DATABASE_USER,
          password: process.env.DATABASE_PASS,
          database: process.env.DATABASE_NAME,
          host: process.env.DATABASE_HOST,
          port: process.env.DATABASE_PORT,
        },
        test: {
          user: process.env.DATABASE_USER,
          password: process.env.DATABASE_PASS,
          database: process.env.DATABASE_NAME,
          host: process.env.DATABASE_HOST,
          port: process.env.DATABASE_PORT,
        },
        production: {
          user: process.env.DATABASE_USER,
          password: process.env.DATABASE_PASS,
          database: process.env.DATABASE_NAME,
          host: process.env.DATABASE_HOST,
          port: process.env.DATABASE_PORT,
        },
      },
    }
  : config;
