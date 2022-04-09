create table if not exists rol(
    id bigserial,
    nombre text,
    descripcion text,
    clave text not null,
    primary key(id),
    constraint clave_unica_rol
        unique(clave)
);