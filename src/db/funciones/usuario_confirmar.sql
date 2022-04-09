create or replace function usuario_confirmar(
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
            token text
        )
    into e;

    select
        id
    from
        usuario
    where
        confirmacion=e.token
    into
        v_usuario_id;

    if v_usuario_id is not null then

        update
            usuario
        set
            confirmacion=null,
            confirmado=true
        where
            id=v_usuario_id;

        return to_json(true);

    else

        return to_json(false);

    end if;

end
$$