-- Preparación del escenario: 03_CompraFacil
-- Este script define las relaciones y carga registros de demostración.
-- Precaución: recrea la base; no usar sobre datos que deban conservarse.

drop database if exists comprafacil;
create database comprafacil character set utf8mb4;

show databases;
use comprafacil;

create table employees (
    id BIGINT auto_increment primary key,
    code VARCHAR(30) not null unique,
    name VARCHAR(150) not null,
    email VARCHAR(255) not null unique
) engine=InnoDB;

create table products (
    id BIGINT auto_increment primary key,
    sku VARCHAR(50) not null unique,
    name VARCHAR(150) not null,
    unit_of_measure VARCHAR(30) not null,
    active BOOLEAN not null default true
) engine=InnoDB;

create table suppliers (
    id BIGINT auto_increment primary key,
    nit VARCHAR(25) not null unique,
    company_name VARCHAR(180) not null,
    email VARCHAR(255) not null,
    status VARCHAR(15) not null default 'ACTIVO',
    constraint chk_suppliers_1 check (status in ('ACTIVO','INACTIVO'))
) engine=InnoDB;

create table requests (
    id BIGINT auto_increment primary key,
    employee_id BIGINT not null,
    created_at DATETIME not null default current_timestamp,
    status VARCHAR(20) not null default 'BORRADOR',
    justification TEXT not null,
    constraint chk_requests_1 check (status in ('BORRADOR','EN_REVISION','APROBADA','RECHAZADA')),
    foreign key (employee_id) references employees(id)
) engine=InnoDB;

create table request_items (
    id BIGINT auto_increment primary key,
    request_id BIGINT not null,
    product_id BIGINT not null,
    requested_quantity DECIMAL(12,2) not null,
    constraint uq_request_items_1 unique (request_id, product_id),
    constraint chk_request_items_1 check (requested_quantity > 0),
    foreign key (request_id) references requests(id),
    foreign key (product_id) references products(id)
) engine=InnoDB;

create table purchase_orders (
    id BIGINT auto_increment primary key,
    request_id BIGINT not null unique,
    supplier_id BIGINT not null,
    issued_at DATETIME not null default current_timestamp,
    status VARCHAR(15) not null default 'EMITIDA',
    constraint chk_purchase_orders_1 check (status in ('EMITIDA','PARCIAL','RECIBIDA','ANULADA')),
    foreign key (request_id) references requests(id),
    foreign key (supplier_id) references suppliers(id)
) engine=InnoDB;

create table order_items (
    id BIGINT auto_increment primary key,
    order_id BIGINT not null,
    request_item_id BIGINT not null unique,
    ordered_quantity DECIMAL(12,2) not null,
    unit_price DECIMAL(14,2) not null,
    constraint chk_order_items_1 check (ordered_quantity > 0),
    constraint chk_order_items_2 check (unit_price >= 0),
    foreign key (order_id) references purchase_orders(id),
    foreign key (request_item_id) references request_items(id)
) engine=InnoDB;

create table receipts (
    id BIGINT auto_increment primary key,
    order_id BIGINT not null,
    delivery_note VARCHAR(50) not null unique,
    received_at DATETIME not null default current_timestamp,
    notes VARCHAR(255) null,
    foreign key (order_id) references purchase_orders(id)
) engine=InnoDB;

create table receipt_items (
    id BIGINT auto_increment primary key,
    receipt_id BIGINT not null,
    order_item_id BIGINT not null,
    received_quantity DECIMAL(12,2) not null,
    constraint uq_receipt_items_1 unique (receipt_id,order_item_id),
    constraint chk_receipt_items_1 check (received_quantity > 0),
    foreign key (receipt_id) references receipts(id),
    foreign key (order_item_id) references order_items(id)
) engine=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

use comprafacil;
insert into employees (code,name,email) values
('C-001','Ana Torres','ana@compras.test'),('C-002','Luis Herrera','luis@compras.test'),('C-003','Sara Díaz','sara@compras.test'),('C-004','Carlos Vega','carlos@compras.test'),('C-005','Mónica Gil','monica@compras.test');
insert into products (sku,name,unit_of_measure,active) values
('TEC-001','Teclado USB','UND',true),('MOU-002','Mouse óptico','UND',true),('PAP-003','Resma de papel','PAQ',true),('MON-004','Monitor 24 pulgadas','UND',true),('CAB-005','Cable HDMI','UND',true),('SIL-006','Silla ergonómica','UND',true),('TIN-007','Tóner negro','UND',false),('LAM-008','Lámpara de escritorio','UND',true);
insert into suppliers (nit,company_name,email,status) values
('901100001-1','TecnoMayorista SAS','ventas@tecnom.test','ACTIVO'),('901100002-2','OfiSuministros SAS','pedidos@ofis.test','ACTIVO'),('901100003-3','Dotaciones Norte SAS','contacto@dotaciones.test','ACTIVO'),('901100004-4','Proveedora Andina SAS','hola@andina.test','INACTIVO');
insert into requests (employee_id,created_at,status,justification) values
(1,'2026-09-01 08:00:00','APROBADA','Periféricos nuevos'),
(2,'2026-09-02 09:00:00','APROBADA','Papelería mensual'),
(3,'2026-09-03 11:00:00','APROBADA','Monitores de equipo'),
(4,'2026-09-04 14:00:00','EN_REVISION','Adecuación de oficina'),
(5,'2026-09-05 10:00:00','RECHAZADA','Gasto no presupuestado'),
(1,'2026-09-06 15:00:00','APROBADA','Accesorios sala'),
(2,'2026-09-07 08:00:00','APROBADA','Insumos del mes siguiente');
insert into request_items (request_id,product_id,requested_quantity) values
(1,1,10),(1,2,5),(2,3,20),(3,4,4),(3,5,4),(4,6,8),(5,7,2),(6,5,10),(6,1,5),(7,3,12);
insert into purchase_orders (request_id,supplier_id,issued_at,status) values
(1,1,'2026-09-08 09:00:00','PARCIAL'),
(2,2,'2026-09-08 10:00:00','RECIBIDA'),
(3,1,'2026-09-09 08:00:00','EMITIDA'),
(6,3,'2026-09-10 14:00:00','PARCIAL');
insert into order_items (order_id,request_item_id,ordered_quantity,unit_price) values
(1,1,10,75000),(1,2,5,36000),(2,3,20,22000),(3,4,4,680000),(3,5,4,25000),(4,8,10,24000),(4,9,5,78000);
insert into receipts (order_id,delivery_note,received_at,notes) values
(1,'REM-001','2026-09-11 09:00:00','Primera entrega de teclados'),
(1,'REM-002','2026-09-13 09:00:00','Segunda entrega de teclados'),
(2,'REM-003','2026-09-12 11:00:00','Papelería completa'),
(4,'REM-004','2026-09-16 14:00:00','Entrega inicial de cables');
insert into receipt_items (receipt_id,order_item_id,received_quantity) values
(1,1,6),(2,1,4),(3,3,20),(4,6,4);


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE suppliers SET status = 'ACTIVO' WHERE id = 4;
-- 02. UPDATE products SET active = TRUE WHERE id = 7;
-- 03. UPDATE requests SET status = 'APROBADA' WHERE id = 4;
-- 04. UPDATE order_items SET unit_price = 76500 WHERE id = 1;
-- 05. UPDATE requests SET status = 'EN_REVISION' WHERE id = 7;
-- 06. DELETE FROM receipt_items WHERE id = 4;
-- 07. DELETE FROM receipts WHERE id = 4;
-- 08. DELETE FROM request_items WHERE id = 10;
-- 09. DELETE FROM requests WHERE id = 7;
-- 10. TRUNCATE TABLE receipt_items;
