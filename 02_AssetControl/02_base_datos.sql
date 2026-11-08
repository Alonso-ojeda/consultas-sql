-- Preparación del escenario: 02_AssetControl
-- Este script define las relaciones y carga registros de demostración.
-- Precaución: recrea la base; no usar sobre datos que deban conservarse.

drop database if exists assetcontrol;
create database assetcontrol character set utf8mb4;

show databases;
use assetcontrol;

create table sites (
    id BIGINT auto_increment primary key,
    code VARCHAR(20) not null unique,
    name VARCHAR(120) not null,
    city VARCHAR(100) not null
) engine=InnoDB;

create table asset_types (
    id BIGINT auto_increment primary key,
    name VARCHAR(80) not null unique,
    description VARCHAR(255) null
) engine=InnoDB;

create table departments (
    id BIGINT auto_increment primary key,
    site_id BIGINT not null,
    name VARCHAR(120) not null,
    constraint uq_departments_1 unique (site_id,name),
    foreign key (site_id) references sites(id)
) engine=InnoDB;

create table assets (
    id BIGINT auto_increment primary key,
    site_id BIGINT not null,
    asset_type_id BIGINT not null,
    patrimonial_identifier VARCHAR(40) not null unique,
    serial_number VARCHAR(100) not null unique,
    brand VARCHAR(100) not null,
    model VARCHAR(100) not null,
    purchase_date DATE not null,
    status VARCHAR(20) not null default 'DISPONIBLE',
    constraint chk_assets_1 check (status in ('DISPONIBLE','ASIGNADO','MANTENIMIENTO','BAJA')),
    foreign key (site_id) references sites(id),
    foreign key (asset_type_id) references asset_types(id)
) engine=InnoDB;

create table employees (
    id BIGINT auto_increment primary key,
    department_id BIGINT not null,
    employee_code VARCHAR(30) not null unique,
    name VARCHAR(150) not null,
    email VARCHAR(255) not null unique,
    status VARCHAR(15) not null default 'ACTIVO',
    constraint chk_employees_1 check (status in ('ACTIVO','INACTIVO')),
    foreign key (department_id) references departments(id)
) engine=InnoDB;

create table assignments (
    id BIGINT auto_increment primary key,
    asset_id BIGINT not null,
    employee_id BIGINT not null,
    started_at DATETIME not null,
    return_date DATETIME null,
    delivery_status VARCHAR(20) not null default 'BUENO',
    active_asset_id BIGINT GENERATED ALWAYS as (if(return_date is null,asset_id,null)) STORED,
    constraint uq_assignments_1 unique (active_asset_id),
    constraint chk_assignments_1 check (return_date is null or return_date > started_at),
    constraint chk_assignments_2 check (delivery_status in ('BUENO','REGULAR','DANADO')),
    foreign key (asset_id) references assets(id),
    foreign key (employee_id) references employees(id)
) engine=InnoDB;

create table maintenance (
    id BIGINT auto_increment primary key,
    asset_id BIGINT not null,
    type VARCHAR(15) not null,
    started_at DATETIME not null,
    ended_at DATETIME null,
    description TEXT not null,
    cost DECIMAL(12,2) not null default 0,
    result VARCHAR(255) null,
    constraint chk_maintenance_1 check (type in ('PREVENTIVO','CORRECTIVO')),
    constraint chk_maintenance_2 check (ended_at is null or ended_at > started_at),
    constraint chk_maintenance_3 check (cost >= 0),
    foreign key (asset_id) references assets(id)
) engine=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

use assetcontrol;
insert into sites (code,name,city) values
('BGA','Sede Centro','Bucaramanga'),('FLB','Sede Floridablanca','Floridablanca'),('BOG','Sede Bogotá','Bogotá'),('MED','Sede Medellín','Medellín');
insert into asset_types (name,description) values
('Portátil','Equipo de cómputo móvil'),('Monitor','Pantalla externa'),('Impresora','Equipo de impresión'),('Teléfono','Teléfono corporativo'),('Proyector','Equipo audiovisual');
insert into departments (site_id,name) values
(1,'Tecnología'),(1,'Contabilidad'),(2,'Comercial'),(2,'Operaciones'),(3,'Recursos Humanos'),(4,'Tecnología');
insert into assets (site_id,asset_type_id,patrimonial_identifier,serial_number,brand,model,purchase_date,status) values
(1,1,'ACT-001','SER-L001','Lenovo','ThinkPad E14','2025-02-10','ASIGNADO'),
(1,2,'ACT-002','SER-M002','Dell','P2422','2025-03-01','ASIGNADO'),
(2,1,'ACT-003','SER-L003','HP','ProBook 440','2024-08-20','DISPONIBLE'),
(2,3,'ACT-004','SER-I004','Epson','L4260','2025-07-11','MANTENIMIENTO'),
(3,1,'ACT-005','SER-L005','Acer','TravelMate','2024-11-20','ASIGNADO'),
(1,4,'ACT-006','SER-T006','Samsung','A35','2026-01-15','DISPONIBLE'),
(4,2,'ACT-007','SER-M007','LG','24MP400','2025-09-14','ASIGNADO'),
(2,5,'ACT-008','SER-P008','Epson','PowerLite','2025-05-05','DISPONIBLE'),
(3,2,'ACT-009','SER-M009','Dell','P2419H','2023-04-05','BAJA');
insert into employees (department_id,employee_code,name,email,status) values
(1,'EMP-001','Ana Torres','ana@empresa.test','ACTIVO'),(1,'EMP-002','Luis Gómez','luis@empresa.test','ACTIVO'),
(2,'EMP-003','María Peña','maria@empresa.test','ACTIVO'),(3,'EMP-004','Carlos Díaz','carlos@empresa.test','ACTIVO'),
(4,'EMP-005','Sofía Rojas','sofia@empresa.test','ACTIVO'),(5,'EMP-006','Jorge León','jorge@empresa.test','ACTIVO'),
(6,'EMP-007','Diana Luna','diana@empresa.test','INACTIVO');
insert into assignments (asset_id,employee_id,started_at,return_date,delivery_status) values
(1,1,'2026-08-01 09:00:00',null,'BUENO'),
(2,2,'2026-06-01 09:00:00','2026-08-01 18:00:00','BUENO'),
(2,1,'2026-08-02 09:00:00',null,'REGULAR'),
(3,4,'2026-04-01 09:00:00','2026-05-20 17:00:00','BUENO'),
(5,6,'2026-09-01 10:00:00',null,'BUENO'),
(7,7,'2026-01-01 09:00:00','2026-02-01 18:00:00','REGULAR'),
(7,2,'2026-09-10 09:00:00',null,'BUENO'),
(8,5,'2026-07-01 09:00:00','2026-07-15 17:00:00','BUENO');
insert into maintenance (asset_id,type,started_at,ended_at,description,cost,result) values
(1,'PREVENTIVO','2026-01-10 08:00:00','2026-01-10 11:00:00','Limpieza preventiva',85000,'Completado'),
(2,'CORRECTIVO','2026-05-10 09:00:00','2026-05-11 15:00:00','Cambio de cable',125000,'Resuelto'),
(3,'PREVENTIVO','2026-06-01 09:00:00','2026-06-01 12:00:00','Actualización de sistema',60000,'Completado'),
(4,'CORRECTIVO','2026-10-05 10:00:00',null,'Falla de impresión',210000,null),
(5,'PREVENTIVO','2026-02-05 08:00:00','2026-02-05 10:00:00','Diagnóstico general',70000,'Completado'),
(5,'CORRECTIVO','2026-09-20 09:00:00','2026-09-21 12:00:00','Reemplazo de memoria',220000,'Resuelto'),
(8,'PREVENTIVO','2026-08-15 08:00:00','2026-08-15 11:00:00','Limpieza de lente',95000,'Completado'),
(9,'CORRECTIVO','2026-04-01 09:00:00','2026-04-03 14:00:00','Falla de panel',550000,'Sin reparación');


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE assets SET status = 'MANTENIMIENTO' WHERE id = 3;
-- 02. UPDATE employees SET status = 'INACTIVO' WHERE id = 6;
-- 03. UPDATE maintenance SET cost = 230000 WHERE id = 6;
-- 04. UPDATE assignments SET return_date = '2026-10-02 17:00:00' WHERE id = 5;
-- 05. DELETE FROM maintenance WHERE id = 8;
-- 06. DELETE FROM assignments WHERE id = 8;
-- 07. DELETE FROM maintenance WHERE id = 7;
-- 08. DELETE FROM employees WHERE id = 5;
-- 09. TRUNCATE TABLE maintenance;
-- 10. TRUNCATE TABLE assignments;
