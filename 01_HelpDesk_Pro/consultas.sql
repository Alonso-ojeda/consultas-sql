-- Consultas revisadas | 01_HelpDesk_Pro
-- Ejecutar el script de base de datos antes de consultar.
-- Las etiquetas resultado_* identifican los campos devueltos.

-- ============================================================
-- Colección de consultas resueltas para revisión y práctica.
-- Archivo de consultas: 20 ejercicios y un ejemplo inicial.
-- Base de datos: helpdesk_pro
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- Las consultas son de lectura; no alteran los datos iniciales.
-- Los encabezados calculados se identifican mediante resultado_.
-- ============================================================

use helpdesk_pro;

-- EJEMPLO DE CLASE (no calificable)
select
    ticket_ref.id as resultado_codigo_ticket,
    ticket_ref.subject as resultado_asunto,
    ticket_ref.status as resultado_estado
from tickets as ticket_ref;



-- ----------------------------------------------------------------------

-- 01. Mostrar el código, asunto, prioridad y estado de todos los tickets, ordenados por código.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 8 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_ticket,
    subject as resultado_asunto,
    priority as resultado_prioridad,
    status as resultado_estado
from tickets
order by id;



-- ----------------------------------------------------------------------

-- 02. Listar los tickets con prioridad ALTA o CRITICA que estén ABIERTO o EN_PROCESO. Usar AND, OR y paréntesis.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 3 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_ticket,
    subject as resultado_asunto,
    priority as resultado_prioridad,
    status as resultado_estado
from tickets
where (priority = 'ALTA' or priority = 'CRITICA')
      and (status = 'ABIERTO' or status = 'EN_PROCESO')
order by id;



-- ----------------------------------------------------------------------

-- 03. Buscar los clientes ACTIVOS cuya razón social contenga SAS. Usar LIKE.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 3 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_cliente,
    company_name as resultado_empresa, 
    status as resultado_estado
from clients
where status = 'ACTIVO' and company_name like '%SAS%'
order by company_name;



-- ----------------------------------------------------------------------

-- 04. Obtener los tres tickets más recientes según su fecha de apertura. Usar ORDER BY y LIMIT.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 3 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_ticket,
    subject as resultado_asunto,
    opened_at as resultado_fecha_apertura
from tickets
order by opened_at desc
limit 3;



-- ----------------------------------------------------------------------

-- 05. Mostrar tickets cuyo asunto contenga la palabra Red o Servidor. Usar LIKE y OR.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 2 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_ticket,
    subject as resultado_asunto
from tickets
where subject like '%Red%' or subject like '%Servidor%'
order by id;



-- ----------------------------------------------------------------------

-- 06. Mostrar el código y asunto de cada ticket junto con el nombre de su contacto. Usar JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 8 fila(s), con las semillas sin modificar.
select
    ticket_ref.id as resultado_codigo_ticket,
    ticket_ref.subject as resultado_asunto,
    contact_ref.name as resultado_contacto
from tickets as ticket_ref
  inner join contacts as contact_ref on ticket_ref.contact_id = contact_ref.id
order by ticket_ref.id;



-- ----------------------------------------------------------------------

-- 07. Mostrar cada ticket con el cliente que lo reportó y la categoría de soporte. Usar varios JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 8 fila(s), con las semillas sin modificar.
select
    ticket_ref.id as resultado_codigo_ticket,
    ticket_ref.subject as resultado_asunto,
    client_ref.company_name as resultado_empresa,
    categorie_ref.name as resultado_categoria
from tickets as ticket_ref
  inner join contacts as contact_ref on ticket_ref.contact_id = contact_ref.id
  inner join clients as client_ref on contact_ref.client_id = client_ref.id
  inner join categories as categorie_ref on ticket_ref.category_id = categorie_ref.id
order by ticket_ref.id;



-- ----------------------------------------------------------------------

-- 08. Listar todos los técnicos y cuántas asignaciones han recibido, incluso si nunca han sido asignados. Usar LEFT JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 5 fila(s), con las semillas sin modificar.
select
    technician_ref.id as resultado_codigo_tecnico,
    technician_ref.name as resultado_tecnico,
    count(assignment_ref.id) as resultado_total_asignaciones
from technicians as technician_ref
  left join assignments as assignment_ref on technician_ref.id = assignment_ref.technician_id
group by technician_ref.id, technician_ref.name
order by resultado_total_asignaciones desc, technician_ref.name;



-- ----------------------------------------------------------------------

-- 09. Contar cuántos tickets existen por prioridad. Usar GROUP BY.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 4 fila(s), con las semillas sin modificar.
select
    priority as resultado_prioridad,
    count(*) as resultado_total_tickets
from tickets
group by priority
order by resultado_total_tickets desc, priority;



-- ----------------------------------------------------------------------

-- 10. Mostrar cuántos tickets se registraron en cada estado, ordenados del más frecuente al menos frecuente.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 4 fila(s), con las semillas sin modificar.
select
    status as resultado_estado,
    count(*) as resultado_total_tickets
from tickets
group by status
order by resultado_total_tickets desc, status;



-- ----------------------------------------------------------------------

-- 11. Mostrar los tickets con asignación todavía abierta y el técnico responsable. Usar IS NULL.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 3 fila(s), con las semillas sin modificar.
select
    ticket_ref.id as resultado_codigo_ticket,
    ticket_ref.subject as resultado_asunto,
    technician_ref.name as resultado_tecnico
from assignments as assignment_ref
  inner join tickets as ticket_ref on assignment_ref.ticket_id = ticket_ref.id
  inner join technicians as technician_ref on assignment_ref.technician_id = technician_ref.id
where assignment_ref.ended_at is null
order by ticket_ref.id;



-- ----------------------------------------------------------------------

-- 12. Buscar tickets abiertos desde el 1 hasta el 5 de septiembre de 2026, incluyendo todo el día 5. Usar BETWEEN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 5 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_ticket,
    subject as resultado_asunto,
    opened_at as resultado_fecha_apertura
from tickets
where opened_at between '2026-09-01 00:00:00' and '2026-09-05 23:59:59'
order by opened_at;



-- ----------------------------------------------------------------------

-- 13. Mostrar los comentarios escritos por técnicos con el nombre del autor y el asunto del ticket.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 5 fila(s), con las semillas sin modificar.
select
    comment_ref.id as resultado_codigo_comentario,
    technician_ref.name as resultado_tecnico,
    ticket_ref.subject as resultado_asunto,
    comment_ref.content as resultado_comentario
from comments as comment_ref
  inner join technicians as technician_ref on comment_ref.technician_id = technician_ref.id
  inner join tickets as ticket_ref on comment_ref.ticket_id = ticket_ref.id
order by comment_ref.id;



-- ----------------------------------------------------------------------

-- 14. Contar los comentarios por ticket, incluyendo tickets sin comentarios.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 8 fila(s), con las semillas sin modificar.
select
    ticket_ref.id as resultado_codigo_ticket,
    ticket_ref.subject as resultado_asunto,
    count(comment_ref.id) as resultado_total_comentarios
from tickets as ticket_ref
  left join comments as comment_ref on ticket_ref.id = comment_ref.ticket_id
group by ticket_ref.id, ticket_ref.subject
order by resultado_total_comentarios desc, ticket_ref.id;



-- ----------------------------------------------------------------------

-- 15. Mostrar las empresas que hayan reportado dos o más tickets. Usar GROUP BY y HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 3 fila(s), con las semillas sin modificar.
select
    client_ref.company_name as resultado_empresa,
    count(ticket_ref.id) as resultado_total_tickets
from clients as client_ref
  inner join contacts as contact_ref on client_ref.id = contact_ref.client_id
  inner join tickets as ticket_ref on contact_ref.id = ticket_ref.contact_id
group by client_ref.id, client_ref.company_name
having count(ticket_ref.id) >= 2
order by resultado_total_tickets desc, resultado_empresa;



-- ----------------------------------------------------------------------

-- 16. Encontrar las categorías con al menos dos tickets registrados. Usar HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 3 fila(s), con las semillas sin modificar.
select
    categorie_ref.name as resultado_categoria,
    count(ticket_ref.id) as resultado_total_tickets
from categories as categorie_ref
  inner join tickets as ticket_ref on categorie_ref.id = ticket_ref.category_id
group by categorie_ref.id, categorie_ref.name
having count(ticket_ref.id) >= 2
order by resultado_total_tickets desc, resultado_categoria;



-- ----------------------------------------------------------------------

-- 17. Mostrar cada cambio de estado con el asunto del ticket y el nombre del técnico, incluyendo cambios automáticos.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 8 fila(s), con las semillas sin modificar.
select
    status_history_ref.id as resultado_codigo_cambio,
    ticket_ref.subject as resultado_asunto,
    status_history_ref.previous_status as resultado_estado_anterior,
    status_history_ref.new_status as resultado_estado_nuevo,
    IFNULL(technician_ref.name, 'Automatización') as resultado_responsable
from status_history as status_history_ref
  inner join tickets as ticket_ref on status_history_ref.ticket_id = ticket_ref.id
  left join technicians as technician_ref on status_history_ref.technician_id = technician_ref.id
order by status_history_ref.id;



-- ----------------------------------------------------------------------

-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar los tickets abiertos después de la fecha de apertura del ticket con id 4.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 4 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_ticket,
    subject as resultado_asunto,
    opened_at as resultado_fecha_apertura
from tickets
where opened_at > (select opened_at from tickets where id = 4)
order by opened_at;



-- ----------------------------------------------------------------------

-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar los técnicos que no han escrito ningún comentario. Usar NOT EXISTS.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 1 fila(s), con las semillas sin modificar.
select
    technician_ref.id as resultado_codigo_tecnico,
    technician_ref.name as resultado_tecnico
from technicians as technician_ref
where not exists (
    select 1 from comments as comment_ref where comment_ref.technician_id = technician_ref.id
)
order by technician_ref.id;



-- ----------------------------------------------------------------------

-- 20 | SUBCONSULTA. SUBCONSULTA: consultar los tickets que tengan una prioridad igual a la de los tickets 1 o 2, excluyendo esos dos tickets. Usar IN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Filas esperadas con datos iniciales: 3 fila(s), con las semillas sin modificar.
select
    id as resultado_codigo_ticket,
    subject as resultado_asunto,
    priority as resultado_prioridad
from tickets
where priority in (select priority from tickets where id in (1, 2))
      and id not in (1, 2)
order by id;