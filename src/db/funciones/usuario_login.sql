create or replace function usuario_login(
    p_datos json
) returns json language plpgsql as
$$
declare
    e record;
    v_usuario_id bigint;
begin

    select
        *
    from
        json_to_record(p_datos) as x(
            correo text,
            password text
        )
    into e;

    select
        id
    from
        usuario
    where
        correo=e.correo
        and password=e.password
    into
        v_usuario_id;

    return to_json(v_usuario_id);

end
$$