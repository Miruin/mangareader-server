create or replace function manga_leer(
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
            capitulo_id bigint,
            pagina bigint,
            activo boolean,
            terminado boolean,
            manga_sentido text
        )
    into e;

    if e.usuario_id is not null then

        update
            usuario u
        set
            manga_sentido=coalesce(e.manga_sentido,u.manga_sentido)
        where
            u.id=e.usuario_id;

        if exists(
            select
                1
            from
                capitulo_usuario cu
            where
                cu.capitulo_id = e.capitulo_id
                and cu.usuario_id = e.usuario_id
        ) then

            update
                capitulo_usuario cu
            set
                terminado=coalesce(e.terminado,cu.terminado),
                activo=coalesce(e.activo,cu.activo),
                pagina=coalesce(e.pagina,cu.pagina),
                fecha_visto=now()
            where
                cu.usuario_id = e.usuario_id
                and cu.capitulo_id = e.capitulo_id;

        else

            insert into capitulo_usuario(
                capitulo_id,
                usuario_id,
                pagina,
                fecha_visto,
                activo,
                terminado
            ) values (e.capitulo_id, e.usuario_id, e.pagina, now(), coalesce(e.activo,true), coalesce(e.terminado,false));

        end if;

        return (
            select
                   row_to_json(r)
            from (
                 select
                    cu.*,
                    u.manga_sentido,
                    c.imagenes
                 from
                    capitulo_usuario cu
                    inner join capitulo c on c.id = cu.capitulo_id
                    inner join usuario u on cu.usuario_id = u.id
                 where
                    cu.usuario_id = e.usuario_id
                    and cu.capitulo_id = e.capitulo_id
                 order by id
            ) r
        );

    else

        return (
            select
                   row_to_json(r)
            from (
                 select
                    c.imagenes
                 from
                    capitulo c
                 where
                    c.id = e.capitulo_id
                 order by id
            ) r
        );

    end if;

end
$$