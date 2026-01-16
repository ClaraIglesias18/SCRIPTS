# Comprobamos que se han pasado los dos parámetros necesarios
param(
    [Parameter(Mandatory=$true)] [string]$fichero,
    [Parameter(Mandatory=$true)] [string]$uoPadreNombre
)

Import-Module ActiveDirectory

# 1. Obtener el Distinguished Name del dominio y la ruta de la UO padre
try {
    $dominioDN = (Get-ADDomain).DistinguishedName
    $targetOU = Get-ADOrganizationalUnit -Filter "Name -eq '$uoPadreNombre'" -ErrorAction Stop
    $padrePath = $targetOU.DistinguishedName
} catch {
    Write-Host "Error: No se encontró la UO padre '$uoPadreNombre' en el dominio." -ForegroundColor Red
    exit
}

# 2. Leer el fichero
if (-not (Test-Path $fichero)) {
    Write-Host "Error: El archivo '$fichero' no existe." -ForegroundColor Red
    exit
}

$lineas = Get-Content $fichero

foreach ($linea in $lineas) {
    if ([string]::IsNullOrWhiteSpace($linea)) { continue }

    # Separamos por punto y coma
    $partes = $linea.Split(";")
    $nombreOUPrincipal = $partes[0].Trim()

    try {
        # Crear la OU de nivel 1 (ALUMNOS, AULAS, etc.)
        $currentOUPath = "OU=$nombreOUPrincipal,$padrePath"
        if (-not (Get-ADOrganizationalUnit -Identity $currentOUPath -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $nombreOUPrincipal -Path $padrePath -ErrorAction Stop
            Write-Host "Creada OU: $nombreOUPrincipal" -ForegroundColor Green
        }

        # Crear las sub-OUs (DIURNO, NOCTURNO, etc.)
        for ($i = 1; $i -lt $partes.Count; $i++) {
            $subOU = $partes[$i].Trim()
            if (-not [string]::IsNullOrEmpty($subOU)) {
                $subPath = "OU=$subOU,$currentOUPath"
                if (-not (Get-ADOrganizationalUnit -Identity $subPath -ErrorAction SilentlyContinue)) {
                    New-ADOrganizationalUnit -Name $subOU -Path $currentOUPath -ErrorAction Stop
                    Write-Host "  -> Creada Sub-OU: $subOU" -ForegroundColor Gray
                }
            }
        }
    } catch {
        Write-Host "Error al procesar la línea '$nombreOUPrincipal': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3. Mostrar la estructura final por pantalla
Write-Host "`n--- ESTRUCTURA FINAL EN $uoPadreNombre ---" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * -SearchBase $padrePath | Select-Object Name, DistinguishedName | Sort-Object DistinguishedName | Format-Table