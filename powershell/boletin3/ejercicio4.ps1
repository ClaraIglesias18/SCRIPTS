# 1. Preguntamos al usuario (Guardamos la respuesta en $respuesta)
$respuesta = Read-Host "¿Deseas ver el contenido del directorio raíz (C:\)? (S/N)"

# 2. Sentencia selectiva
# Usamos -eq "S" para comparar. PowerShell no distingue mayúsculas por defecto.
if ($respuesta -eq "S") {
    Write-Host "`nMostrando el contenido de C:\ ...`n" -ForegroundColor Cyan
    Get-ChildItem -Path "C:\"
} 
elseif ($respuesta -eq "N") {
    Write-Host "`nOperación cancelada por el usuario." -ForegroundColor Yellow
} 
else {
    Write-Host "`nEntrada no válida. Por favor, escribe 'S' para Sí o 'N' para No." -ForegroundColor Red
}