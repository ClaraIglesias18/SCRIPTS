# 1. Leer el archivo saltando las 3 primeras líneas de encabezado decorativo
# 1. Comprobar si el archivo existe
if (-not (Test-Path -Path $path)) {
    Write-Host "⚠️ Error: El archivo '$path' no existe." -ForegroundColor Red
    return
}

$datos = Get-Content -Path "ejemplo.txt" | Select-Object -Skip 3 | ConvertFrom-Csv -Header "Codigo","Marca","Departamento","Alta","Baja"

# --- PROCESAMIENTO DE MENSAJES INDIVIDUALES ---
foreach ($fila in $datos) {
    # El equipo de marca xx está ubicado en el departamento de xx
    Write-Host "El equipo de marca $($fila.Marca) está ubicado en el departamento de $($fila.Departamento)"
    
    # El equipo cuyo código es xx fue dado de alta el xx
    Write-Host "El equipo cuyo código es $($fila.Codigo) fue dado de alta el $($fila.Alta)"
    
    # Verificación de baja
    if ([string]::IsNullOrWhiteSpace($fila.Baja)) {
        # El equipo cuyo código es xx NO fue dado de baja
        Write-Host "El equipo cuyo código es $($fila.Codigo) NO fue dado de baja"
    } else {
        # El equipo cuyo código es xx fue dado de baja el xx
        Write-Host "El equipo cuyo código es $($fila.Codigo) fue dado de baja el $($fila.Baja)"
    }
    Write-Host "------------------------------------------------"
}

# --- ESTADÍSTICAS Y TOTALES ---
Write-Host "`nHay $($datos.Count) equipos en total. Desglose:" -ForegroundColor Cyan

$deptos = $datos | Group-Object Departamento

foreach ($grupo in $deptos) {
    # xx equipos en el departamento de xx
    Write-Host "$($grupo.Count) equipos en el departamento de $($grupo.Name.ToLower())"
}