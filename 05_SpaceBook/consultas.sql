-- Consultas revisadas | 05_SpaceBook
-- Ejecutar el script de base de datos antes de consultar.
-- Las etiquetas resultado_* identifican los campos devueltos.

-- ============================================================
-- Colección de consultas resueltas para revisión y práctica.
-- Archivo de consultas: 20 ejercicios y un ejemplo inicial.
-- Base de datos: spacebook
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- Las consultas son de lectura; no alteran los datos iniciales.
-- Los encabezados calculados se identifican mediante resultado_.
-- ============================================================

use spacebook;

-- EJEMPLO DE CLASE (no calificable)
select
    room_ref.id as resultado_codigo_sala,
    room_ref.name as resultado_sala,
    room_ref.capacity as resultado_capacidad
from rooms as room_ref;



-- ----------------------------------------------------------------------

-- 01. Mostrar código, nombre, capacidad y estado de todas las salas.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo_sala,
    name as resultado_sala,
    capacity as resultado_capacidad,
    status as resultado_estado
from rooms;



-- ----------------------------------------------------------------------

-- 02. Buscar salas ACTIVAS con capacidad entre 6 y 12 personas.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo_sala,
    name as resultado_sala,
    capacity as resultado_capacidad,
    status as resultado_estado
from rooms
where status = 'ACTIVA'
      and capacity between 6 and 12;



-- ----------------------------------------------------------------------

-- 03. Mostrar los recursos DISPONIBLES de tipo PROYECTOR o AUDIO. Usar IN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    code as resultado_codigo_recurso,
    name as resultado_recurso,
    type as resultado_tipo,
    status as resultado_estado
from resources
where status = 'DISPONIBLE'
      and type in ('PROYECTOR', 'AUDIO');



-- ----------------------------------------------------------------------

-- 04. Mostrar las tres reservas que comienzan primero según la fecha y hora de inicio.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo_reserva,
    started_at as resultado_fecha_inicio,
    ended_at as resultado_fecha_fin,
    reason as resultado_motivo,
    status as resultado_estado
from reservations
order by started_at, id
limit 3;



-- ----------------------------------------------------------------------

-- 05. Buscar salas cuyo nombre contenga Sur o Ágora. Usar LIKE y OR.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo_sala,
    name as resultado_sala
from rooms
where name like '%Sur%' or name like '%Ágora%';



-- ----------------------------------------------------------------------

-- 06. Mostrar cada sala con su sede y ciudad.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    room_ref.id as resultado_codigo_sala,
    room_ref.name as resultado_sala,
    site_ref.name as resultado_sede,
    site_ref.city as resultado_ciudad
from sites as site_ref
  inner join rooms as room_ref
    on site_ref.id = room_ref.site_id;



-- ----------------------------------------------------------------------

-- 07. Mostrar cada reserva con el nombre de la sala y del organizador.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    reservation_ref.id as resultado_codigo_reserva,
    room_ref.name as resultado_sala,
    employee_ref.name as resultado_organizador
from reservations as reservation_ref
  inner join rooms as room_ref on reservation_ref.room_id = room_ref.id
  inner join employees as employee_ref on reservation_ref.organizer_id = employee_ref.id;



-- ----------------------------------------------------------------------

-- 08. Contar reservas por sala, incluyendo salas sin ninguna reserva. Usar LEFT JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    room_ref.id as resultado_codigo_sala,
    room_ref.name as resultado_sala,
    count(reservation_ref.id) as resultado_cantidad_reservas
from rooms as room_ref
  left join reservations as reservation_ref on room_ref.id = reservation_ref.room_id
group by room_ref.id, room_ref.name
order by room_ref.id;



-- ----------------------------------------------------------------------

-- 09. Contar las reservas por estado.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    status as resultado_estado,
    count(*) as resultado_cantidad_reservas
from reservations
group by status;



-- ----------------------------------------------------------------------

-- 10. Encontrar salas que tengan al menos dos reservas registradas. Usar HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    room_ref.id as resultado_codigo_sala,
    room_ref.name as resultado_sala,
    count(reservation_ref.id) as resultado_cantidad_reservas
from rooms as room_ref
  inner join reservations as reservation_ref on room_ref.id = reservation_ref.room_id
group by room_ref.id, room_ref.name
having count(reservation_ref.id) >= 2
order by room_ref.id;



-- ----------------------------------------------------------------------

-- 11. Mostrar el número de reservas CONFIRMADAS por sala, sin incluir los demás estados.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    room_ref.id as resultado_codigo_sala,
    room_ref.name as resultado_sala,
    count(reservation_ref.id) as resultado_cantidad_confirmadas
from rooms as room_ref
  inner join reservations as reservation_ref on room_ref.id = reservation_ref.room_id
where reservation_ref.status = 'CONFIRMADA'
group by room_ref.id, room_ref.name
order by room_ref.id;



-- ----------------------------------------------------------------------

-- 12. Mostrar los empleados invitados a cada reserva, indicando motivo y respuesta.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    reservation_ref.id as resultado_codigo_reserva,
    employee_ref.name as resultado_empleado,
    reservation_ref.reason as resultado_motivo,
    reservation_participant_ref.response as resultado_respuesta
from reservation_participants as reservation_participant_ref
  inner join reservations as reservation_ref on reservation_participant_ref.reservation_id = reservation_ref.id
  inner join employees as employee_ref on reservation_participant_ref.employee_id = employee_ref.id
order by reservation_ref.id, employee_ref.id;



-- ----------------------------------------------------------------------

-- 13. Listar reservas CONFIRMADAS del 3 de noviembre de 2026. Usar BETWEEN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo_reserva,
    room_id as resultado_codigo_sala,
    started_at as resultado_fecha_inicio,
    ended_at as resultado_fecha_fin,
    reason as resultado_motivo,
    status as resultado_estado
from reservations
where status = 'CONFIRMADA'
      and started_at between '2026-11-03 00:00:00' and '2026-11-03 23:59:59'
order by started_at, id;



-- ----------------------------------------------------------------------

-- 14. Mostrar recursos asociados a reservas, indicando el organizador de la reserva.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    reservation_ref.id as resultado_codigo_reserva,
    resource_ref.code as resultado_codigo_recurso,
    resource_ref.name as resultado_recurso,
    employee_ref.name as resultado_organizador
from reservation_resources as reservation_resource_ref
  inner join resources as resource_ref on reservation_resource_ref.resource_id = resource_ref.id
  inner join reservations as reservation_ref on reservation_resource_ref.reservation_id = reservation_ref.id
  inner join employees as employee_ref on reservation_ref.organizer_id = employee_ref.id
order by reservation_ref.id, resource_ref.id;



-- ----------------------------------------------------------------------

-- 15. Contar participantes invitados por reserva, incluyendo reservas sin participantes.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    reservation_ref.id as resultado_codigo_reserva,
    reservation_ref.reason as resultado_motivo,
    count(reservation_participant_ref.employee_id) as resultado_cantidad_invitados
from reservations as reservation_ref
  left join reservation_participants as reservation_participant_ref on reservation_ref.id = reservation_participant_ref.reservation_id
group by reservation_ref.id, reservation_ref.reason
order by reservation_ref.id;



-- ----------------------------------------------------------------------

-- 16. Mostrar los bloqueos de salas junto con la sede donde ocurren.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    room_block_ref.id as resultado_codigo_bloqueo,
    room_ref.name as resultado_sala,
    site_ref.name as resultado_sede,
    room_block_ref.started_at as resultado_fecha_inicio,
    room_block_ref.ended_at as resultado_fecha_fin,
    room_block_ref.reason as resultado_motivo
from room_blocks as room_block_ref
  inner join rooms as room_ref on room_block_ref.room_id = room_ref.id
  inner join sites as site_ref on room_ref.site_id = site_ref.id
order by room_block_ref.id;



-- ----------------------------------------------------------------------

-- 17. Encontrar empleados con dos o más invitaciones ACEPTADA. Usar HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    employee_ref.code as resultado_codigo_empleado,
    employee_ref.name as resultado_empleado,
    count(*) as resultado_cantidad_aceptadas
from employees as employee_ref
  inner join reservation_participants as reservation_participant_ref on employee_ref.id = reservation_participant_ref.employee_id
where reservation_participant_ref.response = 'ACEPTADA'
group by employee_ref.id, employee_ref.code, employee_ref.name
having count(*) >= 2
order by employee_ref.id;



-- ----------------------------------------------------------------------

-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar empleados que nunca han organizado una reserva. Usar NOT EXISTS.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    employee_ref.code as resultado_codigo_empleado,
    employee_ref.name as resultado_empleado
from employees as employee_ref
where not exists (
    select 1
    from reservations as reservation_ref
where reservation_ref.organizer_id = employee_ref.id
);



-- ----------------------------------------------------------------------

-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar salas cuya capacidad sea mayor al promedio de capacidades de todas las salas.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    room_ref.id as resultado_codigo_sala,
    room_ref.name as resultado_sala,
    room_ref.capacity as resultado_capacidad
from rooms as room_ref
where room_ref.capacity > (
    select avg(capacity)
    from rooms
);



-- ----------------------------------------------------------------------

-- 20 | SUBCONSULTA. SUBCONSULTA: listar recursos nunca solicitados en una reserva CONFIRMADA. Usar NOT EXISTS.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    resource_ref.code as resultado_codigo_recurso,
    resource_ref.name as resultado_recurso,
    resource_ref.type as resultado_tipo,
    resource_ref.status as resultado_estado
from resources as resource_ref
where not exists (
    select 1
    from reservation_resources as reservation_resource_ref
  inner join reservations as reservation_ref on reservation_resource_ref.reservation_id = reservation_ref.id
where reservation_resource_ref.resource_id = resource_ref.id
      and reservation_ref.status = 'CONFIRMADA'
);
