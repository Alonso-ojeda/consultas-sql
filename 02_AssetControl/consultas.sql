-- Consultas revisadas | 02_AssetControl
-- Ejecutar el script de base de datos antes de consultar.
-- Las etiquetas resultado_* identifican los campos devueltos.

-- ============================================================
-- Colección de consultas resueltas para revisión y práctica.
-- Archivo de consultas: 20 ejercicios y un ejemplo inicial.
-- Base de datos: assetcontrol
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- Las consultas son de lectura; no alteran los datos iniciales.
-- Los encabezados calculados se identifican mediante resultado_.
-- ============================================================

set names utf8mb4;
use assetcontrol;

-- EJEMPLO DE CLASE (no calificable)
select
    asset_ref.id as resultado_codigo_activo,
    asset_ref.brand as resultado_marca,
    asset_ref.model as resultado_modelo,
    asset_ref.status as resultado_estado
from assets as asset_ref;


-- ----------------------------------------------------------------------

-- 01. Mostrar el código, marca, modelo y estado de todos los activos, como se trabajó en clase.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo,
    brand as resultado_marca,
    model as resultado_modelo,
    status as resultado_estado
from assets;


-- ----------------------------------------------------------------------

-- 02. Mostrar cada equipo junto con el nombre de su tipo. Usar alias a y at y un JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_ref.id as resultado_codigo,
    asset_type_ref.name as resultado_nombre_tipo
from asset_types as asset_type_ref
  inner join assets as asset_ref
    on asset_type_ref.id = asset_ref.asset_type_id;



-- ----------------------------------------------------------------------

-- 03. Filtrar los equipos DISPONIBLES que sean de tipo Portátil o Proyector.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_ref.id as resultado_codigo_equipo,
    asset_type_ref.name as resultado_equipo,
    asset_ref.brand as resultado_marca,
    asset_ref.model as resultado_modelo
from asset_types as asset_type_ref
  inner join assets as asset_ref
    on asset_type_ref.id = asset_ref.asset_type_id
where asset_ref.status = 'DISPONIBLE'
      and asset_type_ref.name in ('Portatil', 'Proyector');


-- ----------------------------------------------------------------------

-- 04. Listar los empleados ACTIVOS del departamento Tecnología, con el nombre del departamento. Ordenar por empleado descendente.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    employee_ref.employee_code as resultado_codigo_empleado,
    employee_ref.name as resultado_empleado,
    department_ref.name as resultado_departamento
from employees as employee_ref
  inner join departments as department_ref on employee_ref.department_id = department_ref.id
where employee_ref.status = 'ACTIVO'
      and department_ref.name = 'Tecnologia'
order by employee_ref.name desc;


-- ----------------------------------------------------------------------

-- 05. Listar los equipos comprados entre el 1 de enero de 2025 y el 31 de diciembre de 2025.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo_equipo,
    patrimonial_identifier as resultado_codigo_patrimonial,
    brand as resultado_marca,
    model as resultado_modelo,
    purchase_date as resultado_fecha_compra
from assets
where purchase_date between '2025-01-01' and '2025-12-31'
order by purchase_date, id;


-- ----------------------------------------------------------------------

-- 06. Mostrar cada equipo junto a la sede y ciudad a las que pertenece.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_ref.id as resultado_codigo_equipo,
    asset_ref.brand as resultado_marca,
    asset_ref.model as resultado_modelo,
    site_ref.name as resultado_sede,
    site_ref.city as resultado_ciudad
from assets as asset_ref
  inner join sites as site_ref on asset_ref.site_id = site_ref.id
order by asset_ref.id;


-- ----------------------------------------------------------------------

-- 07. Mostrar los equipos que tienen una asignación vigente y el nombre del empleado que los tiene.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_ref.id as resultado_codigo_equipo,
    asset_ref.brand as resultado_marca,
    asset_ref.model as resultado_modelo,
    employee_ref.name as resultado_empleado
from assets as asset_ref
  inner join assignments as assignment_ref on asset_ref.id = assignment_ref.asset_id
  inner join employees as employee_ref on assignment_ref.employee_id = employee_ref.id
where assignment_ref.return_date is null
order by asset_ref.id;


-- ----------------------------------------------------------------------

-- 08. Mostrar cada mantenimiento junto con el activo intervenido, el tipo y su costo.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    maintenance_ref.id as resultado_codigo_mantenimiento,
    asset_ref.patrimonial_identifier as resultado_codigo_patrimonial,
    asset_ref.brand as resultado_marca,
    asset_ref.model as resultado_modelo,
    maintenance_ref.type as resultado_tipo_mantenimiento,
    maintenance_ref.cost as resultado_costo
from maintenance as maintenance_ref
  inner join assets as asset_ref on maintenance_ref.asset_id = asset_ref.id
order by maintenance_ref.id;


-- ----------------------------------------------------------------------

-- 09. Contar los equipos por estado, ordenados de mayor a menor cantidad.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    status as resultado_estado,
    count(*) as resultado_cantidad_equipos
from assets
group by status
order by resultado_cantidad_equipos desc, status;


-- ----------------------------------------------------------------------

-- 10. Contar los equipos registrados por sede, incluyendo sedes sin equipos. Usar LEFT JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    site_ref.code as resultado_codigo_sede,
    site_ref.name as resultado_sede,
    count(asset_ref.id) as resultado_cantidad_equipos
from sites as site_ref
  left join assets as asset_ref on site_ref.id = asset_ref.site_id
group by site_ref.id, site_ref.code, site_ref.name
order by site_ref.id;


-- ----------------------------------------------------------------------

-- 11. Calcular el costo total de mantenimientos por activo. Mostrar solo activos con mantenimiento.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_ref.id as resultado_codigo_equipo,
    asset_ref.patrimonial_identifier as resultado_codigo_patrimonial,
    sum(maintenance_ref.cost) as resultado_costo_total_mantenimiento
from assets as asset_ref
  inner join maintenance as maintenance_ref on asset_ref.id = maintenance_ref.asset_id
group by asset_ref.id, asset_ref.patrimonial_identifier
order by asset_ref.id;


-- ----------------------------------------------------------------------

-- 12. Contar cuántos equipos vigentes tiene cada empleado, incluyendo los que no tienen ninguno.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    employee_ref.employee_code as resultado_codigo_empleado,
    employee_ref.name as resultado_empleado,
    count(assignment_ref.id) as resultado_cantidad_equipos_vigentes
from employees as employee_ref
  left join assignments as assignment_ref
    on employee_ref.id = assignment_ref.employee_id
      and assignment_ref.return_date is null
group by employee_ref.id, employee_ref.employee_code, employee_ref.name
order by employee_ref.id;


-- ----------------------------------------------------------------------

-- 13. Encontrar los tipos de equipo que tengan dos o más activos. Usar HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_type_ref.name as resultado_tipo_equipo,
    count(asset_ref.id) as resultado_cantidad_activos
from asset_types as asset_type_ref
  inner join assets as asset_ref on asset_type_ref.id = asset_ref.asset_type_id
group by asset_type_ref.id, asset_type_ref.name
having count(asset_ref.id) >= 2
order by resultado_cantidad_activos desc, asset_type_ref.id;


-- ----------------------------------------------------------------------

-- 14. Calcular el costo promedio de mantenimiento por tipo: PREVENTIVO o CORRECTIVO.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    type as resultado_tipo_mantenimiento,
    avg(cost) as resultado_costo_promedio
from maintenance
group by type
order by type;


-- ----------------------------------------------------------------------

-- 15. Mostrar los tres mantenimientos más costosos, con su descripción y costo.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    id as resultado_codigo_mantenimiento,
    description as resultado_descripcion,
    cost as resultado_costo
from maintenance
order by cost desc, id
limit 3;


-- ----------------------------------------------------------------------

-- 16. Consultar el nombre y departamento de quienes tienen equipos asignados actualmente.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select distinct
    employee_ref.name as resultado_empleado,
    department_ref.name as resultado_departamento
from employees as employee_ref
  inner join departments as department_ref on employee_ref.department_id = department_ref.id
  inner join assignments as assignment_ref on employee_ref.id = assignment_ref.employee_id
where assignment_ref.return_date is null
order by resultado_empleado, resultado_departamento;


-- ----------------------------------------------------------------------

-- 17. Mostrar los activos que actualmente no tienen ninguna asignación abierta, usando LEFT JOIN e IS NULL.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_ref.id as resultado_codigo_equipo,
    asset_ref.patrimonial_identifier as resultado_codigo_patrimonial,
    asset_ref.brand as resultado_marca,
    asset_ref.model as resultado_modelo,
    asset_ref.status as resultado_estado
from assets as asset_ref
  left join assignments as assignment_ref
    on asset_ref.id = assignment_ref.asset_id
      and assignment_ref.return_date is null
where assignment_ref.id is null
order by asset_ref.id;


-- ----------------------------------------------------------------------

-- 18 | SUBCONSULTA. SUBCONSULTA: mostrar mantenimientos con costo superior al costo promedio de todos los mantenimientos.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    maintenance_ref.id as resultado_codigo_mantenimiento,
    maintenance_ref.asset_id as resultado_codigo_equipo,
    maintenance_ref.type as resultado_tipo_mantenimiento,
    maintenance_ref.description as resultado_descripcion,
    maintenance_ref.cost as resultado_costo
from maintenance as maintenance_ref
where maintenance_ref.cost > (
    select avg(cost)
    from maintenance
)
order by maintenance_ref.cost desc, maintenance_ref.id;


-- ----------------------------------------------------------------------

-- 19 | SUBCONSULTA. SUBCONSULTA: buscar empleados que figuren en asignaciones vigentes mediante IN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    employee_ref.employee_code as resultado_codigo_empleado,
    employee_ref.name as resultado_empleado,
    employee_ref.email as resultado_correo
from employees as employee_ref
where employee_ref.id in (
    select assignment_ref.employee_id
    from assignments as assignment_ref
where assignment_ref.return_date is null
)
order by employee_ref.id;


-- ----------------------------------------------------------------------

-- 20 | SUBCONSULTA. SUBCONSULTA: encontrar activos que nunca han tenido un mantenimiento mediante NOT EXISTS.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
-- Lectura de datos del escenario sin modificar registros.
select
    asset_ref.id as resultado_codigo_equipo,
    asset_ref.patrimonial_identifier as resultado_codigo_patrimonial,
    asset_ref.brand as resultado_marca,
    asset_ref.model as resultado_modelo
from assets as asset_ref
where not exists (
    select 1
    from maintenance as maintenance_ref
where maintenance_ref.asset_id = asset_ref.id
)
order by asset_ref.id;

