<?php 
/* servicioweb/servicioweb.php 
 *
 * Deja los metodos expuestos para ser usados por front
 */
include 'clsservicios.php';


$soap = new SoapServer(null, array('uri' => 'http://localhost/'));
/* Se ejecuta la clase que contiene los métodos */
$soap -> setClass('clsservicios');
/* se ejecuta la clase */
$soap -> handle();

?>
