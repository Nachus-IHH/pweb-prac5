<?php   
/* sitioweb/acceso.php
 *
 */
          
$usuario="";
$contrasena="";
//un arreglo que reciba el resultado del método del servicio web
$datos=array();

//VERIFICA QUE LLEGUEN LOS DATOS DE LA PAGINA ACCESO
if( !empty($_REQUEST['txtUsuario']) 
    && !empty($_REQUEST['txtContrasena']) ){

    //TOMA LOS VALORES DE LAS CAJAS DE TEXTO
    $usuario    =htmlspecialchars($_REQUEST['txtUsuario']);
    $contrasena =htmlspecialchars($_REQUEST['txtContrasena']);

    //######### HACE USO DEL SERVICIO WEB QUE ESTA PUBLICADO DE MANERA LOCAL ########		 
    $cliente = new SoapClient(
        null,
        array(
            'location' => 'http://localhost/prog-web/prac5/servicioweb/servicioweb.php',
            'uri'      => 'http://localhost/'
        )
    );
  
    //SE EJECUTA EL MÉTODO DE ACCESO DEL SERVICIO WEB, PASANDO SUS PARAMETROS
    $datos = $cliente->sp_Acceso($usuario, $contrasena);
    //SE VERIFICA QUE EL USUARIO EXISTA
    if((int)$datos[0]["BAN"] != 0){
    // EL ARREGLO RECIBIDO SE CONVIERTE EN JSON PARA ENVIARLO DE SALIDA  
        if(!isset($_SESSION['cveUsuario'])) {
            $_SESSION['cveUsuario'] = $datos[0]["CVE"];
        }
        if(!isset($_SESSION['nomUsuario'])) {
            $_SESSION['nomUsuario'] = $datos[0]["NOM"];
            echo $_SESSION['nomUsuario'];
        }
        if(!isset($_SESSION['usuUsuario'])) {
            $_SESSION['usuUsuario'] = $datos[0]["USU"];
        }
        if(!isset($_SESSION['rolUsuario'])) {
            $_SESSION['rolUsuario'] = $datos[0]["ROL"];
        }
        echo "
            <script language='javascript'>alert('Bienvenid@: " . $_SESSION['nomUsuario'] . "');</script>
            <script language='javascript'>document.location.href='inicio.php?op=bienvenida';</script>
        ";
        echo json_encode($datos[0]);
    }
    else {
    // USUARIO NO ENCONTRADO
        if(
            isset($_SESSION['cveUsuario']) &&
            isset($_SESSION['nomUsuario']) &&
            isset($_SESSION['usuUsuario']) &&
            isset($_SESSION['rolUsuario'])
        ) {
            echo "
                <script language='javascript'>
                    alert('Usuario y/o contraseña incorrectos');
                    document.location.href='inicio.php?op=cerrar';
                </script>
            ";
        }
        echo json_encode($datos[0]);  
    }

}

?> 
<html> 
<head>

 <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <!--se agrega un link para acceder a los archivos compilados y comprimidos de bootstratp-->
  <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
</head>
	<body>
	<form id="frmAcceso" method="POST">	
		
         <div class="container">      
			<table width="800px" align="center">
			  <tr>
			    <td >
				  <table align="center">
				  <tr rowspan="3">
				      <td colspan="2" align="center"><hr style="color:#102C54"/></td>
				     </tr>
				  <tr rowspan="3">
				   <td colspan="2"  align="center"><h1>Consumir servicio Web</h1></td>
				  </tr>		
				  	<tr>
					    <td colspan="2"><br /></td>
					</tr>
					<tr >
						<td>Usuario:</td>						
						<td>
						   <input type="text" name="txtUsuario" class="form-control"  placeholder="Nombre de usuario">
						</td>						
					</tr>
					<tr >
						<td>Contraseña:</td>						
						<td>
						   <input type="text" name="txtContrasena" class="form-control"  placeholder="Nombre de usuario">
						</td>						
					</tr>					
					<tr>
						<td colspan="2" align="center"><br>
						   <input type="submit" value="Aceptar" class="btn btn-primary">
						   <input type="button" value="Cancelar" class="btn btn-primary">
						</td>												
					</tr>					
					<tr rowspan="3">
				      <td colspan="2" align="center"><hr style="color:#102C54"/></td>
				     </tr>
				  </table>
				</td>
				<td>
				</td>
			  </tr>
			</table>
	       </div>   
	</form>
	</body>
</html>
