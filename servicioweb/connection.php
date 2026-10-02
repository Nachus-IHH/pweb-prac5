<?php
/* servicioweb/connection.php */

class connection {
    private static $conn = null;

    private static function cargarEnv($path = __DIR__ . '/.env') {
        // Si el archivo .env no existe (QA/PROD) no pasa nada.
        if (!file_exists($path)) {
            return;
        }

        $lineas = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lineas as $linea) {
            $linea = trim($linea);
            if (strpos($linea, '#') === 0) continue; // Ignorar comentarios

            list($nombre, $valor) = explode('=', $linea, 2);
            $nombre = trim($nombre);
            $valor = trim($valor);

            // REGLA CLAVE: Solo inyecta la variable si NO existe previamente en el S.O.
            if (getenv($nombre) === false && !array_key_exists($nombre, $_ENV)) {
                $_ENV[$nombre] = $valor;
                putenv("$nombre=$valor");
            }
        }
    }

    public static function getConnection() {
        if (self::$conn === null) {
            self::cargarEnv();

            // getenv() leerá primero las vars del SO en EC2 (QA/PROD).
            // Si está en local (DEV), leerá las del archivo .env.
            $host = getenv('DB_HOST') ?: 'localhost';
            $port = getenv('DB_PORT') ?: '3306';
            $user = getenv('DB_USER') ?: 'root';
            $pass = getenv('DB_PASS') ?: '';
            $db   = getenv('DB_NAME') ?: '';

            self::$conn = mysqli_connect($host, $user, $pass, $db, $port);

            if (!self::$conn) {
                die("Error de conexión a la base de datos: " . mysqli_connect_error());
            }
        }

        return self::$conn;
    }
}
