<?php
    // session_start();
    session_unset();    // limpiar vars session
    session_destroy();  // destruye vars session

    echo "
        <script language='javascript'>document.location.href='inicio.php?op=acceso';</script>
    ";
?>
