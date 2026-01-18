param (
    [Parameter(Mandatory=$true)]
    [string]$Delegacion, # Nombre de la UO principal

    [Parameter(Mandatory=$true)]
    [string]$Fichero     # Ruta al archivo .txt con los datos
)

# --- COMPROBACIONES PREVIAS ---
if (-not (Test-Path $Fichero)) {
    Write-Error "El archivo '$Fichero' no existe."
    return
}

# 1. Crear la UO de la Delegación si no existe
$dominoDN = (Get-ADDomain).DistinguishedName
$delegacionDN = "OU=$Delegacion,$dominoDN"

if (-not (Get-ADOrganizationalUnit -Identity $delegacionDN -ErrorAction SilentlyContinue)) {
    try {
        New-ADOrganizationalUnit -Name $Delegacion -Path $dominoDN
        Write-Host "✅ Unidad Organizativa '$Delegacion' creada." -ForegroundColor Green
    } catch {
        Write-Error "No se pudo crear la UO: $($_.Exception.Message)"
        return
    }
}

# 2. Procesar el fichero (Saltando las 2 líneas de título y decorador)
# Formato esperado: Usuario,UO,grupo,descripcion
$usuariosData = Get-Content $Fichero | Select-Object -Skip 2 | ConvertFrom-Csv -Header "Usuario","SubUO","Grupo","Descripcion"

$contadorExito = 0

foreach ($linea in $usuariosData) {
    try {
        # Definir rutas y UO específica (SubUO dentro de Delegación)
        $subUODN = "OU=$($linea.SubUO),$delegacionDN"
        
        # Crear Sub-UO si no existe
        if (-not (Get-ADOrganizationalUnit -Identity $subUODN -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $linea.SubUO -Path $delegacionDN
        }

        # Configurar contraseña segura y carpeta personal
        $password = ConvertTo-SecureString "abc123." -AsPlainText -Force
        $homeDir = "\\serverxx\comun\$($linea.Usuario)"

        # Crear Usuario
        New-ADUser -Name $linea.Usuario `
                   -SamAccountName $linea.Usuario `
                   -Path $subUODN `
                   -Description $linea.Descripcion `
                   -AccountPassword $password `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true `
                   -HomeDirectory $homeDir `
                   -HomeDrive "Z:"

        # Crear Grupo si no existe y añadir usuario
        if (-not (Get-ADGroup -Identity $linea.Grupo -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $linea.Grupo -Path $delegacionDN -GroupScope Global -GroupCategory Security
        }
        Add-ADGroupMember -Identity $linea.Grupo -Members $linea.Usuario     

        $contadorExito++
        Write-Host "Usuario '$($linea.Usuario)' procesado correctamente." -ForegroundColor Gray

    } catch {
        Write-Host "❌ Error al procesar '$($linea.Usuario)': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- INFORMES FINALES ---
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE OPERACIÓN"
Write-Host "Total de usuarios creados con éxito: $contadorExito" -ForegroundColor Green

# Informe de miembros de un grupo solicitado
$grupoConsulta = Read-Host "`nIntroduzca el nombre de un grupo para ver sus miembros"
try {
    $miembros = Get-ADGroupMember -Identity $grupoConsulta
    Write-Host "El grupo '$grupoConsulta' tiene $($miembros.Count) miembros." -ForegroundColor Yellow
} catch {
    Write-Host "El grupo '$grupoConsulta' no existe o no tiene miembros." -ForegroundColor Red
}