create or replace function manga_grabar(
    p_datos json
) returns json language plpgsql as
$$
declare
    e record;
    v_manga_id bigint;
begin

    select
        *
    from
        json_to_record(p_datos) as x(
            id bigint,
            usuario_id bigint,
            nombre text,
            descripcion text,
            thumb text,
            nuevos_capitulos json,
            capitulos_a_desactivar json,
            activo boolean,
            suscribirse boolean
        )
    into e;

    if e.id is null then

        insert into manga (
            nombre,
            descripcion,
            thumb,
            usuario_id,
            activo,
            fecha_creado
        ) values (
            e.nombre,
            e.descripcion,
            e.thumb,
            e.usuario_id,
            true,
            now()
        ) returning id into v_manga_id;

    else

        v_manga_id = e.id;

        update
            manga m
        set
            nombre=coalesce(e.nombre,m.nombre),
            descripcion=coalesce(e.descripcion,m.descripcion),
            thumb=coalesce(e.thumb,m.thumb)
        where
            id=v_manga_id;

    end if;

    if e.activo is not null then

        update
            manga
        set
            activo=e.activo
        where
            id=v_manga_id;

    end if;

     if e.suscribirse is not null then

        if exists(
            select
                1
            from
                suscripcion s
            where
                s.manga_id = v_manga_id
                and s.usuario_id = e.usuario_id
        ) then

            update
                suscripcion s
            set
                activo=e.suscribirse
            where
                s.usuario_id = e.usuario_id
                and s.manga_id = v_manga_id;

        else
            insert into suscripcion (
                manga_id,
                usuario_id,
                activo
            ) values (
                v_manga_id,
                e.usuario_id,
                e.suscribirse
            );
        end if;

    end if;

    insert into capitulo (
        nombre,
        imagenes,
        activo,
        manga_id,
        fecha_creado
    )
    select
        x.nombre,
        x.imagenes,
        true,
        v_manga_id,
        now()
    from
         json_to_recordset(e.nuevos_capitulos) as x (
            nombre text,
            imagenes json
        );

    update
        capitulo c
    set
        activo=false
    from
         json_to_recordset(e.capitulos_a_desactivar) as x(
            id bigint
         )
    where
        c.id = x.id;

    return (
        select
            row_to_json(r)
        from (
            select
                m.id,
                m.nombre,
                m.descripcion,
                m.thumb,
                m.usuario_id = e.usuario_id as es_autor,
                exists(
                    select
                        1
                    from
                        suscripcion s
                    where
                        s.manga_id = v_manga_id
                        and s.usuario_id = e.usuario_id
                        and s.activo
                ) as suscrito,
                (
                    select
                        coalesce(json_agg(h1),'[]')
                    from (
                         select
                             c.id,
                             c.nombre,
                             c.imagenes,
                             c.fecha_creado
                         from
                            capitulo c
                         where
                            c.activo
                            and c.manga_id = m.id
                         order by
                            c.id
                    ) h1
                ) as capitulos
            from
                manga m
            where
                m.id = v_manga_id
                and m.activo
        ) r
    );

end
$$