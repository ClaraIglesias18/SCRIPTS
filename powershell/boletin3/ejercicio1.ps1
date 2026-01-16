# 1. Definimos el número de clase (Cámbialo por el tuyo)
$numeroClase = 15

# 2. Pedimos el número al usuario y lo convertimos a entero [int]
$entrada = Read-Host "Introduce un número para comparar"
$numeroUsuario = [int]$entrada

# 3. Lógica de comparación
if ($numeroUsuario -gt $numeroClase) {
    Write-Host "El número $numeroUsuario es MAYOR que tu número de clase ($numeroClase)." -ForegroundColor Green
} 
elseif ($numeroUsuario -eq $numeroClase) {
    Write-Host "El número es IGUAL a tu número de clase ($numeroClase)." -ForegroundColor Yellow
}
else {
    Write-Host "El número $numeroUsuario NO es mayor que tu número de clase ($numeroClase)." -ForegroundColor Red
}