create or replace function manga_traer(
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
            id bigint,
            busqueda text,
            usuario_id bigint,
            capitulo_id bigint,
            solo_es_creador boolean,
            solo_suscritos boolean
        )
    into e;

    if e.id is not null then

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
                            s.manga_id = m.id
                            and s.usuario_id = e.usuario_id
                            and s.activo
                    ) as suscrito,
                    (
                        select coalesce(json_agg(h2), '[]')
                        from (
                           select
                                c.id,
                                c.nombre,
                                c.imagenes,
                                c.fecha_creado,
                              exists(
                                select
                                    1
                                 from
                                    capitulo_usuario cu
                                 where
                                    cu.capitulo_id = c.id
                                    and cu.usuario_id = e.usuario_id
                             ) as visto
                            from
                                capitulo c
                            where
                                c.manga_id = m.id
                                and c.activo
                                and (
                                    e.capitulo_id is null
                                    or c.id = e.capitulo_id
                                )
                            order by
                                c.id
                        )  h2
                    ) as capitulos
                from
                    manga m
                where
                    m.id = e.id
                    and m.activo
            ) r
        );

    else

        return (
            select coalesce(json_agg(h1), '[]')
            from (
                select
                    m.id,
                    m.nombre,
                    m.descripcion,
                    m.thumb
                from
                    manga m
                where
                    (
                       (e.busqueda is null or e.busqueda is not distinct from '')
                        or (
                            m.nombre like '%' || e.busqueda || '%'
                            or m.descripcion like '%' || e.busqueda || '%'
                        )
                    )
                    and m.activo
                    and (
                        e.solo_es_creador is null
                        or (
                           not e.solo_es_creador
                           or m.usuario_id = e.usuario_id
                        )
                    )
                    and (
                        e.solo_suscritos is null
                        or (
                            not e.solo_suscritos
                            or exists (
                                select
                                    1
                                from
                                    suscripcion su
                                where
                                    su.usuario_id = e.usuario_id
                                    and su.manga_id = m.id
                                    and su.activo
                            )
                        )
                    )
            ) h1
        );

    end if;

end
$$