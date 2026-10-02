<?php 
/* servicioweb/clsservicios.php
 *
 * Servicios que proporciona el backend
 */

require_once __DIR__ . '/connection.php';

class clsservicios {

    /* ======================== METODOS POST ======================== */
    
    /* Método de bienvenida */
    public function name($nom) {
        return "Bienvenido " . $nom . ", estas usando el servicio web";
    }

    public function verificacionUsuario($user, $password) {
        return "Verificación del usuario: " . $user . ", password: " . $password;
    }

    // PROGRAMACIÓN DE MÉTODOS
    public function sp_Acceso($usu, $pwd) {
        $conn = connection::getConnection();
        
        // Se estructura el comando SQL para ejecutar 
        $cmdSql = "call sp_Acceso('$usu','$pwd');";

        // Variable para recepción de estatus+datos
        $datos = array();
        
        // Ejecución del comando SQL y recibir resultados (recordset)
        $renglon = mysqli_query($conn, $cmdSql);

        if ($renglon && mysqli_num_rows($renglon) > 0) {
            // Ciclo para lectura de registros
            while ($resultado = mysqli_fetch_assoc($renglon)) {
                $datos[0]["BAN"] = $resultado["usu_ban"];
                if ($datos[0]["BAN"] == "1") {
                    // El usuario existe en BD, extraer los demás datos
                    $datos[0]["CVE"] = $resultado["usu_cve_usuario"];
                    $datos[0]["NOM"] = $resultado["usu_nombre"];
                    $datos[0]["USU"] = $resultado["usu_usuario"];
                    $datos[0]["ROL"] = $resultado["rol_nombre"];
                }
            }
            mysqli_free_result($renglon);
        } else { 
            $datos[0]["BAN"] = "0";        
        }

        return $datos;
    }

    public function vw_rptArticulos() {
        $conn = connection::getConnection();
        
        // Las VISTAS se consultan con SELECT
        $cmdSql = "SELECT * FROM vwRptArticulos;";

        $datos = array();
        $renglon = mysqli_query($conn, $cmdSql);

        if ($renglon && mysqli_num_rows($renglon) > 0) {
            while ($resultado = mysqli_fetch_assoc($renglon)) {
                $datos[] = $resultado;
            }
            mysqli_free_result($renglon);
        }

        return $datos;
    }

    public function vw_rptArticulosPaginado($pagina = 1, $limite = 20, $fFamilia = '', $fModelo = '', $pMin = null, $pMax = null) {
        $conn = connection::getConnection();

        $pagina = max(1, intval($pagina));
        $limite = max(1, intval($limite));
        $offset = ($pagina - 1) * $limite;

        // Filtros dinámicos
        $where = ["1=1"];
        $params = array();
        $types = "";

        if (!empty($fFamilia)) {
            $where[] = "familia = ?";
            $params[] = $fFamilia;
            $types .= "s";
        }
        if (!empty($fModelo)) {
            $where[] = "modelo = ?";
            $params[] = $fModelo;
            $types .= "s";
        }
        if ($pMin !== null && $pMin !== '') {
            $where[] = "precio >= ?";
            $params[] = floatval($pMin);
            $types .= "d";
        }
        if ($pMax !== null && $pMax !== '') {
            $where[] = "precio <= ?";
            $params[] = floatval($pMax);
            $types .= "d";
        }

        $whereSQL = implode(" AND ", $where);

        // -------------------------------------------------------------
        // 1. Obtener el TOTAL de registros que coinciden con los filtros
        // -------------------------------------------------------------
        $sqlCount = "SELECT COUNT(*) AS total FROM vwRptArticulos WHERE $whereSQL";
        $stmtCount = mysqli_prepare($conn, $sqlCount);

        if (!empty($params)) {
            mysqli_stmt_bind_param($stmtCount, $types, ...$params);
        }

        mysqli_stmt_execute($stmtCount);
        $resCount = mysqli_stmt_get_result($stmtCount);
        $rowCount = mysqli_fetch_assoc($resCount);
        $totalRegistros = (int)($rowCount['total'] ?? 0);
        mysqli_stmt_close($stmtCount);

        // -------------------------------------------------------------
        // 2. Obtener los registros de la página actual
        // -------------------------------------------------------------
        $sql = "SELECT * FROM vwRptArticulos WHERE $whereSQL LIMIT ? OFFSET ?";
        $stmt = mysqli_prepare($conn, $sql);

        // Agregar limit y offset a los parámetros
        $paramsPaginado = $params;
        $paramsPaginado[] = $limite;
        $paramsPaginado[] = $offset;
        $typesPaginado = $types . "ii";

        mysqli_stmt_bind_param($stmt, $typesPaginado, ...$paramsPaginado);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);

        $articulos = array();
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) {
                $articulos[] = $row;
            }
        }
        mysqli_stmt_close($stmt);

        return array(
            'datos'         => $articulos,
            'total'         => $totalRegistros,
            'pagina_actual' => $pagina,
            'limite'        => $limite,
            'total_paginas' => ($totalRegistros > 0) ? (int)ceil($totalRegistros / $limite) : 1
        );
    }

    /**
     * Obtiene la lista de familias únicas
     */
    public function obtenerFamilias() {
        $conn = connection::getConnection();

        $sql = "SELECT DISTINCT familia 
                FROM vwRptArticulos 
                WHERE familia IS NOT NULL AND TRIM(familia) != '' 
                ORDER BY familia ASC";

        $resultado = mysqli_query($conn, $sql);

        $familias = array();
        if ($resultado && mysqli_num_rows($resultado) > 0) {
            while ($row = mysqli_fetch_assoc($resultado)) {
                $familias[] = $row;
            }
            mysqli_free_result($resultado);
        }

        return $familias;
    }

    /**
     * Obtiene los modelos en cascada según la familia seleccionada
     */
    public function obtenerModelos($familia = '') {
        $conn = connection::getConnection();
        $familia = trim($familia);

        $modelos = array();

        if (!empty($familia)) {
            // Filtrado por la familia seleccionada
            $sql = "SELECT DISTINCT modelo 
                    FROM vwRptArticulos 
                    WHERE familia = ? 
                      AND modelo IS NOT NULL 
                      AND TRIM(modelo) != '' 
                    ORDER BY modelo ASC";

            $stmt = mysqli_prepare($conn, $sql);

            if ($stmt) {
                mysqli_stmt_bind_param($stmt, "s", $familia);
                mysqli_stmt_execute($stmt);

                $resultado = mysqli_stmt_get_result($stmt);
                if ($resultado) {
                    while ($row = mysqli_fetch_assoc($resultado)) {
                        $modelos[] = $row;
                    }
                }
                mysqli_stmt_close($stmt);
            }
        } else {
            // Si no hay familia elegida ("Todas las familias"), se retornan todos los modelos
            $sql = "SELECT DISTINCT modelo 
                    FROM vwRptArticulos 
                    WHERE modelo IS NOT NULL 
                      AND TRIM(modelo) != '' 
                    ORDER BY modelo ASC";

            $resultado = mysqli_query($conn, $sql);

            if ($resultado && mysqli_num_rows($resultado) > 0) {
                while ($row = mysqli_fetch_assoc($resultado)) {
                    $modelos[] = $row;
                }
                mysqli_free_result($resultado);
            }
        }

        return $modelos;
    }
}
?>
