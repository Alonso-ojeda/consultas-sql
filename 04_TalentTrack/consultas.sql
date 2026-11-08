-- Consultas revisadas | 04_TalentTrack
-- Ejecutar el script de base de datos antes de consultar.
-- Las etiquetas resultado_* identifican los campos devueltos.

-- ============================================================
-- Colección de consultas resueltas para revisión y práctica.
-- Archivo de consultas: 20 ejercicios y un ejemplo inicial.
-- Base de datos: talenttrack
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- Las consultas son de lectura; no alteran los datos iniciales.
-- Los encabezados calculados se identifican mediante resultado_.
-- ============================================================

use talenttrack;

-- EJEMPLO DE CLASE (no calificable)
select
    course_ref.id as resultado_codigo_curso,
    course_ref.name as resultado_curso,
    course_ref.duration_hours as resultado_horas
from courses as course_ref;



-- ----------------------------------------------------------------------

-- 01. Mostrar código, nombre y duración en horas de todos los cursos.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    code as resultado_codigo,
    name as resultado_curso,
    duration_hours as resultado_horas
from courses;



-- ----------------------------------------------------------------------

-- 02. Listar ediciones en estado ABIERTA o EN_CURSO cuya fecha de inicio sea desde septiembre de 2026.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    code as resultado_edicion,
    start_date as resultado_fecha_inicio,
    status as resultado_estado
from editions
where (status = 'ABIERTA' or status = 'EN_CURSO')
      and start_date >= '2026-09-01';



-- ----------------------------------------------------------------------

-- 03. Mostrar colaboradores ACTIVO de empresas cuyo nombre contenga SAS. Usar JOIN y LIKE.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    collaborator_ref.id as resultado_codigo_colaborador,
    collaborator_ref.name as resultado_colaborador,
    companie_ref.company_name as resultado_empresa
from companies as companie_ref
  inner join collaborators as collaborator_ref
    on companie_ref.id = collaborator_ref.company_id
where collaborator_ref.status = 'ACTIVO'
      and companie_ref.company_name like '%SAS%';



-- ----------------------------------------------------------------------

-- 04. Mostrar las tres ediciones con fecha de inicio más reciente. Usar LIMIT.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    code as resultado_edicion,
    start_date as resultado_fecha_inicio
from editions
order by start_date desc, id
limit 3;



-- ----------------------------------------------------------------------

-- 05. Buscar cursos cuyo nombre incluya IA o datos. Usar LIKE y OR.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    code as resultado_codigo,
    name as resultado_curso
from courses
where name like '%IA%' or name like '%datos%';



-- ----------------------------------------------------------------------

-- 06. Mostrar cada edición junto con el nombre del curso y el instructor que la imparte.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    edition_ref.code as resultado_edicion,
    course_ref.name as resultado_curso,
    instructor_ref.name as resultado_instructor
from editions as edition_ref
  inner join courses as course_ref on edition_ref.course_id = course_ref.id
  inner join instructors as instructor_ref on edition_ref.instructor_id = instructor_ref.id;



-- ----------------------------------------------------------------------

-- 07. Relacionar cada matrícula con colaborador, empresa y edición.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    enrollment_ref.id as resultado_codigo_matricula,
    collaborator_ref.name as resultado_colaborador,
    companie_ref.company_name as resultado_empresa,
    edition_ref.code as resultado_edicion
from enrollments as enrollment_ref
  inner join collaborators as collaborator_ref on enrollment_ref.collaborator_id = collaborator_ref.id
  inner join companies as companie_ref on collaborator_ref.company_id = companie_ref.id
  inner join editions as edition_ref on enrollment_ref.edition_id = edition_ref.id;



-- ----------------------------------------------------------------------

-- 08. Contar los matriculados por edición, incluyendo ediciones sin inscritos. Usar LEFT JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    edition_ref.code as resultado_edicion,
    count(enrollment_ref.id) as resultado_cantidad_matriculados
from editions as edition_ref
  left join enrollments as enrollment_ref on edition_ref.id = enrollment_ref.edition_id
group by edition_ref.id, edition_ref.code
order by edition_ref.id;



-- ----------------------------------------------------------------------

-- 09. Contar matrículas agrupadas por su estado.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    status as resultado_estado,
    count(*) as resultado_cantidad_matriculas
from enrollments
group by status;



-- ----------------------------------------------------------------------

-- 10. Encontrar los cursos que se han ofrecido en dos o más ediciones. Usar HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    course_ref.code as resultado_codigo_curso,
    course_ref.name as resultado_curso,
    count(edition_ref.id) as resultado_cantidad_ediciones
from courses as course_ref
  inner join editions as edition_ref on course_ref.id = edition_ref.course_id
group by course_ref.id, course_ref.code, course_ref.name
having count(edition_ref.id) >= 2;



-- ----------------------------------------------------------------------

-- 11. Contar las sesiones programadas en cada edición.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    edition_ref.code as resultado_edicion,
    count(session_ref.id) as resultado_cantidad_sesiones
from editions as edition_ref
  left join sessions as session_ref on edition_ref.id = session_ref.edition_id
group by edition_ref.id, edition_ref.code
order by edition_ref.id;



-- ----------------------------------------------------------------------

-- 12. Mostrar los certificados emitidos junto al nombre del colaborador y el curso.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    certificate_ref.code as resultado_certificado,
    certificate_ref.issued_at as resultado_fecha_emision,
    collaborator_ref.name as resultado_colaborador,
    course_ref.name as resultado_curso
from certificates as certificate_ref
  inner join enrollments as enrollment_ref on certificate_ref.enrollment_id = enrollment_ref.id
  inner join collaborators as collaborator_ref on enrollment_ref.collaborator_id = collaborator_ref.id
  inner join editions as edition_ref on enrollment_ref.edition_id = edition_ref.id
  inner join courses as course_ref on edition_ref.course_id = course_ref.id;



-- ----------------------------------------------------------------------

-- 13. Mostrar las sesiones realizadas durante septiembre de 2026, junto a su edición.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    session_ref.id as resultado_codigo_sesion,
    session_ref.topic as resultado_tema,
    session_ref.started_at as resultado_fecha_inicio,
    session_ref.ended_at as resultado_fecha_fin,
    edition_ref.code as resultado_edicion
from sessions as session_ref
  inner join editions as edition_ref on session_ref.edition_id = edition_ref.id
where session_ref.started_at >= '2026-09-01'
      and session_ref.started_at < '2026-10-01'
order by session_ref.started_at, session_ref.id;



-- ----------------------------------------------------------------------

-- 14. Mostrar todas las asistencias registradas con el colaborador, tema de la sesión y estado.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    attendance_ref.id as resultado_codigo_asistencia,
    collaborator_ref.name as resultado_colaborador,
    session_ref.topic as resultado_tema,
    attendance_ref.status as resultado_estado
from attendance as attendance_ref
  inner join enrollments as enrollment_ref on attendance_ref.enrollment_id = enrollment_ref.id
  inner join collaborators as collaborator_ref on enrollment_ref.collaborator_id = collaborator_ref.id
  inner join sessions as session_ref on attendance_ref.session_id = session_ref.id
order by attendance_ref.id;



-- ----------------------------------------------------------------------

-- 15. Contar cuántas asistencias PRESENTE registra cada matrícula con registros de asistencia.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    enrollment_ref.id as resultado_codigo_matricula,
    sum(case when attendance_ref.status = 'PRESENTE' then 1 else 0 end) as resultado_cantidad_presentes
from enrollments as enrollment_ref
  inner join attendance as attendance_ref on enrollment_ref.id = attendance_ref.enrollment_id
group by enrollment_ref.id
order by enrollment_ref.id;



-- ----------------------------------------------------------------------

-- 16. Mostrar ediciones con al menos dos matriculados e indicar su capacidad. Usar HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    edition_ref.code as resultado_edicion,
    edition_ref.capacity as resultado_capacidad,
    count(enrollment_ref.id) as resultado_cantidad_matriculados
from editions as edition_ref
  inner join enrollments as enrollment_ref on edition_ref.id = enrollment_ref.edition_id
group by edition_ref.id, edition_ref.code, edition_ref.capacity
having count(enrollment_ref.id) >= 2
order by edition_ref.id;



-- ----------------------------------------------------------------------

-- 17. Mostrar matrículas cuya asistencia registrada tenga al menos 80% PRESENTE. Usar GROUP BY y HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    enrollment_ref.id as resultado_codigo_matricula,
    count(attendance_ref.id) as resultado_cantidad_registros,
    sum(case when attendance_ref.status = 'PRESENTE' then 1 else 0 end) as resultado_cantidad_presentes,
    100.0 * sum(case when attendance_ref.status = 'PRESENTE' then 1 else 0 end)
        / count(attendance_ref.id) as resultado_porcentaje_presente
from enrollments as enrollment_ref
  inner join attendance as attendance_ref on enrollment_ref.id = attendance_ref.enrollment_id
group by enrollment_ref.id
having 100.0 * sum(case when attendance_ref.status = 'PRESENTE' then 1 else 0 end)
        / count(attendance_ref.id) >= 80
order by enrollment_ref.id;



-- ----------------------------------------------------------------------

-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar colaboradores que todavía no se han matriculado en ninguna edición. Usar NOT EXISTS.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    collaborator_ref.id as resultado_codigo_colaborador,
    collaborator_ref.name as resultado_colaborador
from collaborators as collaborator_ref
where not exists (
    select 1
    from enrollments as enrollment_ref
where enrollment_ref.collaborator_id = collaborator_ref.id
);



-- ----------------------------------------------------------------------

-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar ediciones cuya capacidad sea mayor al promedio de capacidades de las ediciones.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    edition_ref.code as resultado_edicion,
    edition_ref.capacity as resultado_capacidad
from editions as edition_ref
where edition_ref.capacity > (
    select avg(capacity)
    from editions
);



-- ----------------------------------------------------------------------

-- 20 | SUBCONSULTA. SUBCONSULTA: mostrar colaboradores que estén matriculados en alguna edición del curso con código CUR-IA. Usar IN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    collaborator_ref.id as resultado_codigo_colaborador,
    collaborator_ref.name as resultado_colaborador
from collaborators as collaborator_ref
where collaborator_ref.id in (
    select enrollment_ref.collaborator_id
    from enrollments as enrollment_ref
  inner join editions as edition_ref on enrollment_ref.edition_id = edition_ref.id
  inner join courses as course_ref on edition_ref.course_id = course_ref.id
where course_ref.code = 'CUR-IA'
);
