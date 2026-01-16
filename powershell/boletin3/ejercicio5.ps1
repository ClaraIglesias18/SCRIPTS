# 1. Definimos las opciones válidas
# Si el carácter está en la posición 0 o 1, es un "SÍ"
# Si está en la 2 o 3, es un "NO"
$opciones = "SsNn"

$respuesta = Read-Host "¿Deseas ver el contenido del directorio raíz? (S/N)"

# 2. Buscamos la posición de la respuesta del usuario en nuestra cadena
$indice = $opciones.IndexOf($respuesta)

# 3. Estructura de control basada en el índice
if ($indice -eq 0 -or $indice -eq 1) {
    Write-Host "Has dicho que SÍ." -ForegroundColor Green
    Get-ChildItem -Path "C:\"
}
elseif ($indice -eq 2 -or $indice -eq 3) {
    Write-Host "Has dicho que NO." -ForegroundColor Yellow
}
else {
    Write-Host "Respuesta no reconocida. Por favor, usa S o N." -ForegroundColor Red
}