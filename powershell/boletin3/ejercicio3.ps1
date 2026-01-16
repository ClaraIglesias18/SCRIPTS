# 1. Definimos las variables base
$numeroClase = 15
$objetivo = $numeroClase + 100

Write-Host "--- Comparador de Suma vs Objetivo ($objetivo) ---" -ForegroundColor Magenta

# 2. Solicitamos los 3 números al usuario
$n1 = [int](Read-Host "Introduce el primer número")
$n2 = [int](Read-Host "Introduce el segundo número")
$n3 = [int](Read-Host "Introduce el tercer número")

# 3. Calculamos la suma
$sumaTotal = $n1 + $n2 + $n3

Write-Host "`nLa suma total es: $sumaTotal"

# 4. Comprobamos si es mayor que el objetivo (clase + 100)
if ($sumaTotal -gt $objetivo) {
    Write-Host "¡Resultado positivo! $sumaTotal es MAYOR que $objetivo." -ForegroundColor Green
} else {
    Write-Host "Resultado negativo: $sumaTotal NO es mayor que $objetivo." -ForegroundColor Red
}