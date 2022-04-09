create table if not exists usuario(
    id bigserial,
    nombre text not null,
    apellido text not null,
    correo text not null,
    password text,
    confirmacion text,
    confirmado boolean,
    fecha_creado timestamp not null,
    manga_sentido text,
    primary key (id),
    constraint correo_unico
        unique(correo)
);