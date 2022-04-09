

create table if not exists manga(
    id bigserial,
    nombre text not null,
    descripcion text not null,
    thumb text,
    usuario_id bigint,
    fecha_creado timestamp not null,
    activo boolean,
    primary key (id),
    constraint manga_usuario_id_fk
        foreign key (usuario_id)
            references usuario(id)
);