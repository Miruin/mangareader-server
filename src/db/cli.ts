import { Command } from 'commander';

import { executeFunction, initDatabase } from '.';

const program = new Command();

program
  .command("init")
  .description("Initialize database")
  .action(async () => {
    try {
      const created = await initDatabase();
      if (created) console.log("Database created.");
    } catch (e) {
      console.log(e);
    }
  });

program
  .command("execute")
  .argument("<function>", "function name")
  .argument("<json>", "params")
  .description("Execute function in database")
  .action(async (name, params) => {
    try {
      const result = await executeFunction(name, params);
      console.log(result);
    } catch (e) {
      console.log(e);
    }
  });

program
  .command("grant-permissions")
  .argument("<email>", "user email")
  .argument("<permissions>", "Permissions separated by commas")
  .description("Add permissions to user")
  .action(async (email, permissions) => {
    try {
      const result = await executeFunction(
        "usuario_permisos",
        JSON.stringify({
          usuario_desde_correo: email,
          nuevos_roles: permissions.split(",").map((v) => ({ clave: v })),
        })
      );
      console.log(result);
    } catch (e) {
      console.log(e);
    }
  });

program
  .command("remove-permissions")
  .argument("<email>", "user email")
  .argument("<permissions>", "Permissions separated by commas")
  .description("Remove permissions to user")
  .action(async (email, permissions) => {
    try {
      const result = await executeFunction(
        "usuario_permisos",
        JSON.stringify({
          usuario_desde_correo: email,
          roles_a_remover: permissions.split(",").map((v) => ({ clave: v })),
        })
      );
      console.log(result);
    } catch (e) {
      console.log(e);
    }
  });

program.parse(process.argv);
