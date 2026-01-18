# Función para listar procesos
function Listar-Procesos {
    Write-Host "`n--- PROCESOS ACTIVOS ---" -ForegroundColor Cyan
    # Obtenemos procesos y calculamos la memoria en MB manualmente
    $procesos = Get-Process | Select-Object Id, Name, WorkingSet
    
    foreach ($p in $procesos) {
        $memoriaMB = [math]::Round($p.WorkingSet / 1MB, 2)
        Write-Host "ID: $($p.Id) | Nombre: $($p.Name) | Memoria: $memoriaMB MB"
    }
}

# Función para listar servicios
function Listar-Servicios {
    Write-Host "`n--- SERVICIOS DEL SISTEMA ---" -ForegroundColor Cyan
    # Filtramos y mostramos nombre y estado
    Get-Service | Select-Object DisplayName, Status | Sort-Object Status
}

# Función para mostrar uso de disco
function Mostrar-Disco {
    Write-Host "`n--- USO DE DISCO (FileSystem) ---" -ForegroundColor Cyan
    # Filtramos por el proveedor FileSystem según el requerimiento
    $discos = Get-PSDrive -PSProvider FileSystem

    foreach ($d in $discos) {
        $total = [math]::Round(($d.Used + $d.Free) / 1GB, 2)
        $usado = [math]::Round($d.Used / 1GB, 2)
        $libre = [math]::Round($d.Free / 1GB, 2)
        
        Write-Host "Unidad: $($d.Name)"
        Write-Host "  Total: $total GB"
        Write-Host "  Usado: $usado GB"
        Write-Host "  Libre: $libre GB"
        Write-Host "----------------"
    }
}

# --- BUCLE PRINCIPAL DEL MENÚ ---
do {
    $fecha = Get-Date -Format "dd-MM-yyyy"
    Write-Host "`n========================================"
    Write-Host "     MENU DE SISTEMA - FECHA $fecha"
    Write-Host "========================================"
    Write-Host "1. Listar procesos en ejecución"
    Write-Host "2. Listar servicios del sistema"
    Write-Host "3. Mostrar uso del disco"
    Write-Host "4. Salir"
    Write-Host "----------------------------------------"

    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        "1" { Listar-Procesos }
        "2" { Listar-Servicios }
        "3" { Mostrar-Disco }
        "4" { Write-Host "Saliendo..." -ForegroundColor Yellow }
        default { Write-Host "Opción no válida." -ForegroundColor Red }
    }

    if ($opcion -ne "4") {
        Read-Host "`nPresione Enter para continuar..."
        Clear-Host
    }

} while ($opcion -ne "4")