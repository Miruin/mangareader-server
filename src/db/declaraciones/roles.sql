delete from rol_permiso where true;
delete from rol_usuario where true;
delete from rol where true;
delete from permiso where true;

-- temporal
alter table capitulo_usuario add column if not exists terminado boolean;

insert into permiso (
    nombre,
    descripcion,
    clave
) values (
    'Publicar mangas',
    'Permiso para publicar y editar mangas propios',
    'publicar_manga'
);

insert into permiso (
    nombre,
    descripcion,
    clave
) values (
    'Administrar mangas',
    'Permiso para administrar todos los mangas',
    'administrar_manga'
);

insert into rol(
    nombre,
    descripcion,
    clave
)
values(
    'Mangaka',
    'Usuario que publica y lee mangas',
    'mangaka'
);

insert into rol_permiso (
    rol_id,
    permiso_id
)
select
   (select id from rol where clave='mangaka'),
   p.id
from
    permiso p
where
    p.clave = 'publicar_manga';


insert into rol(
    nombre,
    descripcion,
    clave
)
values(
    'Administrador',
    'Usuario que administra el sistema',
    'administrador'
);

insert into rol_permiso (
    rol_id,
    permiso_id
)
select
   (select id from rol where clave='administrador'),
   p.id
from
    permiso p
where
    p.clave in ('publicar_manga', 'administrar_manga');
