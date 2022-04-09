
create table if not exists capitulo_usuario(
    id bigserial,
    capitulo_id bigint,
    usuario_id bigint,
    pagina bigint,
    fecha_visto timestamp,
    activo boolean,
    capitulo boolean,
    constraint capitulo_usuario_capitulo_id_fk
        foreign key (capitulo_id)
            references capitulo(id),
    constraint capitulo_usuario_usuario_id_fk
        foreign key (usuario_id)
            references usuario(id),
    primary key (id)
);