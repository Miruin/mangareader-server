create or replace function enviar_error(
    p_mensaje text
) returns json language plpgsql as
$$
begin

    return (
        select row_to_json(r)
        from (
             select
                true as error,
                p_mensaje as mensaje
        ) r
    );

end
$$