# 1. Definimos el límite (n = número de clase)
$n = 15

# 2. Inicializamos la variable que guardará el resultado
$suma = 0

# 3. Utilizamos un bucle 'for' para recorrer los números del 1 al $n
for ($i = 1; $i -le $n; $i++) {
    $suma += $i
}

# 4. Mostramos el resultado final
Write-Host "La suma de los primeros $n números es: $suma" -ForegroundColor Cyan