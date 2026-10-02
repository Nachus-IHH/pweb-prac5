<?php
/* sitioweb/rptArticulos.php */

header('Content-Type: application/json; charset=utf-8');

$respuesta = [
    "alumno" => "Ignacio Hernández Hernández - 23200144",
    "datos" => []
];

try {
    $cliente = new SoapClient(
        null,
        array(
            'location' => 'http://localhost/prog-web/prac5/servicioweb/servicioweb.php',
            'uri'      => 'http://localhost/'
        )
    );

    $respuesta["datos"] = $cliente->vw_rptArticulos();

} catch (SoapFault $e) {
    $respuesta["error_rptarticulosjson"] = $e->getMessage();
}

echo json_encode($respuesta, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

?>
