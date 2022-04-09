create table if not exists rol_usuario(
    id bigserial,
    rol_id bigint,
    usuario_id bigint,
    primary key(id),
    constraint rol_usuario_rol_id_fk
        foreign key(rol_id)
            references rol(id),
    constraint rol_usuario_usuario_id_fk
        foreign key (usuario_id)
            references usuario(id)
);