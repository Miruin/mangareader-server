create table if not exists permiso(
    id bigserial,
    nombre text,
    descripcion text,
    clave text not null,
    primary key(id),
    constraint clave_unica
        unique(clave)
);