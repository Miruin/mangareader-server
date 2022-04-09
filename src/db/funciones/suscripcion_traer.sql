create or replace function suscripcion_traer(
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
            usuario_id bigint
        )
    into e;

    return (
        select
            row_to_json(r)
        from (
             select
                cu.capitulo_id,
                u.manga_sentido,
                cu.pagina
             from
                capitulo_usuario cu
                inner join capitulo c on cu.capitulo_id = c.id
                inner join suscripcion su on
                    su.manga_id = c.manga_id
                    and su.usuario_id = cu.usuario_id
                    and su.activo
                inner join usuario u on cu.usuario_id = u.id
             where
                cu.usuario_id = e.usuario_id
                and cu.activo
                and not cu.terminado
             order by
                cu.id desc
             fetch first row only
        ) r
    );

end
$$