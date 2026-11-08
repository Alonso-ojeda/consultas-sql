-- Preparación del escenario: 04_TalentTrack
-- Este script define las relaciones y carga registros de demostración.
-- Precaución: recrea la base; no usar sobre datos que deban conservarse.

drop database if exists talenttrack;
create database talenttrack character set utf8mb4;

show databases;
use talenttrack;

create table companies (
    id BIGINT auto_increment primary key,
    nit VARCHAR(25) not null unique,
    company_name VARCHAR(180) not null,
    status VARCHAR(15) not null default 'ACTIVA',
    constraint chk_companies_1 check (status in ('ACTIVA','INACTIVA'))
) engine=InnoDB;

create table instructors (
    id BIGINT auto_increment primary key,
    name VARCHAR(150) not null,
    email VARCHAR(255) not null unique
) engine=InnoDB;

create table courses (
    id BIGINT auto_increment primary key,
    code VARCHAR(30) not null unique,
    name VARCHAR(180) not null,
    description TEXT null,
    duration_hours INT not null,
    constraint chk_courses_1 check (duration_hours > 0)
) engine=InnoDB;

create table collaborators (
    id BIGINT auto_increment primary key,
    company_id BIGINT not null,
    name VARCHAR(150) not null,
    email VARCHAR(255) not null,
    status VARCHAR(15) not null default 'ACTIVO',
    constraint uq_collaborators_1 unique (company_id,email),
    constraint chk_collaborators_1 check (status in ('ACTIVO','INACTIVO')),
    foreign key (company_id) references companies(id)
) engine=InnoDB;

create table editions (
    id BIGINT auto_increment primary key,
    course_id BIGINT not null,
    instructor_id BIGINT not null,
    code VARCHAR(40) not null unique,
    start_date DATE not null,
    end_date DATE not null,
    capacity INT not null,
    status VARCHAR(20) not null default 'PROGRAMADA',
    constraint chk_editions_1 check (end_date >= start_date),
    constraint chk_editions_2 check (capacity > 0),
    constraint chk_editions_3 check (status in ('PROGRAMADA','ABIERTA','EN_CURSO','FINALIZADA','CANCELADA')),
    foreign key (course_id) references courses(id),
    foreign key (instructor_id) references instructors(id)
) engine=InnoDB;

create table enrollments (
    id BIGINT auto_increment primary key,
    collaborator_id BIGINT not null,
    edition_id BIGINT not null,
    enrolled_at DATETIME not null default current_timestamp,
    status VARCHAR(20) not null default 'ACTIVA',
    constraint uq_enrollments_1 unique (collaborator_id,edition_id),
    constraint chk_enrollments_1 check (status in ('ACTIVA','FINALIZADA','CANCELADA')),
    foreign key (collaborator_id) references collaborators(id),
    foreign key (edition_id) references editions(id)
) engine=InnoDB;

create table sessions (
    id BIGINT auto_increment primary key,
    edition_id BIGINT not null,
    started_at DATETIME not null,
    ended_at DATETIME not null,
    topic VARCHAR(180) not null,
    constraint chk_sessions_1 check (ended_at > started_at),
    foreign key (edition_id) references editions(id)
) engine=InnoDB;

create table certificates (
    id BIGINT auto_increment primary key,
    enrollment_id BIGINT not null unique,
    code VARCHAR(60) not null unique,
    issued_at DATETIME not null default current_timestamp,
    verification_url VARCHAR(500) not null,
    foreign key (enrollment_id) references enrollments(id)
) engine=InnoDB;

create table attendance (
    id BIGINT auto_increment primary key,
    enrollment_id BIGINT not null,
    session_id BIGINT not null,
    status VARCHAR(10) not null,
    recorded_at DATETIME not null default current_timestamp,
    constraint uq_attendance_1 unique (enrollment_id,session_id),
    constraint chk_attendance_1 check (status in ('PRESENTE','AUSENTE')),
    foreign key (enrollment_id) references enrollments(id),
    foreign key (session_id) references sessions(id)
) engine=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

use talenttrack;
insert into companies (nit,company_name,status) values
('901200001-1','Innovación Delta SAS','ACTIVA'),('901200002-2','Logística Norte SAS','ACTIVA'),('901200003-3','Salud Integral SAS','ACTIVA'),('901200004-4','Comercio Global SAS','INACTIVA');
insert into instructors (name,email) values
('Elena Pardo','elena@academia.test'),('Julián Mora','julian@academia.test'),('Laura Gil','laura@academia.test'),('Pedro Nieto','pedro@academia.test');
insert into courses (code,name,description,duration_hours) values
('CUR-IA','Fundamentos de IA','Uso empresarial de inteligencia artificial',20),('CUR-SQL','SQL para analistas','Consultas y modelado relacional',24),('CUR-SEG','Ciberseguridad','Buenas prácticas de seguridad',16),('CUR-DAT','Análisis de datos','Indicadores y tableros',32);
insert into collaborators (company_id,name,email,status) values
(1,'Ana Torres','ana@delta.test','ACTIVO'),(1,'Luis Pérez','luis@delta.test','ACTIVO'),(2,'Sara Ruiz','sara@norte.test','ACTIVO'),(2,'Mateo Silva','mateo@norte.test','ACTIVO'),(3,'Diana Paz','diana@salud.test','ACTIVO'),(3,'Juan León','juan@salud.test','ACTIVO'),(4,'Laura Cano','laura@comercio.test','INACTIVO');
insert into editions (course_id,instructor_id,code,start_date,end_date,capacity,status) values
(1,1,'IA-2026-A','2026-09-01','2026-09-30',15,'FINALIZADA'),
(1,2,'IA-2026-B','2026-11-01','2026-11-30',20,'ABIERTA'),
(2,2,'SQL-2026-A','2026-09-01','2026-11-15',12,'EN_CURSO'),
(3,3,'SEG-2026-A','2026-10-01','2026-10-30',10,'EN_CURSO'),
(4,4,'DAT-2026-A','2026-12-01','2026-12-30',18,'PROGRAMADA');
insert into enrollments (collaborator_id,edition_id,enrolled_at,status) values
(1,1,'2026-08-20 09:00:00','FINALIZADA'),(2,1,'2026-08-20 10:00:00','FINALIZADA'),
(1,2,'2026-10-01 10:00:00','ACTIVA'),(3,2,'2026-10-05 10:00:00','ACTIVA'),
(3,3,'2026-08-29 10:00:00','ACTIVA'),(4,3,'2026-08-30 10:00:00','ACTIVA'),
(5,4,'2026-09-28 10:00:00','ACTIVA'),(6,4,'2026-09-29 10:00:00','ACTIVA');
insert into sessions (edition_id,started_at,ended_at,topic) values
(1,'2026-09-02 08:00:00','2026-09-02 12:00:00','Introducción'),
(1,'2026-09-04 08:00:00','2026-09-04 12:00:00','Prompting'),
(1,'2026-09-09 08:00:00','2026-09-09 12:00:00','Asistentes'),
(1,'2026-09-11 08:00:00','2026-09-11 12:00:00','Automatización'),
(1,'2026-09-16 08:00:00','2026-09-16 12:00:00','Proyecto'),
(2,'2026-11-04 08:00:00','2026-11-04 12:00:00','Introducción IA'),
(2,'2026-11-06 08:00:00','2026-11-06 12:00:00','Prompts IA'),
(3,'2026-09-10 14:00:00','2026-09-10 18:00:00','SELECT y WHERE'),
(4,'2026-10-10 08:00:00','2026-10-10 12:00:00','Seguridad básica'),
(5,'2026-12-02 08:00:00','2026-12-02 12:00:00','Indicadores');
insert into attendance (enrollment_id,session_id,status,recorded_at) values
(1,1,'PRESENTE','2026-09-02 12:10:00'),(1,2,'PRESENTE','2026-09-04 12:10:00'),
(1,3,'PRESENTE','2026-09-09 12:10:00'),(1,4,'PRESENTE','2026-09-11 12:10:00'),
(1,5,'AUSENTE','2026-09-16 12:10:00'),
(2,1,'PRESENTE','2026-09-02 12:11:00'),(2,2,'PRESENTE','2026-09-04 12:11:00'),
(2,3,'PRESENTE','2026-09-09 12:11:00'),(2,4,'PRESENTE','2026-09-11 12:11:00'),
(2,5,'PRESENTE','2026-09-16 12:11:00');
insert into certificates (enrollment_id,code,issued_at,verification_url) values
(1,'CERT-IA-A-001','2026-09-30 09:00:00','https://ejemplo.test/cert/CERT-IA-A-001'),
(2,'CERT-IA-A-002','2026-09-30 09:05:00','https://ejemplo.test/cert/CERT-IA-A-002');


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE collaborators SET status = 'INACTIVO' WHERE id = 6;
-- 02. UPDATE editions SET capacity = 25 WHERE id = 2;
-- 03. UPDATE enrollments SET status = 'CANCELADA' WHERE id = 8;
-- 04. UPDATE courses SET duration_hours = 28 WHERE id = 2;
-- 05. DELETE FROM certificates WHERE id = 2;
-- 06. DELETE FROM attendance WHERE id = 10;
-- 07. DELETE FROM enrollments WHERE id = 8;
-- 08. DELETE FROM sessions WHERE id = 10;
-- 09. TRUNCATE TABLE certificates;
-- 10. TRUNCATE TABLE attendance;
