-- Preparación del escenario: 01_HelpDesk_Pro
-- Este script define las relaciones y carga registros de demostración.
-- Precaución: recrea la base; no usar sobre datos que deban conservarse.

drop database if exists helpdesk_pro;
create database helpdesk_pro character set utf8mb4;

show databases;
use helpdesk_pro;

create table clients (
    id BIGINT auto_increment primary key,
    nit VARCHAR(25) not null unique,
    company_name VARCHAR(180) not null,
    status VARCHAR(15) not null default 'ACTIVO',
    constraint chk_clients_1 check (status in ('ACTIVO','INACTIVO'))
) engine=InnoDB;

create table categories (
    id BIGINT auto_increment primary key,
    name VARCHAR(100) not null unique,
    description VARCHAR(255) null
) engine=InnoDB;

create table technicians (
    id BIGINT auto_increment primary key,
    name VARCHAR(150) not null,
    corporate_email VARCHAR(255) not null unique,
    specialty VARCHAR(100) not null,
    status VARCHAR(15) not null default 'ACTIVO',
    constraint chk_technicians_1 check (status in ('ACTIVO','INACTIVO'))
) engine=InnoDB;

create table contacts (
    id BIGINT auto_increment primary key,
    client_id BIGINT not null,
    name VARCHAR(150) not null,
    email VARCHAR(255) not null,
    status VARCHAR(15) not null default 'ACTIVO',
    constraint uq_contacts_1 unique (client_id, email),
    constraint chk_contacts_1 check (status in ('ACTIVO','INACTIVO')),
    foreign key (client_id) references clients(id)
) engine=InnoDB;

create table tickets (
    id BIGINT auto_increment primary key,
    contact_id BIGINT not null,
    category_id BIGINT not null,
    subject VARCHAR(180) not null,
    description TEXT not null,
    priority VARCHAR(12) not null default 'MEDIA',
    status VARCHAR(20) not null default 'ABIERTO',
    opened_at DATETIME not null default current_timestamp,
    constraint chk_tickets_1 check (priority in ('BAJA','MEDIA','ALTA','CRITICA')),
    constraint chk_tickets_2 check (status in ('ABIERTO','EN_PROCESO','RESUELTO','CERRADO')),
    foreign key (contact_id) references contacts(id),
    foreign key (category_id) references categories(id)
) engine=InnoDB;

create table assignments (
    id BIGINT auto_increment primary key,
    ticket_id BIGINT not null,
    technician_id BIGINT not null,
    started_at DATETIME not null,
    ended_at DATETIME null,
    active_ticket_id BIGINT GENERATED ALWAYS as (if(ended_at is null, ticket_id, null)) STORED,
    constraint uq_assignments_1 unique (active_ticket_id),
    constraint chk_assignments_1 check (ended_at is null or ended_at > started_at),
    foreign key (ticket_id) references tickets(id),
    foreign key (technician_id) references technicians(id)
) engine=InnoDB;

create table status_history (
    id BIGINT auto_increment primary key,
    ticket_id BIGINT not null,
    technician_id BIGINT null,
    previous_status VARCHAR(20) null,
    new_status VARCHAR(20) not null,
    changed_at DATETIME not null default current_timestamp,
    reason VARCHAR(255) not null,
    constraint chk_status_history_1 check (previous_status is null or previous_status in ('ABIERTO','EN_PROCESO','RESUELTO','CERRADO')),
    constraint chk_status_history_2 check (new_status in ('ABIERTO','EN_PROCESO','RESUELTO','CERRADO')),
    constraint chk_status_history_3 check (previous_status is null or previous_status <> new_status),
    foreign key (ticket_id) references tickets(id),
    foreign key (technician_id) references technicians(id)
) engine=InnoDB;

create table comments (
    id BIGINT auto_increment primary key,
    ticket_id BIGINT not null,
    contact_id BIGINT null,
    technician_id BIGINT null,
    content TEXT not null,
    created_at DATETIME not null default current_timestamp,
    constraint chk_comments_1 check (
        (contact_id is not null and technician_id is null) or
        (contact_id is null and technician_id is not null)
    ),
    foreign key (ticket_id) references tickets(id),
    foreign key (contact_id) references contacts(id),
    foreign key (technician_id) references technicians(id)
) engine=InnoDB;

SHOW TABLES;


-- ============================================================
-- DML: INSERT INTO | datos semilla para resolver los 20 retos
-- Nunca ejecutar los ejemplos destructivos antes del DQL.
-- ============================================================

use helpdesk_pro;
insert into clients (nit, company_name, status) values
('900111001-1','Andes Digital SAS','ACTIVO'),('900111002-2','Nova Retail SAS','ACTIVO'),('900111003-3','Clínica Norte SAS','ACTIVO'),('900111004-4','Agrocentro SAS','INACTIVO');
insert into categories (name, description) values
('Acceso','Problemas de inicio de sesión'),('Infraestructura','Servidores y red'),('Facturación','Errores de cobro'),('Aplicación','Funcionalidad de software'),('Seguridad','Reportes de acceso inusual');
insert into technicians (name,corporate_email,specialty,status) values
('Lucía Pérez','lucia@soporte.test','Redes','ACTIVO'),('Mateo Ruiz','mateo@soporte.test','Aplicaciones','ACTIVO'),('Sara Díaz','sara@soporte.test','Seguridad','ACTIVO'),('Juan Vega','juan@soporte.test','Facturación','ACTIVO'),('Elena Paz','elena@soporte.test','Infraestructura','INACTIVO');
insert into contacts (client_id,name,email,status) values
(1,'Ana Rojas','ana@andes.test','ACTIVO'),(1,'Carlos Mora','carlos@andes.test','ACTIVO'),(2,'Diana Gil','diana@nova.test','ACTIVO'),(2,'Pedro León','pedro@nova.test','ACTIVO'),(3,'Lina Serrano','lina@clinica.test','ACTIVO'),(3,'Iván Díaz','ivan@clinica.test','ACTIVO'),(4,'Rosa Pinto','rosa@agro.test','INACTIVO');
insert into tickets (contact_id,category_id,subject,description,priority,status,opened_at) values
(1,1,'No puedo ingresar','La contraseña no se reconoce','ALTA','ABIERTO','2026-09-01 08:00:00'),
(2,2,'Red intermitente','Cortes de red en oficina','CRITICA','EN_PROCESO','2026-09-02 09:00:00'),
(3,3,'Factura duplicada','Cobro repetido de agosto','MEDIA','RESUELTO','2026-09-03 10:30:00'),
(4,4,'Exportación fallida','El módulo de reportes falla','ALTA','CERRADO','2026-09-04 14:20:00'),
(5,5,'Alerta de seguridad','Acceso desde ubicación inusual','CRITICA','EN_PROCESO','2026-09-05 07:15:00'),
(1,4,'Filtro no funciona','Listado devuelve datos incorrectos','BAJA','CERRADO','2026-09-06 12:00:00'),
(6,1,'Cuenta bloqueada','Bloqueo tras varios intentos','MEDIA','ABIERTO','2026-09-07 11:00:00'),
(3,2,'Servidor lento','Tiempos de respuesta elevados','ALTA','RESUELTO','2026-09-08 16:00:00');
insert into assignments (ticket_id,technician_id,started_at,ended_at) values
(1,2,'2026-09-01 09:00:00',null),
(2,1,'2026-09-02 09:30:00','2026-09-02 12:00:00'),
(2,5,'2026-09-02 12:15:00',null),
(3,4,'2026-09-03 11:00:00','2026-09-03 16:00:00'),
(4,2,'2026-09-04 15:00:00','2026-09-05 10:00:00'),
(5,3,'2026-09-05 08:00:00',null),
(6,2,'2026-09-06 13:00:00','2026-09-06 15:00:00'),
(8,1,'2026-09-08 17:00:00','2026-09-09 09:00:00');
insert into status_history (ticket_id,technician_id,previous_status,new_status,changed_at,reason) values
(1,null,null,'ABIERTO','2026-09-01 08:00:00','Registro inicial'),
(2,1,'ABIERTO','EN_PROCESO','2026-09-02 09:30:00','Diagnóstico iniciado'),
(3,4,'EN_PROCESO','RESUELTO','2026-09-03 16:00:00','Ajuste de factura'),
(4,2,'RESUELTO','CERRADO','2026-09-05 10:30:00','Confirmación del cliente'),
(5,3,'ABIERTO','EN_PROCESO','2026-09-05 08:00:00','Auditoría de acceso'),
(6,2,'RESUELTO','CERRADO','2026-09-06 16:00:00','Validación final'),
(7,null,null,'ABIERTO','2026-09-07 11:00:00','Creación automática'),
(8,1,'EN_PROCESO','RESUELTO','2026-09-09 09:00:00','Reinicio de servicios');
insert into comments (ticket_id,contact_id,technician_id,content,created_at) values
(1,1,null,'Solicito apoyo urgente','2026-09-01 08:05:00'),
(1,null,2,'Revisaré el acceso','2026-09-01 09:15:00'),
(2,2,null,'La conexión sigue cayéndose','2026-09-02 10:00:00'),
(2,null,1,'Se detectó una falla de red','2026-09-02 11:00:00'),
(3,null,4,'Se corrigió el documento','2026-09-03 15:30:00'),
(4,4,null,'Ya funciona la exportación','2026-09-05 10:15:00'),
(5,null,3,'Incidente en investigación','2026-09-05 08:30:00'),
(6,1,null,'Gracias por solucionar el filtro','2026-09-06 16:00:00'),
(8,null,1,'Servicio restablecido','2026-09-09 09:10:00');


-- ============================================================
-- PRACTICA ADICIONAL: UPDATE / DELETE / TRUNCATE
-- Los siguientes 10 ejemplos estan DESACTIVADOS (comentados).
-- Descomentar uno a la vez, SOLO en una copia de laboratorio.
-- Ejecutar estos ejemplos puede cambiar resultados de DQL.
-- TRUNCATE es DDL en MySQL, no se revierte con ROLLBACK.
-- ============================================================

-- 01. UPDATE clients SET status = 'ACTIVO' WHERE id = 4;
-- 02. UPDATE tickets SET priority = 'CRITICA' WHERE id = 1;
-- 03. UPDATE technicians SET specialty = 'Soporte de red' WHERE id = 1;
-- 04. UPDATE assignments SET ended_at = '2026-09-03 11:00:00' WHERE id = 3;
-- 05. DELETE FROM comments WHERE id = 9;
-- 06. DELETE FROM status_history WHERE id = 7;
-- 07. DELETE FROM assignments WHERE id = 8;
-- 08. DELETE FROM tickets WHERE id = 7;
-- 09. TRUNCATE TABLE comments;
-- 10. TRUNCATE TABLE status_history;
