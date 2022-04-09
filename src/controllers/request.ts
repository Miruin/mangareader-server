import { Request, Response } from 'express';

import { executeFunction } from '../db';

export async function execute(req: Request, res: Response) {
  try {
    if (req.user) {
      req.body.usuario_id = parseInt(req.user as string);
    } else {
      delete req.body.usuario_id;
    }
    const result = await executeFunction(
      req.params.function,
      JSON.stringify(req.body)
    );
    if (result.error) throw new Error(result.mensaje);
    res.status(200).send(result);
  } catch (e) {
    res.status(500).send((e as Error).message);
  }
}

export default { execute };
