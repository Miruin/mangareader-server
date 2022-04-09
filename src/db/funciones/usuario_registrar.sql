create or replace function usuario_registrar(
    p_datos json
) returns json language plpgsql as
$$
declare
    e record;
    v_usuario_id bigint;
    v_rol_id bigint;
begin

    select
        *
    from
        json_to_record(p_datos) as x(
            nombre text,
            apellido text,
            correo text,
            password text
        )
    into e;

    if exists(
        select
            1
        from
            usuario
        where
            correo=e.correo
        ) then
        return (
            select * from enviar_error('Ya existe un usuario con ese correo')
        );
    end if;

    insert into usuario(
        nombre,
        apellido,
        correo,
        password,
        confirmado,
        confirmacion,
        fecha_creado
    )
    values (
        e.nombre,
        e.apellido,
        e.correo,
        e.password,
        false,
        md5(e.correo),
        now()
    ) returning id into v_usuario_id;

    select
        id
    from
         rol
    where
         clave='mangaka'
    into
        v_rol_id;

    if v_rol_id is not null then

        insert into rol_usuario(
            rol_id,
            usuario_id
        ) values (
            v_rol_id,
            v_usuario_id
        );

    end if;



    return (
        select
            row_to_json(r)
        from (
            select
                *
            from
                usuario
            where
                id=v_usuario_id
        ) r
    );

end
$$