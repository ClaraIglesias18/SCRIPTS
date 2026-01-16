# Comprobar si se han pasado usuarios como parámetros
if ($args.Count -eq 0) {
    Write-Host "Error: Debes pasar al menos un nombre de usuario como parámetro." -ForegroundColor Red
    Write-Host "Ejemplo: .\script.ps1 usuario1 usuario2"
    exit
}

Import-Module ActiveDirectory

try {
    $dominioDN = (Get-ADDomain).DistinguishedName
    
    # 1. Creación de la jerarquía de Unidades Organizativas
    # Estructura: Usuarios -> Profesores / Alumnos -> ASIR1 / ASIR2
    $uoEstructura = @(
        "OU=Usuarios,$dominioDN",
        "OU=Profesores,OU=Usuarios,$dominioDN",
        "OU=Alumnos,OU=Usuarios,$dominioDN",
        "OU=ASIR1,OU=Alumnos,OU=Usuarios,$dominioDN",
        "OU=ASIR2,OU=Alumnos,OU=Usuarios,$dominioDN"
    )

    foreach ($path in $uoEstructura) {
        $nombreOU = ($path -split ",")[0].Replace("OU=","")
        $parentPath = ($path -split ",",2)[1]
        
        if (-not (Get-ADOrganizationalUnit -Identity $path -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $nombreOU -Path $parentPath -ErrorAction Stop
            Write-Host "Creada OU: $nombreOU" -ForegroundColor Cyan
        }
    }

    # 2. Creación de Grupos
    $grupos = @{
        "G_Profesores" = "Grupo de profesores";
        "G_ASIR"       = "Grupo de ASIR"
    }

    foreach ($grp in $grupos.Keys) {
        if (-not (Get-ADGroup -Filter "Name -eq '$grp'" -ErrorAction SilentlyContinue)) {
            $pathGrp = if ($grp -eq "G_Profesores") { "OU=Profesores,OU=Usuarios,$dominioDN" } else { "OU=Alumnos,OU=Usuarios,$dominioDN" }
            New-ADGroup -Name $grp -SamAccountName $grp -Path $pathGrp -GroupCategory Security -GroupScope Global -Description $grupos[$grp]
        }
    }

    # 3. Procesamiento de usuarios pasados por parámetro
    $usuariosCreados = 0

    foreach ($user in $args) {
        Write-Host "`n--- Configurando usuario: $user ---" -ForegroundColor Yellow
        
        # Determinar destino
        $tipo = Read-Host "¿Es (P)rofesor o (A)lumno?"
        $destOU = ""
        $grupoDestino = ""

        if ($tipo.ToUpper() -eq "P") {
            $destOU = "OU=Profesores,OU=Usuarios,$dominioDN"
            $grupoDestino = "G_Profesores"
        } else {
            $curso = Read-Host "¿Pertenece a ASIR1 o ASIR2? (Indica 1 o 2)"
            $destOU = "OU=ASIR$curso,OU=Alumnos,OU=Usuarios,$dominioDN"
            $grupoDestino = "G_ASIR"
        }

        # Preguntar estado
        $deshabilitar = Read-Host "¿Deseas crear el usuario deshabilitado? (S/N)"
        $enabled = if ($deshabilitar.ToUpper() -eq "S") { $false } else { $true }

        # Contraseña igual al nombre de usuario
        $securePass = ConvertTo-SecureString $user -AsPlainText -Force

        try {
            New-ADUser -Name $user -SamAccountName $user -Path $destOU `
                       -AccountPassword $securePass -Enabled $enabled `
                       -ChangePasswordAtLogon $true -ErrorAction Stop
            
            Add-ADGroupMember -Identity $grupoDestino -Members $user
            $usuariosCreados++
            Write-Host "Usuario '$user' creado correctamente en su UO y añadido a $grupoDestino." -ForegroundColor Green
        } catch {
            Write-Host "Error al crear el usuario $user: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # 4. Informe de creación
    Write-Host "`nTotal de usuarios creados en esta sesión: $usuariosCreados" -ForegroundColor White -BackgroundColor DarkGreen

    # 5. Listado de una UO específica
    Write-Host "`n--- Consulta de Usuarios ---"
    $uoConsulta = Read-Host "Introduce el nombre de la OU para listar sus usuarios (Profesores, ASIR1, ASIR2)"
    
    $uoEncontrada = Get-ADOrganizationalUnit -Filter "Name -eq '$uoConsulta'" 
    if ($uoEncontrada) {
        Write-Host "Listando usuarios en $($uoEncontrada.Name):" -ForegroundColor Cyan
        Get-ADUser -Filter * -SearchBase $uoEncontrada.DistinguishedName | Select-Object Name, SamAccountName, Enabled | Format-Table
    } else {
        Write-Host "La OU especificada no existe." -ForegroundColor Red
    }

} catch {
    Write-Host "Error crítico en el script: $($_.Exception.Message)" -ForegroundColor Red
}