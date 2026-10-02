<?php  
/* paginas/rptarticulos.php */
$datos = array();
$jsonSalida = "";

// Captura de Parámetros desde $_GET
$paginaActual = isset($_GET['p']) ? max(1, intval($_GET['p'])) : 1;
$limitePorPagina = 20;

$pMin     = isset($_GET['p_min']) && $_GET['p_min'] !== '' ? floatval($_GET['p_min']) : null;
$pMax     = isset($_GET['p_max']) && $_GET['p_max'] !== '' ? floatval($_GET['p_max']) : null;
$fFamilia = $_GET['f_familia'] ?? '';
$fModelo  = $_GET['f_modelo']  ?? '';

$totalRegistros = 0;
$totalPaginas   = 1;

$listaFamilias = array();
$listaModelos  = array();

try {
    $cliente = new SoapClient(
        null,
        array(
            'location' => 'http://localhost/prog-web/prac5/servicioweb/servicioweb.php',
            'uri'      => 'http://localhost/'
        )
    );

    // 1. Obtener catálogo de Familias desde el WS
    $respFamilias = $cliente->obtenerFamilias();
    $rawFamilias = json_decode(json_encode($respFamilias), true) ?? array();
    
    // Normalizar si SOAP devuelve un único registro como objeto/arreglo simple
    if (isset($rawFamilias['familia'])) {
        $listaFamilias = array($rawFamilias);
    } else {
        $listaFamilias = $rawFamilias;
    }

    // 2. Obtener catálogo de Modelos (En cascada según la familia seleccionada)
    $respModelos = $cliente->obtenerModelos($fFamilia);
    $rawModelos = json_decode(json_encode($respModelos), true) ?? array();
    
    if (isset($rawModelos['modelo'])) {
        $listaModelos = array($rawModelos);
    } else {
        $listaModelos = $rawModelos;
    }

    // 3. Consumir el método paginado de artículos
    $respuesta = $cliente->vw_rptArticulosPaginado($paginaActual, $limitePorPagina, $fFamilia, $fModelo, $pMin, $pMax);
    
    // Normalizar datos de artículos
    $resultado = json_decode(json_encode($respuesta), true);
    
    $datos          = $resultado['datos'] ?? array();
    $totalRegistros = (int)($resultado['total'] ?? 0);
    $totalPaginas   = (int)($resultado['total_paginas'] ?? 1);
    $paginaActual   = (int)($resultado['pagina_actual'] ?? 1);

    $jsonSalida = json_encode($resultado, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

} catch (SoapFault $e) {
    $datos = array();
    $jsonSalida = json_encode(["error_rptArticulos" => $e->getMessage()]);
}

// Función auxiliar para mantener filtros en la URL al cambiar de página
function urlPagina($p) {
    $params = $_GET;
    $params['p'] = $p;
    return 'inicio.php?' . http_build_query($params);
}
?>

<style>
    .catalog-wrapper { overflow-x: hidden; width: 100%; }

    .ml-grid {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 0.75rem;
        width: 100%;
    }
    @media (max-width: 1200px) { .ml-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); } }
    @media (max-width: 768px)  { .ml-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
    @media (max-width: 480px)  { .ml-grid { grid-template-columns: repeat(1, minmax(0, 1fr)); } }

    .product-card {
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        background: #fff;
        padding: 0.65rem;
        font-size: 0.8rem;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        height: 100%;
        min-width: 0;
        overflow: hidden;
    }

    .product-thumb {
        height: 110px;
        object-fit: contain;
        width: 100%;
        margin-bottom: 0.4rem;
        border-radius: 4px;
        background-color: #f8f9fa;
    }

    .product-title {
        font-weight: 600;
        color: #2b2b2b;
        line-height: 1.2;
        height: 2.4em;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        word-break: break-word;
        margin-bottom: 0.2rem;
    }

    .product-desc {
        font-size: 0.73rem;
        color: #6c757d;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        margin-bottom: 0.3rem;
    }

    .product-price {
        font-size: 1.15rem;
        font-weight: 700;
        color: #00a650;
        margin-bottom: 0.2rem;
    }

    .badge-ml {
        font-size: 0.68rem;
        padding: 0.2em 0.4em;
        font-weight: 600;
        max-width: 100%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .filter-card {
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        background: #fff;
        padding: 0.9rem;
    }

    .filter-title {
        font-weight: 600;
        font-size: 0.85rem;
        color: #333;
    }
</style>

<div class="catalog-wrapper">
    <!-- Encabezado -->
    <div class="p-2 mb-3 bg-light rounded border d-flex justify-content-between align-items-center">
        <div>
            <h6 class="fw-bold text-primary mb-0">Ignacio Hernández Hernández - 23200144</h6>
            <small class="text-muted">Práctica 5 | Reporte de Artículos Paginado (SOAP)</small>
        </div>
        <span class="badge bg-secondary px-2 py-1 fs-7">
            Mostrando <?= count($datos) ?> de <?= $totalRegistros ?> productos (Pág. <?= $paginaActual ?>/<?= $totalPaginas ?>)
        </span>
    </div>

    <div class="row g-2 m-0">
        <!-- PANEL IZQUIERDO: FILTROS -->
        <aside class="col-lg-3 col-md-4 ps-0 pe-2">
            <div class="filter-card shadow-sm">
                <h5 class="fw-bold mb-1" style="font-size: 1.2rem;">Filtros</h5>
                <p class="text-muted small mb-3"><?= number_format($totalRegistros) ?> resultados</p>

                <form method="GET" action="inicio.php" id="formFiltros">
                    <input type="hidden" name="op" value="rptarticulos">
                    <input type="hidden" name="p" value="1"><!-- Al filtrar, reinicia a la página 1 -->

                    <!-- Filtro: Precio -->
                    <div class="mb-3">
                        <label class="filter-title mb-1">Precio</label>
                        <div class="d-flex align-items-center gap-1 mb-2">
                            <input type="number" step="0.01" class="form-control form-control-sm" name="p_min" placeholder="Mínimo" value="<?= htmlspecialchars($_GET['p_min'] ?? '') ?>">
                            <span class="text-muted">-</span>
                            <input type="number" step="0.01" class="form-control form-control-sm" name="p_max" placeholder="Máximo" value="<?= htmlspecialchars($_GET['p_max'] ?? '') ?>">
                            <button type="submit" class="btn btn-sm btn-outline-secondary px-2"><i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>

                    <hr class="my-2">

                    <!-- Filtro: Familia (Select Dinámico) -->
                    <div class="mb-3">
                        <label class="filter-title mb-1">Familia</label>
                        <select name="f_familia" class="form-select form-select-sm" onchange="document.getElementById('f_modelo').value=''; this.form.submit();">
                            <option value="">Todas las familias</option>
                            <?php foreach ($listaFamilias as $fam): ?>
                                <?php 
                                    $valFam = is_array($fam) ? ($fam['familia'] ?? $fam['nombre'] ?? reset($fam)) : $fam; 
                                    if (empty($valFam)) continue;
                                ?>
                                <option value="<?= htmlspecialchars($valFam) ?>" <?= ($fFamilia === $valFam) ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($valFam) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <!-- Filtro: Modelo (Select en Cascada) -->
                    <div class="mb-3">
                        <label class="filter-title mb-1">Modelo</label>
                        <select name="f_modelo" id="f_modelo" class="form-select form-select-sm" onchange="this.form.submit();">
                            <option value="">Todos los modelos</option>
                            <?php foreach ($listaModelos as $mod): ?>
                                <?php 
                                    $valMod = is_array($mod) ? ($mod['modelo'] ?? $mod['nombre'] ?? reset($mod)) : $mod; 
                                    if (empty($valMod)) continue;
                                ?>
                                <option value="<?= htmlspecialchars($valMod) ?>" <?= ($fModelo === $valMod) ? 'selected' : '' ?>>
                                    <?= htmlspecialchars($valMod) ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-sm btn-primary w-100 mb-2">Aplicar Filtros</button>

                    <?php if ($pMin !== null || $pMax !== null || $fFamilia !== '' || $fModelo !== ''): ?>
                        <a href="inicio.php?op=rptarticulos" class="btn btn-sm btn-light border w-100 text-danger fw-semibold">
                            <i class="bi bi-x-circle me-1"></i>Limpiar filtros
                        </a>
                    <?php endif; ?>
                </form>
            </div>
        </aside>

        <!-- SECCIÓN PRINCIPAL: Tarjetas -->
        <main class="col-lg-9 col-md-8 px-0">
            <?php if (!empty($datos)): ?>
                <div class="ml-grid">
                    <?php foreach ($datos as $art): ?>
                        <?php 
                            $fotoBD = trim($art['foto'] ?? '');
                            $fotoUrl = !empty($fotoBD) ? ltrim($fotoBD, '/') : 'https://via.placeholder.com/200x150/f8f9fa/cccccc?text=Sin+Imagen';
                        ?>
                        <div class="product-card">
                            <div>
                                <img src="<?= htmlspecialchars($fotoUrl) ?>" 
                                     class="product-thumb" 
                                     alt="<?= htmlspecialchars($art['nombre'] ?? 'Producto') ?>"
                                     onerror="this.onerror=null; this.src='https://via.placeholder.com/200x150/f8f9fa/cccccc?text=Sin+Imagen';">
                                
                                <div class="product-title" title="<?= htmlspecialchars($art['nombre'] ?? '') ?>">
                                    <?= htmlspecialchars($art['nombre'] ?? 'Sin nombre') ?>
                                </div>
                                
                                <div class="product-desc" title="<?= htmlspecialchars($art['descripcion'] ?? '') ?>">
                                    <?= htmlspecialchars($art['descripcion'] ?? '') ?>
                                </div>
                            </div>

                            <div>
                                <div class="product-price">
                                    $<?= number_format((float)($art['precio'] ?? 0), 2) ?>
                                </div>

                                <div class="d-flex flex-wrap gap-1 align-items-center mt-1">
                                    <?php if (intval($art['existencias'] ?? 0) > 0): ?>
                                        <span class="badge bg-success-subtle text-success border border-success-subtle badge-ml">
                                            <i class="bi bi-lightning-fill"></i> Disponible (<?= $art['existencias'] ?>)
                                        </span>
                                    <?php else: ?>
                                        <span class="badge bg-danger-subtle text-danger badge-ml">Agotado</span>
                                    <?php endif; ?>

                                    <span class="badge bg-light text-dark border badge-ml" title="<?= htmlspecialchars($art['familia'] ?? 'General') ?>">
                                        <?= htmlspecialchars($art['familia'] ?? 'General') ?>
                                    </span>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>

                <!-- BARRA DE PAGINACIÓN -->
                <?php if ($totalPaginas > 1): ?>
                    <nav class="mt-4 d-flex justify-content-center">
                        <ul class="pagination pagination-sm mb-0">
                            <!-- Botón Anterior -->
                            <li class="page-item <?= ($paginaActual <= 1) ? 'disabled' : '' ?>">
                                <a class="page-link" href="<?= urlPagina($paginaActual - 1) ?>">&laquo; Anterior</a>
                            </li>

                            <!-- Números de Página -->
                            <?php 
                                $rango = 2; 
                                for ($i = 1; $i <= $totalPaginas; $i++): 
                                    if ($i == 1 || $i == $totalPaginas || ($i >= $paginaActual - $rango && $i <= $paginaActual + $rango)):
                            ?>
                                <li class="page-item <?= ($i == $paginaActual) ? 'active' : '' ?>">
                                    <a class="page-link" href="<?= urlPagina($i) ?>"><?= $i ?></a>
                                </li>
                            <?php 
                                    elseif ($i == $paginaActual - $rango - 1 || $i == $paginaActual + $rango + 1): 
                            ?>
                                <li class="page-item disabled"><span class="page-link">...</span></li>
                            <?php 
                                    endif;
                                endfor; 
                            ?>

                            <!-- Botón Siguiente -->
                            <li class="page-item <?= ($paginaActual >= $totalPaginas) ? 'disabled' : '' ?>">
                                <a class="page-link" href="<?= urlPagina($paginaActual + 1) ?>">Siguiente &raquo;</a>
                            </li>
                        </ul>
                    </nav>
                <?php endif; ?>

            <?php else: ?>
                <div class="alert alert-warning text-center py-4">
                    <i class="bi bi-exclamation-triangle fs-3 d-block mb-2"></i>
                    No se encontraron artículos que coincidan con la búsqueda.
                </div>
            <?php endif; ?>

            <!-- SALIDA RAW JSON DE EVIDENCIA -->
            <div class="mt-4">
                <button class="btn btn-sm btn-outline-secondary mb-2" type="button" data-bs-toggle="collapse" data-bs-target="#jsonCollapse">
                    <i class="bi bi-code-slash me-1"></i>Ver Salida Raw (JSON)
                </button>
                <div class="collapse" id="jsonCollapse">
                    <div class="bg-dark text-warning p-3 rounded border">
                        <pre class="m-0" style="max-height: 200px; overflow-y: auto;"><code><?= $jsonSalida ?></code></pre>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>
