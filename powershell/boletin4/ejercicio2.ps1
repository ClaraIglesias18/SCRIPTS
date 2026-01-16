# Importar el módulo de AD
Import-Module ActiveDirectory

do {
    Clear-Host
    Write-Host "--- PANEL DE CONTROL AD ---" -ForegroundColor Cyan
    Write-Host "A. Encontrar un equipo"
    Write-Host "B. Eliminar usuario"
    Write-Host "C. Consultar grupos"
    Write-Host "D. Salir"
    
    $opcion = Read-Host "`nSelecciona una opción (A-D)"

    switch ($opcion.ToUpper()) {
        "A" {
            $nombreEquipo = Read-Host "Introduce el nombre del equipo a buscar"
            $equipo = Get-ADComputer -Filter "Name -eq '$nombreEquipo'" -ErrorAction SilentlyContinue
            
            if ($equipo) {
                Write-Host "Aviso: El equipo '$nombreEquipo' ya existe en el dominio." -ForegroundColor Yellow
            } else {
                Write-Host "El equipo no existe. Procediendo a crearlo..." -ForegroundColor Gray
                New-ADComputer -Name $nombreEquipo -SamAccountName $nombreEquipo
                Write-Host "Equipo '$nombreEquipo' creado con éxito." -ForegroundColor Green
            }
        }
        
        "B" {
            $nombreUser = Read-Host "Introduce el SamAccountName del usuario a eliminar"
            $usuario = Get-ADUser -Filter "SamAccountName -eq '$nombreUser'" -ErrorAction SilentlyContinue
            
            if ($usuario) {
                Remove-ADUser -Identity $nombreUser -Confirm:$false
                Write-Host "El usuario '$nombreUser' ha sido eliminado." -ForegroundColor Green
            } else {
                Write-Host "Error: El usuario '$nombreUser' no existe." -ForegroundColor Red
            }
        }
        
        "C" {
            Write-Host "`nListado de grupos del dominio:" -ForegroundColor Magenta
            Get-ADGroup -Filter * | Select-Object Name, GroupCategory, GroupScope | Format-Table
        }

        "D" {
            Write-Host "Cerrando sesión..." -ForegroundColor Cyan
        }

        Default {
            Write-Host "Opción no válida. Por favor, selecciona A, B, C o D." -ForegroundColor Red
        }
    }
    
    if ($opcion.ToUpper() -ne "D") {
        pause
    }

} while ($opcion.ToUpper() -ne "D")