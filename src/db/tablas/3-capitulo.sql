create table if not exists capitulo(
    id bigserial,
    nombre text not null,
    imagenes json,
    activo boolean,
    manga_id bigint,
    fecha_creado timestamp,
    primary key (id),
    constraint chapter_manga_id_fk
        foreign key (manga_id)
            references manga(id)
);