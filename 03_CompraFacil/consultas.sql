-- Consultas revisadas | 03_CompraFacil
-- Ejecutar el script de base de datos antes de consultar.
-- Las etiquetas resultado_* identifican los campos devueltos.

-- ============================================================
-- COMPRAFÁCIL | 20 EJERCICIOS DQL RESUELTOS
-- Archivo 02/02 | MySQL 8.0.16+
-- Ejecutar primero el DDL y DML del archivo 01_base_datos.sql.
-- Las consultas no modifican los datos semilla.
-- ============================================================

use comprafacil;

-- EJEMPLO DE CLASE (no calificable)
select
    product_ref.id as resultado_codigo_producto,
    product_ref.name as resultado_producto,
    product_ref.active as resultado_activo
from products as product_ref;


-- ----------------------------------------------------------------------

-- 01. Mostrar el código, nombre y correo de los empleados que pueden solicitar compras.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    code as resultado_codigo,
    name as resultado_empleado,
    email as resultado_correo
from employees
order by id;


-- ----------------------------------------------------------------------

-- 02. Mostrar los productos activos y su unidad de medida. Usar WHERE.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    id as resultado_codigo_producto,
    name as resultado_producto,
    unit_of_measure as resultado_unidad_medida
from products
where active = true
order by id;


-- ----------------------------------------------------------------------

-- 03. Listar órdenes con estado PARCIAL o EMITIDA. Usar OR.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    id as resultado_codigo_orden,
    issued_at as resultado_fecha_emision,
    status as resultado_estado
from purchase_orders
where status = 'PARCIAL' or status = 'EMITIDA'
order by id;


-- ----------------------------------------------------------------------

-- 04. Mostrar las solicitudes creadas entre el 1 y el 5 de septiembre de 2026. Usar BETWEEN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    id as resultado_codigo_solicitud,
    created_at as resultado_fecha,
    status as resultado_estado,
    justification as resultado_justificacion
from requests
where created_at between '2026-09-01 00:00:00' and '2026-09-05 23:59:59'
order by id;


-- ----------------------------------------------------------------------

-- 05. Buscar productos cuyo nombre contenga Cable o Teclado. Usar LIKE.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select id as resultado_codigo_producto, name as resultado_producto
from products
where name like '%Cable%' or name like '%Teclado%'
order by id;


-- ----------------------------------------------------------------------

-- 06. Mostrar cada solicitud con el empleado que la creó, su fecha y estado.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    request_ref.id as resultado_codigo_solicitud,
    employee_ref.name as resultado_empleado,
    request_ref.created_at as resultado_fecha,
    request_ref.status as resultado_estado
from requests as request_ref
  inner join employees as employee_ref on request_ref.employee_id = employee_ref.id
order by request_ref.id;


-- ----------------------------------------------------------------------

-- 07. Mostrar cada orden de compra junto con el proveedor y la justificación de la solicitud que originó la orden.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    purchase_order_ref.id as resultado_codigo_orden,
    supplier_ref.company_name as resultado_proveedor,
    request_ref.justification as resultado_justificacion
from purchase_orders as purchase_order_ref
  inner join suppliers as supplier_ref on purchase_order_ref.supplier_id = supplier_ref.id
  inner join requests as request_ref on purchase_order_ref.request_id = request_ref.id
order by purchase_order_ref.id;


-- ----------------------------------------------------------------------

-- 08. Mostrar productos y cantidades requeridas de cada solicitud. Usar JOIN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    request_item_ref.request_id as resultado_codigo_solicitud,
    product_ref.name as resultado_producto,
    request_item_ref.requested_quantity as resultado_cantidad_requerida
from request_items as request_item_ref
  inner join products as product_ref on request_item_ref.product_id = product_ref.id
order by request_item_ref.request_id, request_item_ref.id;


-- ----------------------------------------------------------------------

-- 09. Contar las solicitudes por estado.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select status as resultado_estado, count(*) as resultado_cantidad_solicitudes
from requests
group by status
order by status;


-- ----------------------------------------------------------------------

-- 10. Calcular el valor total de cada orden sumando cantidad ordenada multiplicada por precio unitario.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    purchase_order_ref.id as resultado_codigo_orden,
    coalesce(sum(order_item_ref.ordered_quantity * order_item_ref.unit_price), 0) as resultado_valor_total
from purchase_orders as purchase_order_ref
  left join order_items as order_item_ref on purchase_order_ref.id = order_item_ref.order_id
group by purchase_order_ref.id
order by purchase_order_ref.id;


-- ----------------------------------------------------------------------

-- 11. Mostrar cada recepción con su número de remisión y proveedor.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    receipt_ref.id as resultado_codigo_recepcion,
    receipt_ref.delivery_note as resultado_remision,
    supplier_ref.company_name as resultado_proveedor
from receipts as receipt_ref
  inner join purchase_orders as purchase_order_ref on receipt_ref.order_id = purchase_order_ref.id
  inner join suppliers as supplier_ref on purchase_order_ref.supplier_id = supplier_ref.id
order by receipt_ref.id;


-- ----------------------------------------------------------------------

-- 12. Mostrar los productos recibidos, su cantidad recibida y la remisión correspondiente.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    product_ref.name as resultado_producto,
    receipt_item_ref.received_quantity as resultado_cantidad_recibida,
    receipt_ref.delivery_note as resultado_remision
from receipt_items as receipt_item_ref
  inner join receipts as receipt_ref on receipt_item_ref.receipt_id = receipt_ref.id
  inner join order_items as order_item_ref on receipt_item_ref.order_item_id = order_item_ref.id
  inner join request_items as request_item_ref on order_item_ref.request_item_id = request_item_ref.id
  inner join products as product_ref on request_item_ref.product_id = product_ref.id
order by receipt_item_ref.id;


-- ----------------------------------------------------------------------

-- 13. Calcular la cantidad pendiente por renglón de orden: cantidad ordenada menos lo recibido. Mostrar también los renglones sin recepción.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    order_item_ref.order_id as resultado_codigo_orden,
    order_item_ref.id as resultado_codigo_renglon,
    product_ref.name as resultado_producto,
    order_item_ref.ordered_quantity as resultado_cantidad_ordenada,
    coalesce(sum(receipt_item_ref.received_quantity), 0) as resultado_cantidad_recibida,
    order_item_ref.ordered_quantity - coalesce(sum(receipt_item_ref.received_quantity), 0) as resultado_cantidad_pendiente
from order_items as order_item_ref
  inner join request_items as request_item_ref on order_item_ref.request_item_id = request_item_ref.id
  inner join products as product_ref on request_item_ref.product_id = product_ref.id
  left join receipt_items as receipt_item_ref on order_item_ref.id = receipt_item_ref.order_item_id
group by order_item_ref.order_id, order_item_ref.id, product_ref.id, product_ref.name, order_item_ref.ordered_quantity
order by order_item_ref.order_id, order_item_ref.id;


-- ----------------------------------------------------------------------

-- 14. Contar las órdenes por proveedor, incluyendo proveedores que todavía no tienen órdenes.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    supplier_ref.id as resultado_codigo_proveedor,
    supplier_ref.company_name as resultado_proveedor,
    count(purchase_order_ref.id) as resultado_cantidad_ordenes
from suppliers as supplier_ref
  left join purchase_orders as purchase_order_ref on supplier_ref.id = purchase_order_ref.supplier_id
group by supplier_ref.id, supplier_ref.company_name
order by supplier_ref.id;


-- ----------------------------------------------------------------------

-- 15. Mostrar empleados que hayan realizado dos o más solicitudes. Usar HAVING.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    employee_ref.code as resultado_codigo_empleado,
    employee_ref.name as resultado_empleado,
    count(request_ref.id) as resultado_cantidad_solicitudes
from employees as employee_ref
  inner join requests as request_ref on employee_ref.id = request_ref.employee_id
group by employee_ref.id, employee_ref.code, employee_ref.name
having count(request_ref.id) >= 2
order by employee_ref.id;


-- ----------------------------------------------------------------------

-- 16. Mostrar productos presentes en dos o más renglones de órdenes de compra.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    product_ref.id as resultado_codigo_producto,
    product_ref.name as resultado_producto,
    count(order_item_ref.id) as resultado_cantidad_renglones
from products as product_ref
  inner join request_items as request_item_ref on product_ref.id = request_item_ref.product_id
  inner join order_items as order_item_ref on request_item_ref.id = order_item_ref.request_item_id
group by product_ref.id, product_ref.name
having count(order_item_ref.id) >= 2
order by product_ref.id;


-- ----------------------------------------------------------------------

-- 17. Mostrar los tres renglones de órdenes con mayor valor total (cantidad por precio). Usar LIMIT.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    order_item_ref.id as resultado_codigo_renglon,
    order_item_ref.order_id as resultado_codigo_orden,
    product_ref.name as resultado_producto,
    order_item_ref.ordered_quantity as resultado_cantidad,
    order_item_ref.unit_price as resultado_precio_unitario,
    order_item_ref.ordered_quantity * order_item_ref.unit_price as resultado_valor_total
from order_items as order_item_ref
  inner join request_items as request_item_ref on order_item_ref.request_item_id = request_item_ref.id
  inner join products as product_ref on request_item_ref.product_id = product_ref.id
order by resultado_valor_total desc, order_item_ref.id
limit 3;


-- ----------------------------------------------------------------------

-- 18. SUBCONSULTA: encontrar renglones cuyo precio unitario sea superior al precio unitario promedio.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    order_item_ref.id as resultado_codigo_renglon,
    order_item_ref.order_id as resultado_codigo_orden,
    order_item_ref.unit_price as resultado_precio_unitario
from order_items as order_item_ref
where order_item_ref.unit_price > (
    select avg(unit_price)
    from order_items
)
order by order_item_ref.id;


-- ----------------------------------------------------------------------

-- 19. SUBCONSULTA: listar productos que nunca han aparecido en una orden de compra. Usar NOT EXISTS.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    product_ref.id as resultado_codigo_producto,
    product_ref.name as resultado_producto
from products as product_ref
where not exists (
    select 1
    from request_items as request_item_ref
  inner join order_items as order_item_ref on request_item_ref.id = order_item_ref.request_item_id
where request_item_ref.product_id = product_ref.id
)
order by product_ref.id;


-- ----------------------------------------------------------------------

-- 20. SUBCONSULTA: listar proveedores que tengan al menos una orden PARCIAL. Usar IN.
-- Nota de implementación: se mantienen las condiciones y la cardinalidad solicitadas.
select
    supplier_ref.id as resultado_codigo_proveedor,
    supplier_ref.company_name as resultado_proveedor
from suppliers as supplier_ref
where supplier_ref.id in (
    select purchase_order_ref.supplier_id
    from purchase_orders as purchase_order_ref
where purchase_order_ref.status = 'PARCIAL'
)
order by supplier_ref.id;
