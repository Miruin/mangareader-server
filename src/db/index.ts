import fs from 'fs';
import Path from 'path';
import { Pool, PoolClient } from 'pg';

import config from '../config';

const env = process.env.NODE_ENV ?? "development";

const pool = new Pool({ ...config.database[env], ssl: env === "production" });

const functions = Path.resolve(Path.join(__dirname, "./funciones"));
const tables = Path.resolve(Path.join(__dirname, "./tablas"));
const declarations = Path.resolve(Path.join(__dirname, "./declaraciones"));

export async function initDatabase() {
  let client: PoolClient;
  try {
    client = await pool.connect();
    for (const file of await fs.promises.readdir(tables)) {
      const path = Path.join(tables, file);
      const sql = await fs.promises.readFile(path, { encoding: "utf-8" });
      await client.query(sql);
    }
    for (const file of await fs.promises.readdir(functions)) {
      const path = Path.join(functions, file);
      const sql = await fs.promises.readFile(path, { encoding: "utf-8" });
      await client.query(sql);
    }
    for (const file of await fs.promises.readdir(declarations)) {
      const path = Path.join(declarations, file);
      const sql = await fs.promises.readFile(path, { encoding: "utf-8" });
      await client.query(sql);
    }
  } catch (e) {
    console.error(e);
    return false;
  } finally {
    if (client) {
      client.release();
    }
  }
  return true;
}

export async function executeFunction(name: string, params: string) {
  let client: PoolClient;
  try {
    client = await pool.connect();
    // prevent SQL injection
    JSON.parse(params);
    if (!name.match(/^[a-zA-Z_$][a-zA-Z_$0-9]*$/)) {
      console.error("Invalid function name");
    }
    const sql = `select * from ${name}('${params}'::json)`;
    const result = await client.query(sql);
    if (result.rows.length > 0) {
      return result.rows[0][name];
    }
  } catch (e) {
    throw e;
  } finally {
    if (client) {
      client.release();
    }
  }
}

export default pool;
