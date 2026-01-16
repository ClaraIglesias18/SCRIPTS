# 1. Preparación del entorno
Import-Module ActiveDirectory
$dominioDN = (Get-ADDomain).DistinguishedName
$ouExamen = "OU=examen,$dominioDN"

# Verificar si la OU 'examen' existe, si no, crearla
if (-not (Get-ADOrganizationalUnit -Identity $ouExamen -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "examen" -Path $dominioDN
    Write-Host "OU 'examen' creada automáticamente." -ForegroundColor Gray
}

$continuar = "S"

# 2. Bucle principal
while ($continuar -eq "S") {
    Clear-Host
    Write-Host "--- CREADOR DE OBJETOS EN OU EXAMEN ---" -ForegroundColor Cyan
    Write-Host "1. Unidad Organizativa (OU)"
    Write-Host "2. Usuario"
    Write-Host "3. Equipo (Computer)"
    
    $opcion = Read-Host "`n¿Qué tipo de objeto deseas crear? (1-3)"
    $nombre = Read-Host "Introduce el nombre para el nuevo objeto"

    try {
        switch ($opcion) {
            "1" {
                New-ADOrganizationalUnit -Name $nombre -Path $ouExamen -ErrorAction Stop
                Write-Host "OU '$nombre' creada con éxito." -ForegroundColor Green
            }
            "2" {
                New-ADUser -Name $nombre -SamAccountName $nombre -Path $ouExamen -Enabled $true -ErrorAction Stop
                Write-Host "Usuario '$nombre' creado con éxito." -ForegroundColor Green
            }
            "3" {
                New-ADComputer -Name $nombre -SamAccountName $nombre -Path $ouExamen -ErrorAction Stop
                Write-Host "Equipo '$nombre' creado con éxito." -ForegroundColor Green
            }
            Default { Write-Host "Opción no válida." -ForegroundColor Red }
        }
    } catch {
        Write-Host "Error al crear el objeto: $($_.Exception.Message)" -ForegroundColor Red
    }

    $continuar = Read-Host "`n¿Deseas crear otro objeto? (S/N)"
}

# 3. Consultas finales por tipo
Write-Host "`n--- INICIANDO CONSULTA DE ELEMENTOS CREADOS ---" -ForegroundColor Yellow

Write-Host "`n> Visualizando UNIDADES ORGANIZATIVAS dentro de 'examen':" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * -SearchBase $ouExamen | Select-Object Name, DistinguishedName | Format-Table

Write-Host "> Visualizando USUARIOS dentro de 'examen':" -ForegroundColor Cyan
Get-ADUser -Filter * -SearchBase $ouExamen | Select-Object Name, SamAccountName | Format-Table

Write-Host "> Visualizando EQUIPOS dentro de 'examen':" -ForegroundColor Cyan
Get-ADComputer -Filter * -SearchBase $ouExamen | Select-Object Name, SamAccountName | Format-Table