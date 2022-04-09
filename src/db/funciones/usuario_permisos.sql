create or replace function usuario_permisos(
    p_datos json
) returns json language plpgsql as
$$
declare
    e record;
begin

    select
        *
    from
        json_to_record(p_datos) as x(
            usuario_id bigint,
            usuario_desde_correo text,
            nuevos_roles json,
            roles_a_remover json
        )
    into e;

    if e.usuario_desde_correo is not null then
        select
            id
        from
             usuario
        where
            correo=e.usuario_desde_correo
        into
            e.usuario_id;
    end if;

    insert into rol_usuario(
         rol_id,
         usuario_id
    )
    select
        rol.id,
        e.usuario_id
    from
        json_to_recordset(e.nuevos_roles) as x (
            clave text
        ) inner join rol on rol.clave = x.clave
    where
        not exists (
            select
                1
            from
                rol_usuario
            where
                rol_id=rol.id
                and usuario_id=e.usuario_id
        );

    delete from
        rol_usuario
    where
        rol_id in (
            select
                rol.id
            from
                json_to_recordset(e.roles_a_remover) as x (
                    clave text
                ) inner join rol on rol.clave = x.clave
        ) and usuario_id = e.usuario_id;


    return (
        select
            coalesce(json_agg(h1), '[]')
        from (
            select
                *
            from
                permiso
            where
                exists(
                    select
                        1
                    from
                        rol_permiso rp
                        inner join rol_usuario ru on
                            rp.rol_id = ru.rol_id
                            and ru.usuario_id = e.usuario_id
                    where
                        rp.permiso_id = permiso.id
                )
        ) h1
    );

end
$$