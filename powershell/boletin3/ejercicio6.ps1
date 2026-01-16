# Definimos el número de clase
$nClase = 15

do {
    Clear-Host
    Write-Host "--- MENÚ DE TAREAS POWERSHELL (Clase: $nClase) ---" -ForegroundColor Cyan
    Write-Host "1. Comprobar si un número es mayor que mi número de clase"
    Write-Host "2. Sumar los primeros $nClase números"
    Write-Host "3. Sumar 3 números y comparar con (Clase + 100)"
    Write-Host "4. Ver contenido del directorio raíz (C:\)"
    Write-Host "5. Salir"
    
    $opcion = Read-Host "`nSelecciona una opción (1-5)"

    switch ($opcion) {
        "1" {
            $num = [int](Read-Host "Introduce un número")
            if ($num -gt $nClase) { Write-Host "Es mayor." -ForegroundColor Green } 
            else { Write-Host "No es mayor." -ForegroundColor Red }
        }
        "2" {
            $suma = 0
            for ($i=1; $i -le $nClase; $i++) { $suma += $i }
            Write-Host "La suma de los primeros $nClase números es: $suma" -ForegroundColor Yellow
        }
        "3" {
            $n1 = [int](Read-Host "Número 1")
            $n2 = [int](Read-Host "Número 2")
            $n3 = [int](Read-Host "Número 3")
            $total = $n1 + $n2 + $n3
            $objetivo = $nClase + 100
            if ($total -gt $objetivo) { Write-Host "Suma ($total) mayor que $objetivo" -ForegroundColor Green }
            else { Write-Host "Suma ($total) no supera el objetivo" -ForegroundColor Red }
        }
        "4" {
            Get-ChildItem -Path "C:\"
        }
        "5" {
            Write-Host "Saliendo del programa..." -ForegroundColor Magenta
            break
        }
        Default {
            Write-Host "Opción no válida, intenta de nuevo." -ForegroundColor DarkRed
        }
    }
    pause
} while ($opcion -ne "5")