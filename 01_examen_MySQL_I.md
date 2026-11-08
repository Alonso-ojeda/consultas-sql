# Examen práctico final — Análisis de información con MySQL

**Duración:** 3 horas (180 minutos)  
**Modalidad:** individual, con las cinco bases de datos de los talleres  
**Valor:** 100 puntos (10 puntos por consulta)  
**Herramienta:** MySQL 8.x

## Contexto del examen

Durante las clases construimos y consultamos las bases de datos `helpdesk_pro`, `assetcontrol`, `comprafacil`, `talenttrack` y `spacebook`. Ahora actuarás como analista de datos: recibirás solicitudes de distintas áreas de negocio y deberás convertir cada necesidad en **una consulta SQL que proporcione la información correcta**.

Las situaciones no indican qué instrucciones SQL debes utilizar. Debes interpretar el problema, identificar las tablas necesarias y decidir cómo relacionar, filtrar, agrupar y ordenar la información.

**Antes de comenzar:** ejecuta el archivo `01_base_datos.sql` de la versión V2 de cada proyecto, con sus datos semilla. **No necesitas insertar registros adicionales para este examen.** No ejecutes los ejemplos opcionales de `UPDATE`, `DELETE` ni `TRUNCATE`, ni modifiques los datos para conseguir resultados.

Escribe tus respuestas en un archivo llamado `examen_mysql_apellido_nombre.sql`, numeradas del `01` al `10`, con el `USE` correspondiente antes de cada consulta. Debe ser posible ejecutar las diez respuestas en orden. Conserva los identificadores de las bases, tablas y atributos en **inglés, minúsculas y `snake_case`**. Los alias que presentes al usuario pueden estar en español, también en minúsculas y `snake_case`. Si dos tablas generan múltiples registros relacionados, comprueba que los totales no se dupliquen.

**Criterio general:** cuando una cifra sea monetaria, un promedio o un porcentaje, preséntala con dos decimales. Las fechas de referencia son las de los casos, no la fecha actual del sistema. Se califica el resultado y el razonamiento, no una única manera de escribir SQL.

---

## Caso 1. HelpDesk Pro — Mesa de ayuda empresarial

### 01. ¿Qué clientes requieren atención prioritaria? — 10 puntos

La gerencia de HelpDesk Pro observa que algunos clientes generan numerosos reportes y quiere decidir a cuáles asignará primero recursos de soporte. Para su reunión de seguimiento solo le interesan los **clientes activos** que hayan registrado **al menos dos tickets** y todavía tengan **algún ticket sin resolver**. Para este análisis, considera pendientes los casos en estado `ABIERTO` o `EN_PROCESO`.

Prepara un informe de una fila por cliente. La gerencia necesita ver su nombre comercial, el número total de tickets de cualquier estado, el número de pendientes, cuántos de estos pendientes son de prioridad `CRITICA` y la fecha en que ese cliente abrió su ticket más reciente, incluso si ya fue cerrado. Los clientes con más pendientes deben aparecer primero; cuando exista empate, ordénalos alfabéticamente.

**Columnas que debe recibir la gerencia, en este orden:** `cliente`, `total_tickets`, `tickets_pendientes`, `criticos_pendientes`, `ultima_apertura`.

```sql
USE helpdesk_pro;

-- 01. Tu consulta

SELECT
    c.company_name AS cliente,
    COUNT(t.id) AS total_tickets,
    SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO') THEN 1 ELSE 0 END) AS tickets_pendientes,
    SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO') AND t.priority = 'CRITICA' THEN 1 ELSE 0 END) AS criticos_pendientes,
    MAX(t.opened_at) AS ultima_apertura
FROM clients AS c
JOIN contacts AS co ON c.id = co.client_id
JOIN tickets AS t ON co.id = t.contact_id
WHERE c.status = 'ACTIVO'
GROUP BY c.id, c.company_name
HAVING COUNT(t.id) >= 2
    AND SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO') THEN 1 ELSE 0 END) > 0
ORDER BY tickets_pendientes DESC, cliente;

```

### 02. ¿Qué responsables no han respondido a sus tickets? — 10 puntos

El coordinador de soporte detectó que algunos incidentes están asignados, pero su responsable actual aún no ha escrito una respuesta. Quiere enviarles un recordatorio sin responsabilizar a técnicos que ya terminaron su asignación ni confundir los comentarios de un cliente o de otro técnico con los del responsable vigente.

Entrégale los tickets que sigan `ABIERTO` o `EN_PROCESO`, tengan una asignación **sin fecha de finalización** y no registren **ningún comentario escrito por el técnico de esa asignación en ese mismo ticket**. Para cada caso deben aparecer el código del ticket, asunto, empresa cliente, técnico responsable, prioridad y fecha de inicio de la asignación. Presenta primero los tickets abiertos hace más tiempo y utiliza su código para desempatar.

**Columnas esperadas:** `codigo_ticket`, `asunto`, `cliente`, `tecnico`, `prioridad`, `asignado_desde`.

```sql
USE helpdesk_pro;

-- 02. Tu consulta

SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    c.company_name AS cliente,
    te.name AS tecnico,
    t.priority AS prioridad,
    a.started_at AS asignado_desde
FROM tickets AS t
JOIN contacts AS co ON t.contact_id = co.id
JOIN clients AS c ON co.client_id = c.id
JOIN assignments AS a ON t.id = a.ticket_id
JOIN technicians AS te ON a.technician_id = te.id
WHERE t.status IN ('ABIERTO', 'EN_PROCESO')
    AND a.ended_at IS NULL
    AND NOT EXISTS (
        SELECT 1
        FROM comments AS cm
        WHERE cm.ticket_id = t.id
            AND cm.technician_id = a.technician_id
    )
ORDER BY t.opened_at, t.id;

```

---

## Caso 2. AssetControl — Inventario tecnológico

### 03. ¿En qué sedes se está invirtiendo más en mantenimiento? — 10 puntos

La dirección de tecnología debe distribuir su presupuesto del próximo trimestre. Antes de hacerlo necesita comparar las sedes que tienen **dos o más equipos en inventario**, incluidos los disponibles, asignados o dados de baja. También quiere distinguir entre tener muchos equipos y tener muchos mantenimientos sobre un mismo equipo.

El informe debe contener una fila por sede con su nombre y ciudad, cuántos **equipos distintos** tiene registrados, cuántos de ellos han recibido alguna intervención, cuánto suman los costos de **todos** sus mantenimientos y cuál es el costo promedio por equipo de inventario. Este último indicador se calcula dividiendo el gasto acumulado entre todos los equipos registrados en la sede, no entre los mantenimientos realizados. Si no existe ningún mantenimiento, el gasto y el promedio deberán mostrarse como cero. Organiza las sedes por gasto total descendente y usa el nombre como desempate.

**Columnas esperadas:** `sede`, `ciudad`, `total_equipos`, `equipos_intervenidos`, `costo_total`, `promedio_por_equipo`.

```sql
USE assetcontrol;

-- 03. Tu consulta

SELECT
    s.name AS sede,
    s.city AS ciudad,
    COUNT(a.id) AS total_equipos,
    COUNT(m.asset_id) AS equipos_intervenidos,
    CAST(COALESCE(SUM(m.costo), 0) AS DECIMAL(18,2)) AS costo_total,
    CAST(COALESCE(SUM(m.costo), 0) / COUNT(a.id) AS DECIMAL(18,2)) AS promedio_por_equipo
FROM sites AS s
JOIN assets AS a ON s.id = a.site_id
LEFT JOIN (
    SELECT asset_id, SUM(cost) AS costo
    FROM maintenance
    GROUP BY asset_id
) AS m ON a.id = m.asset_id
GROUP BY s.id, s.name, s.city
HAVING COUNT(a.id) >= 2
ORDER BY costo_total DESC, sede;

```

### 04. ¿Qué equipos están bajo custodia de otra sede? — 10 puntos

Durante una auditoría, el área administrativa descubrió que algunos activos pueden estar asignados a colaboradores cuyo departamento pertenece a una sede diferente de la sede responsable del inventario. Esto no es necesariamente un error, pero debe revisarse porque puede afectar los controles de custodia.

Identifica exclusivamente las asignaciones **que todavía no tienen fecha de devolución** y en las que las dos sedes no coincidan. Auditoría necesita el identificador patrimonial, la marca del equipo, el nombre del colaborador, su departamento, el nombre de la sede responsable del activo, el nombre de la sede a la que pertenece el departamento y la fecha de asignación. Presenta los equipos ordenados por su identificador patrimonial.

**Columnas esperadas:** `codigo_activo`, `marca`, `empleado`, `departamento`, `sede_inventario`, `sede_departamento`, `fecha_asignacion`.

```sql
USE assetcontrol;

-- 04. Tu consulta

SELECT
    a.patrimonial_identifier AS codigo_activo,
    a.brand AS marca,
    e.name AS empleado,
    d.name AS departamento,
    si.name AS sede_inventario,
    sd.name AS sede_departamento,
    asi.started_at AS fecha_asignacion
FROM assignments AS asi
JOIN assets AS a ON asi.asset_id = a.id
JOIN employees AS e ON asi.employee_id = e.id
JOIN departments AS d ON e.department_id = d.id
JOIN sites AS si ON a.site_id = si.id
JOIN sites AS sd ON d.site_id = sd.id
WHERE asi.return_date IS NULL
    AND a.site_id <> d.site_id
ORDER BY a.patrimonial_identifier;

```

---

## Caso 3. CompraFácil — Gestión de compras

### 05. ¿Cuánto dinero comprometido falta por recibir? — 10 puntos

El departamento financiero revisará las órdenes de compra para saber cuánto dinero se comprometió con los proveedores y qué parte de los productos ya fue recibida. Algunas órdenes contienen varios renglones; otras tienen entregas parciales y un mismo renglón puede aparecer en varias recepciones. También existen órdenes que aún no han recibido nada.

Construye un estado por **cada orden que no esté `ANULADA`**, incluidas las que no registran recepciones. El valor ordenado es la suma de las cantidades compradas multiplicadas por sus precios unitarios acordados; el valor recibido se obtiene de las cantidades efectivamente recibidas en todas las entregas, valoradas a esos mismos precios. La diferencia corresponde al saldo pendiente. Una entrega parcial no debe hacer que se cuente dos veces el valor original de la orden. Las órdenes con mayor saldo pendiente aparecerán primero; resuelve los empates por código de orden.

**Columnas esperadas:** `codigo_orden`, `proveedor`, `estado`, `valor_ordenado`, `valor_recibido`, `saldo_pendiente`.

```sql
USE comprafacil;

-- 05. Tu consulta

SELECT
    po.id AS codigo_orden,
    s.company_name AS proveedor,
    po.status AS estado,
    CAST(COALESCE(SUM(oi.ordered_quantity * oi.unit_price), 0) AS DECIMAL(18,2)) AS valor_ordenado,
    CAST(COALESCE(SUM(rc.cantidad_recibida * oi.unit_price), 0) AS DECIMAL(18,2)) AS valor_recibido,
    CAST(COALESCE(SUM(oi.ordered_quantity * oi.unit_price), 0)
        - COALESCE(SUM(rc.cantidad_recibida * oi.unit_price), 0) AS DECIMAL(18,2)) AS saldo_pendiente
FROM purchase_orders AS po
JOIN suppliers AS s ON po.supplier_id = s.id
LEFT JOIN order_items AS oi ON po.id = oi.order_id
LEFT JOIN (
    SELECT order_item_id, SUM(received_quantity) AS cantidad_recibida
    FROM receipt_items
    GROUP BY order_item_id
) AS rc ON oi.id = rc.order_item_id
WHERE po.status <> 'ANULADA'
GROUP BY po.id, s.company_name, po.status
ORDER BY saldo_pendiente DESC, po.id;

```

### 06. ¿Qué productos se piden reiteradamente y aún no se compran en su totalidad? — 10 puntos

Compras sospecha que hay productos que aparecen de manera recurrente en las solicitudes internas, pero que siguen pendientes de ordenar. Para determinarlo, revisará **todas las solicitudes registradas**, independientemente de su estado, y prestará especial atención a productos presentes en **dos o más solicitudes diferentes**.

Para cada producto que cumpla esa condición, compara el total solicitado con el total efectivamente incluido en los renglones de las órdenes de compra vinculadas a esas solicitudes. Cuando una solicitud todavía no tenga orden, debe seguir contando como cantidad solicitada y aportar cero a la cantidad ordenada. El área solo quiere conocer los productos cuya cantidad solicitada **supere** a la ordenada. Incluye su SKU, nombre, número de solicitudes distintas, cantidades solicitadas y ordenadas, y cantidad restante por ordenar. Muestra primero el mayor faltante y usa el SKU para desempatar.

**Columnas esperadas:** `sku`, `producto`, `solicitudes`, `cantidad_solicitada`, `cantidad_ordenada`, `cantidad_no_ordenada`.

```sql
USE comprafacil;

-- 06. Tu consulta

SELECT
    p.sku AS sku,
    p.name AS producto,
    COUNT(DISTINCT ri.request_id) AS solicitudes,
    SUM(ri.requested_quantity) AS cantidad_solicitada,
    COALESCE(SUM(oi.ordered_quantity), 0) AS cantidad_ordenada,
    SUM(ri.requested_quantity) - COALESCE(SUM(oi.ordered_quantity), 0) AS cantidad_no_ordenada
FROM products AS p
JOIN request_items AS ri ON p.id = ri.product_id
LEFT JOIN order_items AS oi ON ri.id = oi.request_item_id
GROUP BY p.id, p.sku, p.name
HAVING COUNT(DISTINCT ri.request_id) >= 2
    AND SUM(ri.requested_quantity) > COALESCE(SUM(oi.ordered_quantity), 0)
ORDER BY cantidad_no_ordenada DESC, p.sku;

```

---

## Caso 4. TalentTrack — Formación corporativa

### 07. ¿Quiénes reúnen las condiciones para certificarse? — 10 puntos

La coordinación académica va a auditar la emisión de certificados. Quiere revisar **todas las matrículas**, incluso aquellas cuyos estudiantes aún no tienen asistencias registradas. Para este ejercicio, una matrícula es **apta para certificarse** únicamente cuando su edición está `FINALIZADA`, existe un registro de asistencia para **cada sesión programada de esa misma edición** y se asistió en estado `PRESENTE` a por lo menos el **80 %** de esas sesiones. Tener un certificado registrado no reemplaza estas condiciones.

Construye un reporte que muestre el código de cada matrícula, el colaborador, el código de edición, cuántas sesiones están programadas, en cuántas se registró asistencia y cuántas figuran como `PRESENTE`. Calcula el porcentaje de presencias sobre las sesiones programadas. Añade una respuesta `SI` o `NO` para señalar si es apta y otra para señalar si **ya tiene certificado emitido**. Una matrícula sin presencias debe mostrar cero por ciento cuando tenga sesiones programadas. Ordena por código de edición y nombre del colaborador.

**Columnas esperadas:** `codigo_matricula`, `colaborador`, `edicion`, `sesiones_programadas`, `asistencias_registradas`, `presencias`, `porcentaje_asistencia`, `apto_para_certificado`, `certificado_emitido`.

```sql
USE talenttrack;

-- 07. Tu consulta

SELECT
    en.id AS codigo_matricula,
    c.name AS colaborador,
    e.code AS edicion,
    COUNT(s.id) AS sesiones_programadas,
    COUNT(a.id) AS asistencias_registradas,
    SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) AS presencias,
    CAST(COALESCE(100.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(s.id), 0), 0) AS DECIMAL(7,2)) AS porcentaje_asistencia,
    CASE WHEN e.status = 'FINALIZADA'
        AND COUNT(s.id) > 0
        AND COUNT(a.id) = COUNT(s.id)
        AND 100.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) / COUNT(s.id) >= 80
        THEN 'SI' ELSE 'NO' END AS apto_para_certificado,
    CASE WHEN ce.id IS NOT NULL THEN 'SI' ELSE 'NO' END AS certificado_emitido
FROM enrollments AS en
JOIN collaborators AS c ON en.collaborator_id = c.id
JOIN editions AS e ON en.edition_id = e.id
LEFT JOIN sessions AS s ON e.id = s.edition_id
LEFT JOIN attendance AS a ON en.id = a.enrollment_id AND s.id = a.session_id
LEFT JOIN certificates AS ce ON en.id = ce.enrollment_id
GROUP BY en.id, c.name, e.code, e.status, ce.id
ORDER BY e.code, c.name;

```

### 08. ¿Qué empresas obtienen mejores resultados de certificación? — 10 puntos

La dirección comercial desea comparar la efectividad de su oferta de formación entre las empresas clientes **activas** que hayan acumulado **dos o más matrículas**. Una misma persona puede matricularse en varias ediciones; en ese caso, representa un solo colaborador, pero varias matrículas. Igualmente, dos ediciones de un mismo curso representan un solo curso distinto.

Para cada empresa incluida en el análisis, informa cuántos colaboradores diferentes se han matriculado, el total de matrículas, la cantidad de cursos distintos cursados, el total de certificados efectivamente emitidos y la tasa de certificación calculada como **certificados emitidos dividido entre matrículas, multiplicado por 100**. Presenta primero las empresas con la tasa más alta; en caso de empate, utiliza el nombre de la empresa en orden alfabético.

**Columnas esperadas:** `empresa`, `colaboradores_matriculados`, `total_matriculas`, `cursos_distintos`, `certificados_emitidos`, `tasa_certificacion`.

```sql
USE talenttrack;

-- 08. Tu consulta

SELECT
    co.company_name AS empresa,
    COUNT(DISTINCT c.id) AS colaboradores_matriculados,
    COUNT(en.id) AS total_matriculas,
    COUNT(DISTINCT e.course_id) AS cursos_distintos,
    COUNT(ce.id) AS certificados_emitidos,
    CAST(100.0 * COUNT(ce.id) / COUNT(en.id) AS DECIMAL(7,2)) AS tasa_certificacion
FROM companies AS co
JOIN collaborators AS c ON co.id = c.company_id
JOIN enrollments AS en ON c.id = en.collaborator_id
JOIN editions AS e ON en.edition_id = e.id
LEFT JOIN certificates AS ce ON en.id = ce.enrollment_id
WHERE co.status = 'ACTIVA'
GROUP BY co.id, co.company_name
HAVING COUNT(en.id) >= 2
ORDER BY tasa_certificacion DESC, empresa;

```

---

## Caso 5. SpaceBook — Reservas de salas

### 09. ¿Qué salas se pueden reservar en el horario solicitado? — 10 puntos

Un empleado necesita una sala para una reunión el **3 de noviembre de 2026**, desde las **8:30 a. m. hasta las 9:30 a. m.** Puede desplazarse a cualquiera de las sedes y desea conocer todas las salas activas realmente disponibles.

Para considerar una sala disponible, no debe existir ninguna reserva en estado `CONFIRMADA` que ocupe **alguna parte** de ese intervalo, ni un bloqueo de sala por mantenimiento o limpieza que se cruce con él. Las reservas `SOLICITADA`, `CANCELADA` o `FINALIZADA` no deben impedir la selección. Si una ocupación termina exactamente al comenzar la reunión, o empieza exactamente cuando esta termina, no representa un conflicto. Prepara la relación de salas disponibles con su código, nombre, sede, ciudad y capacidad. Ordénalas alfabéticamente por sede y después por sala.

**Columnas esperadas:** `codigo_sala`, `sala`, `sede`, `ciudad`, `capacidad`.

```sql
USE spacebook;

-- 09. Tu consulta

SELECT
    r.code AS codigo_sala,
    r.name AS sala,
    s.name AS sede,
    s.city AS ciudad,
    r.capacity AS capacidad
FROM rooms AS r
JOIN sites AS s ON r.site_id = s.id
WHERE r.status = 'ACTIVA'
    AND NOT EXISTS (
        SELECT 1
        FROM reservations AS re
        WHERE re.room_id = r.id
            AND re.status = 'CONFIRMADA'
            AND re.started_at < '2026-11-03 09:30:00'
            AND re.ended_at > '2026-11-03 08:30:00'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM room_blocks AS rb
        WHERE rb.room_id = r.id
            AND rb.started_at < '2026-11-03 09:30:00'
            AND rb.ended_at > '2026-11-03 08:30:00'
    )
ORDER BY s.name, r.name;

```

### 10. ¿Cómo se está utilizando el aforo de las reuniones confirmadas? — 10 puntos

La administración necesita comparar las reuniones en estado `CONFIRMADA` para conocer sus participantes y recursos reservados. En una reunión puede haber varios invitados y también varios recursos, por lo que no debe repetirse una persona o un dispositivo al calcular los totales.

Por cada reserva confirmada, presenta el código, la sala, el organizador y la capacidad. Indica cuántas personas fueron invitadas en total, cuántas respondieron `ACEPTADA`, cuántas `RECHAZADA` y cuántos recursos diferentes están asociados a la reunión. Para este informe, el número de asistentes confirmados será **el organizador más todos los invitados que aceptaron**; cuenta al organizador como una persona adicional, conforme a la regla del examen. Calcula qué porcentaje de la capacidad representa ese número. Organiza las reuniones de mayor a menor porcentaje de aforo, con el código de reserva como desempate.

**Columnas esperadas:** `codigo_reserva`, `sala`, `organizador`, `capacidad`, `invitados`, `aceptados`, `rechazados`, `recursos`, `asistentes_confirmados`, `porcentaje_aforo`.

```sql
USE spacebook;

-- 10. Tu consulta

SELECT
    re.id AS codigo_reserva,
    r.name AS sala,
    e.name AS organizador,
    r.capacity AS capacidad,
    COALESCE(p.invitados, 0) AS invitados,
    COALESCE(p.aceptados, 0) AS aceptados,
    COALESCE(p.rechazados, 0) AS rechazados,
    COALESCE(rec.recursos, 0) AS recursos,
    1 + COALESCE(p.aceptados, 0) AS asistentes_confirmados,
    CAST(100.0 * (1 + COALESCE(p.aceptados, 0)) / r.capacity AS DECIMAL(10,2)) AS porcentaje_aforo
FROM reservations AS re
JOIN rooms AS r ON re.room_id = r.id
JOIN employees AS e ON re.organizer_id = e.id
LEFT JOIN (
    SELECT
        reservation_id,
        COUNT(*) AS invitados,
        SUM(CASE WHEN response = 'ACEPTADA' THEN 1 ELSE 0 END) AS aceptados,
        SUM(CASE WHEN response = 'RECHAZADA' THEN 1 ELSE 0 END) AS rechazados
    FROM reservation_participants
    GROUP BY reservation_id
) AS p ON re.id = p.reservation_id
LEFT JOIN (
    SELECT reservation_id, COUNT(DISTINCT resource_id) AS recursos
    FROM reservation_resources
    GROUP BY reservation_id
) AS rec ON re.id = rec.reservation_id
WHERE re.status = 'CONFIRMADA'
ORDER BY porcentaje_aforo DESC, re.id;

```

---

## Evaluación

Cada situación vale **10 puntos**: interpretación de las reglas del negocio (4), relaciones correctas entre tablas (3), exactitud de resultados y ausencia de duplicados (2), presentación de campos y orden solicitado (1).

**Antes de entregar:** verifica que todas las consultas puedan ejecutarse después de cargar las cinco bases originales, sin cambios a los datos; que los conteos de elementos distintos sean correctos y que los casos sin registros relacionados se manejen de acuerdo con cada situación.

**Fin del examen.**
