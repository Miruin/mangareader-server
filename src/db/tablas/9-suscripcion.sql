
create table if not exists suscripcion(
    id bigserial,
    manga_id bigint,
    usuario_id bigint,
    activo boolean,
    constraint suscripcion_manga_id_fk
        foreign key (manga_id)
            references manga(id),
    constraint suscripcion_usuario_id_fk
        foreign key (usuario_id)
            references usuario(id)
);