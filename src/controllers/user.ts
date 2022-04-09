import { Request, Response } from 'express';
import hasha from 'hasha';
import jwt from 'jsonwebtoken';

import config from '../config';
import { executeFunction } from '../db';

function signUser(id) {
  return "Bearer " + jwt.sign(id, config.secretKey);
}

export async function login(req: Request, res: Response) {
  try {
    req.body.password = hasha(req.body.password);
    const user = await executeFunction(
      "usuario_login",
      JSON.stringify(req.body)
    );
    if (!user) throw new Error("Correo o contraseña invalidos");
    if (user.error) throw new Error(user.mensaje);
    res.status(200).send(signUser(user));
  } catch (e) {
    res.status(500).send((e as Error).message);
  }
}

export async function register(req: Request, res: Response) {
  try {
    req.body.password = hasha(req.body.password);
    const user = await executeFunction(
      "usuario_registrar",
      JSON.stringify(req.body)
    );
    if (user.error) throw new Error(user.mensaje);
    res.status(200).send(signUser(user.id));
  } catch (e) {
    res.status(500).send((e as Error).message);
  }
}

export default { register, login };
