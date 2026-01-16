# 1. Solicitar el nombre del proceso
$nombreProceso = Read-Host "Introduce el nombre del proceso (ej: notepad, chrome, msedge)"

# 2. Intentar obtener el proceso
# ErrorAction SilentlyContinue evita que salga un mensaje rojo feo si no lo encuentra
$proceso = Get-Process -Name $nombreProceso -ErrorAction SilentlyContinue

if ($proceso) {
    Write-Host "Confirmado: El proceso '$nombreProceso' se está ejecutando." -ForegroundColor Green
    
    # 3. Preguntar si desea finalizarlo
    $confirmacion = Read-Host "¿Deseas finalizar el proceso? (S/N)"
    
    if ($confirmacion -eq "S") {
        Stop-Process -Name $nombreProceso -Force
        Write-Host "El proceso '$nombreProceso' ha sido finalizado con éxito." -ForegroundColor Cyan
    } else {
        Write-Host "Operación cancelada. El proceso sigue en ejecución." -ForegroundColor Yellow
    }
} 
else {
    Write-Host "El proceso '$nombreProceso' NO se está ejecutando actualmente." -ForegroundColor Red
}