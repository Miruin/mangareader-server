create table if not exists rol_permiso(
    id bigserial,
    rol_id bigint,
    permiso_id bigint,
    primary key(id),
    constraint rol_permiso_rol_id_fk
        foreign key(rol_id)
            references rol(id),
    constraint rol_permiso_permiso_id_fk
        foreign key (permiso_id)
            references permiso(id)
);