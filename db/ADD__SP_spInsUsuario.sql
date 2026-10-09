-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- (6) PROCEDIMIENTO PARA ALTA DE USUARIOS 
--     1. NO SE PUEDE REGISTRAR UN USUARIO EXACTAMENTE CON EL MISMO NOMBRE, AP. PATERNO Y AP. MATERNO
--     2. NO SE PUEDE REGISTRAR UN USUARIO (USU_USUARIO) YA EXISTA
--     3. LA LLAVE FORANEA (TIP_CVE_TIPOUSUARIO) EXISTA EN SU TABLA CATALOGO
--     4. NOMBRE DEL PROCEDIMIENTO: sp_InsUsuario

delimiter $$
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

END $$
delimiter ;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SECCION DE PRUEBAS
CALL sp_InsUsuario('Ana', 'Bell', 'Perez', '7711234554', 'ana@loquesea.com', 'lperezb', 'isc2026', 1);	-- 1
CALL sp_InsUsuario('Ana', 'Ball', 'Lopez', '7711234554', 'ana@loquesea.com', 'lbell', 'isc2026', 10);	-- 1
SELECT * FROM usuario;
