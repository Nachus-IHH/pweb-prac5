-- ---------------------------------------------------------------
-- ProSoft
-- PRACTICA DE BASES DE DATOS
-- AUTOR: Ignacio Hernandez Hernandez
-- FECHA: 10/09/2026
-- ---------------------------------------------------------------

-- 1.- DESARROLLO INDIVIDUAL
-- 2.- CREAR LA BD_PROSOFT EN MYSQL
-- 3.- VERIFICAR EL SCRIPT PARA QUE SE PUEDA GENERAR LA BD
-- 4.- INSERTAR 5 REGISTROS SOLO EN LAS TABLAS TIPO CATALOGO: 
--     CLIENTE, MODELO, FAMILIA, ARTICULO
--     LOS ARTICULOS, FAMILIAS Y MODELOS DEBERAN SER SOBRE HARDWARE, SOFTWARE, 
--     SERVICIOS EN CLOUDCOMPUTING, ETC.
-- 5.- AGREGAR EN ESTE SCRIPT EL CODIGO DE CREACION DE TABLAS E INSERCIONES
--     DEL ARCHIVO Script Usuario - Rol [PROSOFT].sql
--     --> VERIFICAR QUE LA NOMENCLATURA SEA CORRECTA Y EXACTA EN MYSQL
--     --> EN LA BD, EN TODAS LAS TABLAS Y EN TODOS LOS ATRIBUTOS
-- ----------------------------------------------------------------
-- 6.- CARGAR EL SCRIPT FINAL EN MOODLE
--     --> LIMITE DE ENTREGA: JUEVES 10 DE SEPTIEMBRE (11:59 PM)
-- ----------------------------------------------------------------

-- DROP DATABASE BD_PROSOFT
-- CREACION DE UNA BASE DE DATOS
CREATE DATABASE bd_prosoft;
-- ACTIVACIÓN DE LA BASE DE DATOS
USE bd_prosoft;
-- =========================================================================
-- CONFIGURACIÓN INICIAL DE REEJECUCIÓN
-- =========================================================================
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS FACTURA;
DROP TABLE IF EXISTS MODO_PAGO;
DROP TABLE IF EXISTS ALBARAN;
DROP TABLE IF EXISTS LINEA_DETALLE_PEDIDO;
DROP TABLE IF EXISTS PEDIDO;
DROP TABLE IF EXISTS ARTICULO;
DROP TABLE IF EXISTS FAMILIA;
DROP TABLE IF EXISTS MODELO;
DROP TABLE IF EXISTS CLIENTE;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS rol;

DROP VIEW IF EXISTS vwRptArticulos;
DROP PROCEDURE IF EXISTS sp_Acceso;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================================
-- 1. CREACIÓN DE TABLAS
-- =========================================================================

CREATE TABLE CLIENTE (
    CLI_CVE_CLIENTE      INT AUTO_INCREMENT PRIMARY KEY,
    CLI_NOMBRE           VARCHAR(50)  NOT NULL, 
    CLI_APELLIDO_PATERNO VARCHAR(50)  NOT NULL, 
    CLI_APELLIDO_MATERNO VARCHAR(50)  NOT NULL, 
    CLI_EMAIL            VARCHAR(50)  NOT NULL, 
    CLI_FAX              VARCHAR(25), 
    CLI_ESTATUS          CHAR(1)      NOT NULL,     
    CLI_FECHA_REGISTRO   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE MODELO (
    MOD_CVE_MODELO  INT AUTO_INCREMENT PRIMARY KEY,
    MOD_NOMBRE      VARCHAR(50)  NOT NULL,
    MOD_DESCRIPCION VARCHAR(250) NOT NULL,
    MOD_ESTATUS     VARCHAR(20)  NOT NULL,   
    MOD_FECHA_REG   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE FAMILIA (
    FAM_CVE_FAMILIA INT AUTO_INCREMENT PRIMARY KEY,
    FAM_NOMBRE      VARCHAR(20)  NOT NULL,
    FAM_DESCRIPCION VARCHAR(60)  NOT NULL,
    FAM_ESTATUS     VARCHAR(20)  NOT NULL,
    FAM_FECHA_REG   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ARTICULO (
    ART_CVE_ARTICULO INT AUTO_INCREMENT PRIMARY KEY,
    ART_NOMBRE       VARCHAR(50)   NOT NULL,
    ART_DESCRIPCION  VARCHAR(250)  NOT NULL,
    ART_ESTATUS      VARCHAR(20)   NOT NULL,
    ART_EXISTENCIAS  INT           NOT NULL,
    ART_PRECIO       DECIMAL(9,2)  NOT NULL,
    ART_FOTO         VARCHAR(255)  NOT NULL,  
    ART_FECHA_REG    DATETIME      NOT NULL,
    MOD_CVE_MODELO   INT           NOT NULL,
    FAM_CVE_FAMILIA  INT           NOT NULL,
    CONSTRAINT fk_articulo_modelo  FOREIGN KEY (MOD_CVE_MODELO)  REFERENCES MODELO(MOD_CVE_MODELO),
    CONSTRAINT fk_articulo_familia FOREIGN KEY (FAM_CVE_FAMILIA) REFERENCES FAMILIA(FAM_CVE_FAMILIA)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE PEDIDO (
    PED_CVE_PEDIDO  INT AUTO_INCREMENT PRIMARY KEY,    
    PED_SUBTOTAL    DECIMAL(9,2) NOT NULL,   
    PED_IVA         DECIMAL(9,2) NOT NULL,
    PED_TOTAL       DECIMAL(9,2) NOT NULL,
    PED_ESTATUS     VARCHAR(20)  NOT NULL,     
    PED_FECHA       DATETIME     NOT NULL,
    CLI_CVE_CLIENTE INT          NOT NULL, 
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (CLI_CVE_CLIENTE) REFERENCES CLIENTE(CLI_CVE_CLIENTE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE LINEA_DETALLE_PEDIDO (
    DET_CVE_LINEA    INT AUTO_INCREMENT PRIMARY KEY, 
    DET_CANTIDAD     INT          NOT NULL,
    DET_PRECIO       DECIMAL(9,2) NOT NULL, 
    PED_CVE_PEDIDO   INT          NOT NULL,
    ART_CVE_ARTICULO INT          NOT NULL,
    CONSTRAINT fk_detalle_pedido   FOREIGN KEY (PED_CVE_PEDIDO)   REFERENCES PEDIDO(PED_CVE_PEDIDO),
    CONSTRAINT fk_detalle_articulo FOREIGN KEY (ART_CVE_ARTICULO) REFERENCES ARTICULO(ART_CVE_ARTICULO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ALBARAN (
    ALB_CVE_ALBARAN   INT AUTO_INCREMENT PRIMARY KEY,
    ALB_CALLE         VARCHAR(40) NOT NULL,
    ALB_NUMERO        VARCHAR(15) NOT NULL,
    ALB_COLONIA       VARCHAR(40) NOT NULL,
    ALB_CODIGO_POSTAL VARCHAR(5)  NOT NULL,
    ALB_CIUDAD        VARCHAR(40) NOT NULL,
    ALB_RECEPTOR      VARCHAR(40) NOT NULL,
    ALB_FECHA_ENTREGA DATETIME    NOT NULL,
    DET_CVE_LINEA     INT         NOT NULL,
    CONSTRAINT fk_albaran_detalle FOREIGN KEY (DET_CVE_LINEA) REFERENCES LINEA_DETALLE_PEDIDO(DET_CVE_LINEA)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE MODO_PAGO (
    MOD_CVE_MODO    INT AUTO_INCREMENT PRIMARY KEY,
    MOD_TIPO_PAGO   VARCHAR(50)  NOT NULL,
    MOD_DESCRIPCION VARCHAR(150) NOT NULL,
    MOD_ESTATUS     VARCHAR(20)  NOT NULL,
    MOD_FECHA_REG   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE FACTURA (
    FAC_CVE_FACTURA      INT AUTO_INCREMENT PRIMARY KEY,
    FAC_FOLIO_SAT        VARCHAR(10) NOT NULL,
    FAC_FECHA_GENERACION DATETIME    NOT NULL,
    ALB_CVE_ALBARAN      INT         NOT NULL,
    MOD_CVE_MODO         INT         NOT NULL,
    CONSTRAINT fk_factura_albaran  FOREIGN KEY (ALB_CVE_ALBARAN) REFERENCES ALBARAN(ALB_CVE_ALBARAN),
    CONSTRAINT fk_factura_modopago FOREIGN KEY (MOD_CVE_MODO)    REFERENCES MODO_PAGO(MOD_CVE_MODO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE rol (
    rol_cve_rol     INT AUTO_INCREMENT PRIMARY KEY,
    rol_nombre      VARCHAR(30)  NOT NULL,
    rol_descripcion VARCHAR(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE usuario (
    usu_cve_usuario      INT AUTO_INCREMENT PRIMARY KEY, 
    usu_nombre           VARCHAR(30) NOT NULL,
    usu_apellido_paterno VARCHAR(30) NOT NULL,
    usu_apellido_materno VARCHAR(30) NOT NULL,
    usu_telefono         VARCHAR(15),
    usu_correo           VARCHAR(50),
    usu_fecha_registro   DATETIME    NOT NULL,
    usu_usuario          VARCHAR(15) NOT NULL,
    usu_password         VARCHAR(15) NOT NULL,
    rol_cve_rol          INT         NOT NULL,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (rol_cve_rol) REFERENCES rol(rol_cve_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================================================
-- 2. INSERCIÓN DE DATOS INICIALES
-- =========================================================================

INSERT INTO CLIENTE (CLI_NOMBRE, CLI_APELLIDO_PATERNO, CLI_APELLIDO_MATERNO, CLI_EMAIL, CLI_FAX, CLI_ESTATUS, CLI_FECHA_REGISTRO) VALUES
('Carlos', 'Mendoza', 'García', 'carlos.mendoza@email.com', '555-0192', 'A', NOW()),
('Ana', 'Hernández', 'López', 'ana.hernandez@email.com', NULL, 'A', NOW()),
('Roberto', 'Gómez', 'Martínez', 'roberto.gomez@email.com', '555-0144', 'A', NOW()),
('Laura', 'Torres', 'Ramírez', 'laura.torres@email.com', NULL, 'I', NOW()),
('Miguel', 'Ángel', 'Vásquez', 'miguel.vasquez@email.com', '555-0188', 'A', NOW());

INSERT INTO MODELO (MOD_NOMBRE, MOD_DESCRIPCION, MOD_ESTATUS, MOD_FECHA_REG) VALUES
('PowerEdge R750', 'Servidor de rack empresarial de alto rendimiento para bases de datos', 'ACTIVO', NOW()),
('ThinkPad X1 Carbon', 'Laptop ultraligera orientada a desarrollo e infraestructura', 'ACTIVO', NOW()),
('Cloud EC2 Standard', 'Instancia virtual orientada a cómputo general en la nube', 'ACTIVO', NOW()),
('Catalyst 9300', 'Switch administrable de capa 3 para redes corporativas', 'ACTIVO', NOW()),
('Enterprise DB v15', 'Licencia de motor de base de datos relacional para alto tráfico', 'ACTIVO', NOW());

INSERT INTO FAMILIA (FAM_NOMBRE, FAM_DESCRIPCION, FAM_ESTATUS, FAM_FECHA_REG) VALUES
('Hardware', 'Servidores, componentes y equipos físicos', 'ACTIVO', NOW()),
('Software', 'Sistemas operativos, licencias y suites', 'ACTIVO', NOW()),
('Cloud Computing', 'Servicios de infraestructura y cómputo en la nube', 'ACTIVO', NOW()),
('Redes y Connect', 'Equipos de conectividad, switches y routers', 'ACTIVO', NOW()),
('Ciberseguridad', 'Soluciones de protección, firewalls y licencias de software', 'ACTIVO', NOW());

INSERT INTO ARTICULO (ART_NOMBRE, ART_DESCRIPCION, ART_ESTATUS, ART_EXISTENCIAS, ART_PRECIO, ART_FOTO, ART_FECHA_REG, MOD_CVE_MODELO, FAM_CVE_FAMILIA) VALUES
('Servidor Dell PowerEdge R750', 'Servidor de 2U con procesador Intel Xeon Dual, 64GB RAM y 2TB SSD', 'DISPONIBLE', 10, 45000.00, '/images/articulos/dell_r750.jpg', NOW(), 1, 1),
('Laptop Lenovo ThinkPad X1', 'Ultrabook procesador i7, 32GB RAM, 1TB NVMe, pantalla 14 pulgadas', 'DISPONIBLE', 25, 32500.50, '/images/articulos/thinkpad_x1.jpg', NOW(), 2, 1),
('Instancia Cloud EC2 - Compute', 'Suscrpción mensual a servidor virtual 8 vCPU, 32GB RAM', 'DISPONIBLE', 999, 1200.00, '/images/articulos/aws_ec2.jpg', NOW(), 3, 3),
('Switch Cisco Catalyst 48p', 'Switch administrable de 48 puertos Gigabit PoE+ para rack', 'DISPONIBLE', 15, 18900.00, '/images/articulos/cisco_cat9300.jpg', NOW(), 4, 4),
('Licencia BD Enterprise 1Y', 'Suscripción anual para motor de base de datos con soporte 24/7', 'DISPONIBLE', 100, 8500.00, '/images/articulos/db_enterprise.jpg', NOW(), 5, 2);

INSERT INTO rol (rol_nombre, rol_descripcion) VALUES 
('ADMINISTRADOR', 'Administrador General de la Empresa'),
('VENTAS', 'Gerente de Ventas'),
('COMPRAS', 'Gerente de Compras'),
('CLIENTE', 'Cliente general, sin distincion inicial');

INSERT INTO usuario (usu_nombre, usu_apellido_paterno, usu_apellido_materno, usu_telefono, usu_correo, usu_fecha_registro, usu_usuario, usu_password, rol_cve_rol) VALUES 
('Pedro', 'Perez', 'Roig', '771-234-234', 'pperez@gmail.com', NOW(), 'pperez', 'itp2026', 1),
('Luis', 'Ruiz', 'Lopez', '771-876-321', 'lruiz@gmail.com', NOW(), 'lruiz', 'itp2026', 2),
('Ana', 'Bell', 'Ring', '771-123-987', 'bbell@gmail.com', NOW(), 'bbell', 'itp2026', 4);

-- =========================================================================
-- 3. ACTUALIZACIÓN DE DATOS
-- =========================================================================

UPDATE ARTICULO 
SET ART_FOTO = CONCAT('imagenes/articulos/', ART_CVE_ARTICULO, '.jpg');

-- =========================================================================
-- 4. VISTAS
-- =========================================================================

CREATE VIEW vwRptArticulos AS
SELECT  
    a.ART_CVE_ARTICULO AS clave, 
    a.ART_DESCRIPCION AS descripcion, 
    a.ART_NOMBRE AS nombre, 
    a.ART_PRECIO AS precio,   
    a.ART_EXISTENCIAS AS existencias, 
    a.ART_FOTO AS foto,
    CONCAT(m.MOD_NOMBRE, ' (', m.MOD_DESCRIPCION, ')') AS modelo,  
    f.FAM_NOMBRE AS familia 
FROM ARTICULO a
INNER JOIN MODELO m ON a.MOD_CVE_MODELO = m.MOD_CVE_MODELO
INNER JOIN FAMILIA f ON a.FAM_CVE_FAMILIA = f.FAM_CVE_FAMILIA
WHERE a.ART_ESTATUS = 'DISPONIBLE' 
  AND a.ART_EXISTENCIAS > 0 
ORDER BY a.ART_CVE_ARTICULO;

-- =========================================================================
-- 5. PROCEDIMIENTOS ALMACENADOS
-- =========================================================================

DELIMITER $$
CREATE PROCEDURE sp_Acceso
(
    IN p_usuario VARCHAR(15),
    IN p_password VARCHAR(15)
)
BEGIN
    IF EXISTS(
        SELECT 1
        FROM usuario u
        INNER JOIN rol r ON u.rol_cve_rol = r.rol_cve_rol
        WHERE u.usu_usuario = p_usuario
          AND u.usu_password = p_password
    ) THEN
        SELECT 
            '1' AS usu_ban, 
            u.usu_cve_usuario,
            CONCAT(u.usu_nombre, ' ', u.usu_apellido_paterno, ' ', u.usu_apellido_materno) AS usu_nombre, 
            u.usu_usuario, 
            r.rol_nombre
        FROM usuario u
        INNER JOIN rol r ON u.rol_cve_rol = r.rol_cve_rol
        WHERE u.usu_usuario = p_usuario
          AND u.usu_password = p_password;
    ELSE
        SELECT '0' AS usu_ban;
    END IF;
END $$
DELIMITER ;

-- =========================================================================
-- 6. PRUEBAS DE VERIFICACIÓN
-- =========================================================================

CALL sp_Acceso('pperez', 'itp2026');
CALL sp_Acceso('hola', '12345');
SELECT * FROM vwRptArticulos;
