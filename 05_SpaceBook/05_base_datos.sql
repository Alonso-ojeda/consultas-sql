-- Preparación del escenario: 05_SpaceBook
-- Este script define las relaciones y carga registros de demostración.
-- Precaución: recrea la base; no usar sobre datos que deban conservarse.

drop database if exists spacebook;
create database spacebook character set utf8mb4;

show databases;
use spacebook;

create table sites (
    id BIGINT auto_increment primary key,
    code VARCHAR(20) not null unique,
    name VARCHAR(120) not null,
    city VARCHAR(100) not null
) engine=InnoDB;

create table resources (
    id BIGINT auto_increment primary key,
    code VARCHAR(40) not null unique,
    name VARCHAR(120) not null,
    type VARCHAR(80) not null,
    status VARCHAR(20) not null default 'DISPONIBLE',
    constraint chk_resources_1 check (status in ('DISPONIBLE','MANTENIMIENTO','BAJA'))
) engine=InnoDB;

create table employees (
    id BIGINT auto_increment primary key,
    site_id BIGINT not null,
    code VARCHAR(30) not null unique,
    name VARCHAR(150) not null,
    email VARCHAR(255) not null unique,
    foreign key (site_id) references sites(id)
) engine=InnoDB;

create table rooms (
    id BIGINT auto_increment primary key,
    site_id BIGINT not null,
    code VARCHAR(30) not null,
    name VARCHAR(120) not null,
    capacity INT not null,
    status VARCHAR(15) not null default 'ACTIVA',
    constraint uq_rooms_1 unique (site_id,code),
    constraint chk_rooms_1 check (capacity > 0),
    constraint chk_rooms_2 check (status in ('ACTIVA','INACTIVA')),
    foreign key (site_id) references sites(id)
) engine=InnoDB;

create table reservations (
    id BIGINT auto_increment primary key,
    room_id BIGINT not null,
    organizer_id BIGINT not null,
    started_at DATETIME not null,
    ended_at DATETIME not null,
    reason VARCHAR(255) not null,
    status VARCHAR(15) not null default 'SOLICITADA',
    constraint chk_reservations_1 check (ended_at > started_at),
    constraint chk_reservations_2 check (status in ('SOLICITADA','CONFIRMADA','CANCELADA','FINALIZADA')),
    foreign key (room_id) references rooms(id),
    foreign key (organizer_id) references employees(id)
) engine=InnoDB;

create table room_blocks (
    id BIGINT auto_increment primary key,
    room_id BIGINT not null,
    started_at DATETIME not null,
    ended_at DATETIME not null,
    reason VARCHAR(180) not null,
    constraint chk_room_blocks_1 check (ended_at > started_at),
    foreign key (room_id) references rooms(id)
) engine=InnoDB;

create table reservation_participants (
    reservation_id BIGINT not null,
    employee_id BIGINT not null,
    response VARCHAR(15) not null default 'PENDIENTE',
    primary key (reservation_id,employee_id),
    constraint chk_reservation_participants_1 check (response in ('PENDIENTE','ACEPTADA','RECHAZADA')),
    foreign key (reservation_id) references reservations(id),
    foreign key (employee_id) references employees(id)
) engine=InnoDB;

create table reservation_resources (
    reservation_id BIGINT not null,
    resource_id BIGINT not null,
    primary key (reservation_id,resource_id),
    foreign key (reservation_id) references reservations(id),
    foreign key (resource_id) references resources(id)
) engine=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

use spacebook;
insert into sites (code,name,city) values
('BGA','Sede Centro','Bucaramanga'),('FLB','Sede Sur','Floridablanca'),('BOG','Sede Capital','Bogotá'),('MED','Sede Antioquia','Medellín');
insert into resources (code,name,type,status) values
('REC-001','Proyector Epson','PROYECTOR','DISPONIBLE'),('REC-002','Cámara Logitech','CAMARA','DISPONIBLE'),('REC-003','Micrófono Jabra','AUDIO','DISPONIBLE'),('REC-004','Pantalla portátil','PANTALLA','DISPONIBLE'),('REC-005','Proyector BenQ','PROYECTOR','MANTENIMIENTO'),('REC-006','Kit de audio','AUDIO','DISPONIBLE');
insert into employees (site_id,code,name,email) values
(1,'E-001','Ana Torres','ana@space.test'),(1,'E-002','Luis Rojas','luis@space.test'),(2,'E-003','Sara Gil','sara@space.test'),(2,'E-004','Mateo Vega','mateo@space.test'),(3,'E-005','Diana Pérez','diana@space.test'),(3,'E-006','Carlos Ruiz','carlos@space.test'),(4,'E-007','Laura Mora','laura@space.test');
insert into rooms (site_id,code,name,capacity,status) values
(1,'S1','Sala Horizonte',6,'ACTIVA'),(1,'S2','Sala Ágora',12,'ACTIVA'),(2,'S1','Sala Sur',8,'ACTIVA'),(2,'S2','Sala Verde',4,'ACTIVA'),(3,'S1','Sala Capital',10,'ACTIVA'),(4,'S1','Sala Antioquia',8,'INACTIVA');
insert into reservations (room_id,organizer_id,started_at,ended_at,reason,status) values
(1,1,'2026-11-03 08:00:00','2026-11-03 09:00:00','Planeación semanal','CONFIRMADA'),
(1,2,'2026-11-03 09:00:00','2026-11-03 10:00:00','Revisión de entregas','CONFIRMADA'),
(2,1,'2026-11-03 08:00:00','2026-11-03 10:00:00','Comité directivo','CONFIRMADA'),
(3,3,'2026-11-04 14:00:00','2026-11-04 15:00:00','Capacitación interna','CONFIRMADA'),
(4,4,'2026-11-05 10:00:00','2026-11-05 11:00:00','Revisión comercial','CANCELADA'),
(5,5,'2026-11-06 08:00:00','2026-11-06 09:00:00','Presupuesto','SOLICITADA'),
(1,1,'2026-11-07 11:00:00','2026-11-07 12:00:00','Cierre de sprint','SOLICITADA'),
(3,6,'2026-10-08 15:00:00','2026-10-08 16:00:00','Retroalimentación','FINALIZADA');
insert into room_blocks (room_id,started_at,ended_at,reason) values
(1,'2026-11-03 10:00:00','2026-11-03 12:00:00','Limpieza'),
(2,'2026-11-04 08:00:00','2026-11-04 12:00:00','Mantenimiento audiovisual'),
(3,'2026-11-05 12:00:00','2026-11-05 14:00:00','Acondicionamiento'),
(5,'2026-11-09 08:00:00','2026-11-09 11:00:00','Limpieza');
insert into reservation_participants (reservation_id,employee_id,response) values
(1,2,'ACEPTADA'),(1,3,'ACEPTADA'),(1,4,'PENDIENTE'),
(2,1,'ACEPTADA'),(2,5,'RECHAZADA'),(3,2,'ACEPTADA'),
(3,5,'PENDIENTE'),(4,4,'ACEPTADA'),(5,3,'ACEPTADA'),(6,6,'PENDIENTE');
insert into reservation_resources (reservation_id,resource_id) values
(1,1),(1,3),(2,1),(3,2),(3,4),(4,6),(5,3),(6,2);


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE employees SET name = 'Ana María Torres' WHERE id = 1;
-- 02. UPDATE resources SET status = 'DISPONIBLE' WHERE id = 5;
-- 03. UPDATE reservations SET status = 'CANCELADA' WHERE id = 7;
-- 04. UPDATE reservation_participants SET response = 'ACEPTADA' WHERE reservation_id = 1 AND employee_id = 4;
-- 05. DELETE FROM reservation_resources WHERE reservation_id = 6 AND resource_id = 2;
-- 06. DELETE FROM reservation_participants WHERE reservation_id = 6 AND employee_id = 6;
-- 07. DELETE FROM room_blocks WHERE id = 4;
-- 08. DELETE FROM reservations WHERE id = 7;
-- 09. TRUNCATE TABLE reservation_participants;
-- 10. TRUNCATE TABLE reservation_resources;
