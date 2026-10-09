-- ---------------------------------------------------------------
-- ProSoft
-- PRACTICA DE BASES DE DATOS
-- AUTOR: Ignacio Hernandez Hernandez
-- FECHA: 10/09/2026
-- ---------------------------------------------------------------

-- 1.- DESARROLLO INDIVIDUAL
-- 2.- CREAR LA bd_prosoft EN MYSQL
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

-- DROP DATABASE bd_prosoft
-- CREACION DE UNA BASE DE DATOS
CREATE DATABASE bd_prosoft;
-- ACTIVACIÓN DE LA BASE DE DATOS
USE bd_prosoft;
-- =========================================================================
-- CONFIGURACIÓN INICIAL DE REEJECUCIÓN
-- =========================================================================
SET FOREIGN_KEY_CHECKS = 0;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================================
-- 1. CREACIÓN DE TABLAS
-- =========================================================================

CREATE TABLE cliente (
    cli_cve_cliente      INT AUTO_INCREMENT PRIMARY KEY,
    cli_nombre           VARCHAR(50)  NOT NULL, 
    cli_apellido_paterno VARCHAR(50)  NOT NULL, 
    cli_apellido_materno VARCHAR(50)  NOT NULL, 
    cli_email            VARCHAR(50)  NOT NULL, 
    cli_fax              VARCHAR(25), 
    cli_estatus          CHAR(1)      NOT NULL,     
    cli_fecha_registro   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE modelo (
    mod_cve_modelo  INT AUTO_INCREMENT PRIMARY KEY,
    mod_nombre      VARCHAR(50)  NOT NULL,
    mod_descripcion VARCHAR(250) NOT NULL,
    mod_estatus     VARCHAR(20)  NOT NULL,   
    mod_fecha_reg   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE familia (
    fam_cve_familia INT AUTO_INCREMENT PRIMARY KEY,
    fam_nombre      VARCHAR(20)  NOT NULL,
    fam_descripcion VARCHAR(60)  NOT NULL,
    fam_estatus     VARCHAR(20)  NOT NULL,
    fam_fecha_reg   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE articulo (
    art_cve_articulo INT AUTO_INCREMENT PRIMARY KEY,
    art_nombre       VARCHAR(50)   NOT NULL,
    art_descripcion  VARCHAR(250)  NOT NULL,
    art_estatus      VARCHAR(20)   NOT NULL,
    art_existencias  INT           NOT NULL,
    art_precio       DECIMAL(9,2)  NOT NULL,
    art_foto         VARCHAR(255)  NOT NULL,  
    art_fecha_reg    DATETIME      NOT NULL,
    mod_cve_modelo   INT           NOT NULL,
    fam_cve_familia  INT           NOT NULL,
    CONSTRAINT fk_articulo_modelo  FOREIGN KEY (mod_cve_modelo)  REFERENCES modelo(mod_cve_modelo),
    CONSTRAINT fk_articulo_familia FOREIGN KEY (fam_cve_familia) REFERENCES familia(fam_cve_familia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pedido (
    ped_cve_pedido  INT AUTO_INCREMENT PRIMARY KEY,    
    ped_subtotal    DECIMAL(9,2) NOT NULL,   
    ped_iva         DECIMAL(9,2) NOT NULL,
    ped_total       DECIMAL(9,2) NOT NULL,
    ped_estatus     VARCHAR(20)  NOT NULL,     
    ped_fecha       DATETIME     NOT NULL,
    cli_cve_cliente INT          NOT NULL, 
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (cli_cve_cliente) REFERENCES cliente(cli_cve_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE linea_detalle_pedido (
    det_cve_linea    INT AUTO_INCREMENT PRIMARY KEY, 
    det_cantidad     INT          NOT NULL,
    det_precio       DECIMAL(9,2) NOT NULL, 
    ped_cve_pedido   INT          NOT NULL,
    art_cve_articulo INT          NOT NULL,
    CONSTRAINT fk_detalle_pedido   FOREIGN KEY (ped_cve_pedido)   REFERENCES pedido(ped_cve_pedido),
    CONSTRAINT fk_detalle_articulo FOREIGN KEY (art_cve_articulo) REFERENCES articulo(art_cve_articulo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE albaran (
    alb_cve_albaran   INT AUTO_INCREMENT PRIMARY KEY,
    alb_calle         VARCHAR(40) NOT NULL,
    alb_numero        VARCHAR(15) NOT NULL,
    alb_colonia       VARCHAR(40) NOT NULL,
    alb_codigo_postal VARCHAR(5)  NOT NULL,
    alb_ciudad        VARCHAR(40) NOT NULL,
    alb_receptor      VARCHAR(40) NOT NULL,
    alb_fecha_entrega DATETIME    NOT NULL,
    det_cve_linea     INT         NOT NULL,
    CONSTRAINT fk_albaran_detalle FOREIGN KEY (det_cve_linea) REFERENCES linea_detalle_pedido(det_cve_linea)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE modo_pago (
    mod_cve_modo    INT AUTO_INCREMENT PRIMARY KEY,
    mod_tipo_pago   VARCHAR(50)  NOT NULL,
    mod_descripcion VARCHAR(150) NOT NULL,
    mod_estatus     VARCHAR(20)  NOT NULL,
    mod_fecha_reg   DATETIME     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE factura (
    fac_cve_factura      INT AUTO_INCREMENT PRIMARY KEY,
    fac_folio_sat        VARCHAR(10) NOT NULL,
    fac_fecha_generacion DATETIME    NOT NULL,
    alb_cve_albaran      INT         NOT NULL,
    mod_cve_modo         INT         NOT NULL,
    CONSTRAINT fk_factura_albaran  FOREIGN KEY (alb_cve_albaran) REFERENCES albaran(alb_cve_albaran),
    CONSTRAINT fk_factura_modopago FOREIGN KEY (mod_cve_modo)    REFERENCES modo_pago(mod_cve_modo)
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

INSERT INTO cliente (cli_nombre, cli_apellido_paterno, cli_apellido_materno, cli_email, cli_fax, cli_estatus, cli_fecha_registro) VALUES
('Carlos', 'Mendoza', 'García', 'carlos.mendoza@email.com', '555-0192', 'A', NOW()),
('Ana', 'Hernández', 'López', 'ana.hernandez@email.com', NULL, 'A', NOW()),
('Roberto', 'Gómez', 'Martínez', 'roberto.gomez@email.com', '555-0144', 'A', NOW()),
('Laura', 'Torres', 'Ramírez', 'laura.torres@email.com', NULL, 'I', NOW()),
('Miguel', 'Ángel', 'Vásquez', 'miguel.vasquez@email.com', '555-0188', 'A', NOW());

INSERT INTO modelo (mod_nombre, mod_descripcion, mod_estatus, mod_fecha_reg) VALUES
('PowerEdge R750', 'Servidor de rack empresarial de alto rendimiento para bases de datos', 'ACTIVO', NOW()),
('ThinkPad X1 Carbon', 'Laptop ultraligera orientada a desarrollo e infraestructura', 'ACTIVO', NOW()),
('Cloud EC2 Standard', 'Instancia virtual orientada a cómputo general en la nube', 'ACTIVO', NOW()),
('Catalyst 9300', 'Switch administrable de capa 3 para redes corporativas', 'ACTIVO', NOW()),
('Enterprise DB v15', 'Licencia de motor de base de datos relacional para alto tráfico', 'ACTIVO', NOW());

INSERT INTO familia (fam_nombre, fam_descripcion, fam_estatus, fam_fecha_reg) VALUES
('Hardware', 'Servidores, componentes y equipos físicos', 'ACTIVO', NOW()),
('Software', 'Sistemas operativos, licencias y suites', 'ACTIVO', NOW()),
('Cloud Computing', 'Servicios de infraestructura y cómputo en la nube', 'ACTIVO', NOW()),
('Redes y Connect', 'Equipos de conectividad, switches y routers', 'ACTIVO', NOW()),
('Ciberseguridad', 'Soluciones de protección, firewalls y licencias de software', 'ACTIVO', NOW());

INSERT INTO articulo (art_nombre, art_descripcion,art_estatus, art_existencias, art_precio, art_foto, art_fecha_reg, mod_cve_modelo, fam_cve_familia) VALUES
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

UPDATE articulo 
SET art_foto = CONCAT('imagenes/articulos/', art_cve_articulo, '.jpg');

-- =========================================================================
-- 4. VISTAS
-- =========================================================================

CREATE VIEW vwRptArticulos AS
SELECT  
    a.art_cve_articulo AS clave, 
    a.art_descripcion AS descripcion, 
    a.art_nombre AS nombre, 
    a.art_precio AS precio,   
    a.art_existencias AS existencias, 
    a.art_foto AS foto,
    CONCAT(m.mod_nombre, ' (', m.mod_descripcion, ')') AS modelo,  
    f.fam_nombre AS familia 
FROM articulo a
INNER JOIN modelo m ON a.mod_cve_modelo = m.mod_cve_modelo
INNER JOIN familia f ON a.fam_cve_familia = f.fam_cve_familia
WHERE a.art_estatus = 'DISPONIBLE' 
  AND a.art_existencias > 0 
ORDER BY a.art_cve_articulo;

-- =========================================================================
-- 5. PROCEDIMIENTOS ALMACENADOS
-- =========================================================================

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
END;


-- =========================================================================
-- 6. PRUEBAS DE VERIFICACIÓN
-- =========================================================================

CALL sp_Acceso('pperez', 'itp2026');
CALL sp_Acceso('hola', '12345');
SELECT * FROM vwRptArticulos;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- (6) PROCEDIMIENTO PARA ALTA DE USUARIOS 
--     1. NO SE PUEDE REGISTRAR UN USUARIO EXACTAMENTE CON EL MISMO NOMBRE, AP. PATERNO Y AP. MATERNO
--     2. NO SE PUEDE REGISTRAR UN USUARIO (USU_USUARIO) YA EXISTA
--     3. LA LLAVE FORANEA (TIP_CVE_TIPOUSUARIO) EXISTA EN SU TABLA CATALOGO
--     4. NOMBRE DEL PROCEDIMIENTO: sp_InsUsuario

CREATE PROCEDURE sp_InsUsuario
(
IN nombre	varchar(30),
IN paterno	varchar(30),
IN materno	varchar(30),
IN telefono	varchar(15),
IN correo	varchar(50),
IN usuario	varchar(15),
IN contrasena	varchar(15),
IN rol		int
)
BEGIN
	-- 1ERA VALIDACION
	IF NOT EXISTS(SELECT usu_cve_usuario FROM usuario WHERE usu_nombre = nombre 
			  AND   usu_apellido_paterno = paterno
			  AND   usu_apellido_materno = materno ) THEN
		-- 2DA VALIDACION
		IF NOT EXISTS(SELECT usu_cve_usuario FROM usuario WHERE usu_usuario = usuario) THEN

			-- 3ERA VALIDACION
			IF EXISTS(SELECT rol_cve_rol FROM rol WHERE rol_cve_rol = rol) THEN
				-- VALIDACIONES CORRECTAS, SE PROCEDE A INSERTAR REGISTRO
				INSERT INTO usuario VALUES(null, nombre, paterno, materno, telefono, correo, now(), usuario, contrasena, rol);
				SELECT '0' as usu_ban;
			ELSE
				-- NO EXISTE EL TIPO DE USUARIO EN TABLA TIPO_USUARIO
				SELECT '3' as usu_ban;
			END IF;

		ELSE
			-- SI EXISTE UN USUARIO REGISTRADO CON EL PARAMETRO RECIBIDO
			SELECT '2' as usu_ban;
		END IF;

	ELSE
		-- SI EXISTE UN USUARIO CON EL NOMBRE, APELLIDO PATERNO Y APELLIDO MATERNO REGISTRADO
		SELECT '1' as usu_ban;
	END IF;

END;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SECCION DE PRUEBAS
CALL sp_InsUsuario('Ana', 'Bell', 'Perez', '7711234554', 'ana@loquesea.com', 'lperezb', 'isc2026', 1);	-- 1
CALL sp_InsUsuario('Ana', 'Ball', 'Lopez', '7711234554', 'ana@loquesea.com', 'lbell', 'isc2026', 10);	-- 1
SELECT * FROM usuario;


-- ADD__SP_spInsArticulo.sql

CREATE PROCEDURE spInsArticulo
(
    IN in_nombre        VARCHAR(50),
    IN in_descripcion   VARCHAR(250),
    IN in_estatus       VARCHAR(20),
    IN in_existencias   INT,
    IN in_precio        DECIMAL(9,2),
    IN in_cve_modelo    INT,
    IN in_cve_fam       INT
)
BEGIN
    -- VARS
    DECLARE var_nuevo_id INT;

    -- ERROR HANDLER / CATCH
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- ERROR CODE DATABASE IN TRANSACTION
        SELECT 4 AS resultado, NULL AS id_insertado;
    END;

    START TRANSACTION;
        INSERT INTO articulo (
            art_cve_articulo,
            art_nombre, 
            art_descripcion, 
            art_estatus, 
            art_existencias, 
            art_precio, 
            art_foto,
            art_fecha_reg, 
            mod_cve_modelo, 
            fam_cve_familia
        )
        VALUES (
            NULL,
            in_nombre,
            in_descripcion,
            in_estatus,
            in_existencias,
            in_precio,
            'imagenes/articulos/default.jpg', 
            NOW(),
            in_cve_modelo,
            in_cve_fam
        );

        SET var_nuevo_id = LAST_INSERT_ID();

        UPDATE articulo
        SET art_foto = CONCAT('imagenes/articulos/', var_nuevo_id, '.jpg')
        WHERE art_cve_articulo = var_nuevo_id;
    COMMIT;
    
    SELECT 0 AS resultado, var_nuevo_id AS id_insertado;

END;

-- Firma: CALL spInsArticulo(nombre, descripcion, estatus, existencias, precio, cve_modelo, cve_fam)

CALL spInsArticulo('Monitor Dell UltraSharp 27', 'Monitor 4K UHD 27 pulgadas IPS con concentrador USB-C integrados', 'DISPONIBLE', 30, 8999.00, 1, 1);
CALL spInsArticulo('Teclado Mecánico Logitech MX', 'Teclado inalámbrico con interruptores silenciosos y retroiluminación', 'DISPONIBLE', 50, 2499.50, 2, 1);
CALL spInsArticulo('Mouse Inalámbrico MX Master 3S', 'Sensor de 8000 DPI con clics silenciosos y desplazamiento magnético', 'DISPONIBLE', 40, 1899.00, 2, 1);
CALL spInsArticulo('Router Cisco ISR 4331', 'Router de servicios integrados con soporte para enlaces WAN gigabit', 'DISPONIBLE', 8, 24500.00, 4, 4);
CALL spInsArticulo('Firewall Fortinet FortiGate 60F', 'Dispositivo de seguridad perimetral SD-WAN y UTM para sucursales', 'DISPONIBLE', 12, 14200.00, 4, 4);

CALL spInsArticulo('Servidor HPE ProLiant DL380 Gen10', 'Servidor de 2U escalable con procesador Intel Xeon Gold y 128GB RAM', 'DISPONIBLE', 5, 78000.00, 1, 1);
CALL spInsArticulo('NAS Synology RackStation', 'Almacenamiento en red de 12 bahías SATA/SAS con fuentes redundantes', 'DISPONIBLE', 7, 31000.00, 1, 1);
CALL spInsArticulo('UPS APC Smart-UPS 3000VA', 'Sistema de alimentación ininterrumpida de 3000VA para rack 2U', 'DISPONIBLE', 18, 16500.00, 1, 1);
CALL spInsArticulo('Licencia VMware vSphere Enterprise', 'Suscripción por socket para virtualización de servidores empresariales', 'DISPONIBLE', 50, 12400.00, 5, 2);
CALL spInsArticulo('Licencia Red Hat Enterprise Linux', 'Suscripción anual RHEL Server con soporte estándar 8x5', 'DISPONIBLE', 80, 4800.00, 5, 2);

CALL spInsArticulo('Access Point Aruba AP-515', 'Punto de acceso Wi-Fi 6 de alto rendimiento para ambientes corporativos', 'DISPONIBLE', 35, 6800.00, 4, 4);
CALL spInsArticulo('Gabinete Rack Tripp Lite 42U', 'Rack de piso para servidores y equipos de red con puertas de malla', 'DISPONIBLE', 10, 15300.00, 1, 1);
CALL spInsArticulo('Disco Duro SAS Seagate Exos 18TB', 'Disco empresarial 7200 RPM 12Gb/s para almacenamiento masivo', 'DISPONIBLE', 60, 5200.00, 1, 1);
CALL spInsArticulo('SSD NVMe Samsung PM9A1 2TB', 'Unidad de estado sólido PCIe 4.0 empresarial para lectura intensa', 'DISPONIBLE', 45, 3800.00, 1, 1);
CALL spInsArticulo('Instancia Cloud Azure D8s v5', 'Máquina virtual cloud con 8 vCPU y 32GB RAM en región Este de EEUU', 'DISPONIBLE', 500, 1350.00, 3, 3);

CALL spInsArticulo('Servidor VPS Storage 1TB', 'Servidor privado virtual optimizado para respaldos masivos de datos', 'DISPONIBLE', 200, 450.00, 3, 3);
CALL spInsArticulo('Licencia Microsoft 365 E5', 'Suscripción anual por usuario con protección avanzada contra amenazas', 'DISPONIBLE', 150, 7200.00, 5, 2);
CALL spInsArticulo('Licencia Docker Enterprise', 'Plataforma de orquestación y contenedores con soporte corporativo', 'DISPONIBLE', 30, 9600.00, 5, 2);
CALL spInsArticulo('Cable UTP Panduit Cat6A 305m', 'Carrete de cable UTP Categoría 6A 10Gbps cero halógenos para red', 'DISPONIBLE', 25, 4100.00, 4, 4);
CALL spInsArticulo('Transceptor SFP+ Cisco 10G SR', 'Módulo óptico multimodo 10GBASE-SR con conector LC dúplex', 'DISPONIBLE', 100, 1850.00, 4, 4);

CALL spInsArticulo('Workstation HP Z4 G4', 'Estación de trabajo Intel Xeon W, 64GB RAM y Nvidia RTX 4000', 'DISPONIBLE', 14, 42000.00, 2, 1);
CALL spInsArticulo('Laptop Dell Latitude 5430', 'Equipo portátil corporativo Core i5, 16GB RAM, 512GB SSD', 'AGOTADO', 0, 18500.00, 2, 1);
CALL spInsArticulo('KVM Switch ATEN 16 Puertos', 'Conmutador KVM para montaje en rack con acceso IP remoto seguro', 'DISPONIBLE', 6, 11200.00, 4, 4);
CALL spInsArticulo('Licencia Kaspersky Endpoint', 'Protección antivirus y firewall para 50 nodos empresariales', 'DISPONIBLE', 40, 13500.00, 5, 2);
CALL spInsArticulo('Cámara IP Hikvision 4K PoE', 'Cámara domo de videovigilancia perimetral con visión nocturna 30m', 'DISPONIBLE', 50, 2900.00, 4, 4);
