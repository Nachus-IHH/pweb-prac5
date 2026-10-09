-- ADD__SP_spInsArticulo.sql

delimiter $$
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

END $$
delimiter ;

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
