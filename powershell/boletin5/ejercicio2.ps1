param (
    [Parameter(Mandatory=$true)]
    [string]$Dominio
)

# Importar módulo de AD si no está cargado
if (-not (Get-Module -ListAvailable ActiveDirectory)) {
    Write-Error "Este script requiere las herramientas de administración de Active Directory."
    return
}
# --- FUNCIONES DE ADMINISTRACIÓN ---

function New-ADUserCustom {
    param ([string]$Username, [string]$DomainName)
    try {
        $user = Get-ADUser -Identity $Username -ErrorAction SilentlyContinue
        if ($user) {
            $estado = if ($user.Enabled) { 
                "Habilitado" 
            } else { 
                "Deshabilitado" 
            }
            Write-Host "El usuario '$Username' ya existe y está $estado." -ForegroundColor Cyan
        } else {
            Write-Host "El usuario no existe. Creando..." -ForegroundColor Yellow
            
            # Configuración extraída de las imágenes
            $perfilPath = "\\wserverxx\perfiles\$Username"
            $homeDirectory = "\\wserver50\comun"
            
            New-ADUser -Name $Username `
                       -SamAccountName $Username `
                       -UserPrincipalName "$Username@$DomainName" `
                       -ProfilePath $perfilPath `
                       -HomeDirectory $homeDirectory `
                       -HomeDrive "Z:" `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true
            
            Write-Host "✅ Usuario '$Username' creado y habilitado correctamente." -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Error al crear usuario: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-ADGroupReport {
    param ([string]$GroupName)
    try {
        $group = Get-ADGroup -Identity $GroupName -Properties Members, GroupScope
        Write-Host "`nInformación del Grupo: $($group.Name)" -ForegroundColor Cyan
        Write-Host "Ámbito del grupo: $($group.GroupScope)"
        Write-Host "Miembros:"
        if ($group.Members.Count -eq 0) {
            Write-Host " - (El grupo está vacío)"
        } else {
            foreach ($memberDN in $group.Members) {
                $m = Get-ADObject -Identity $memberDN
                Write-Host " - $($m.Name) [$($m.ObjectClass)]"
            }
        }
    } catch {
        Write-Host "❌ Error: No se encontró el grupo '$GroupName'." -ForegroundColor Red
    }
}

function Add-ADUserToGroupCustom {
    param ([string]$Username, [string]$GroupName)
    try {
        $userObj = Get-ADUser -Identity $Username -Properties MemberOf
        $groupObj = Get-ADGroup -Identity $GroupName
        
        if ($userObj.MemberOf -contains $groupObj.DistinguishedName) {
            Write-Host "ℹ️ El usuario '$Username' ya es miembro de '$GroupName'." -ForegroundColor Cyan
        } else {
            Write-Host "El usuario no pertenece al grupo. Agregando..." -ForegroundColor Yellow
            Add-ADGroupMember -Identity $GroupName -Members $Username
            Write-Host "✅ Usuario '$Username' vinculado con éxito a '$GroupName'." -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Error: Verifique que el usuario y el grupo existan." -ForegroundColor Red
    }
}

function Mostrar-Menu {
    Clear-Host
    Write-Host "============================="
    Write-Host "  ADMINISTRACIÓN DEL DOMINIO: $($Dominio.ToUpper())"
    Write-Host "============================="
    Write-Host "A. Creación de usuarios de AD"
    Write-Host "B. Comprobación de grupo de AD"
    Write-Host "C. Pertenencia a grupo"
    Write-Host "S. Salir"
    Write-Host "-----------------------------"
}

do {
    Mostrar-Menu
    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        "A" {
            $user = Read-Host "Nombre del usuario a gestionar"
            New-ADUserCustom -Username $user -DomainName $Dominio
        }
        "B" {
            $group = Read-Host "Nombre del grupo a consultar"
            Get-ADGroupReport -GroupName $group
        }
        "C" {
            $user = Read-Host "Nombre del usuario"
            $group = Read-Host "Nombre del grupo"
            Add-ADUserToGroupCustom -Username $user -GroupName $group
        }
    }
    if ($opcion -ne "S") { Read-Host "`nPresione Enter para continuar..." }

} while ($opcion -ne "S")