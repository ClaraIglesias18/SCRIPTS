# 1. Preparación e Importación de Módulo
Import-Module ActiveDirectory

try {
    # 2. Creación de la Unidad Organizativa
    $nombreOU = Read-Host "Introduce el nombre para la nueva Unidad Organizativa"
    $dominioDN = (Get-ADDomain).DistinguishedName
    $ouPath = "OU=$nombreOU,$dominioDN"

    if (-not (Get-ADOrganizationalUnit -Identity $ouPath -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $nombreOU -Path $dominioDN -ErrorAction Stop
        Write-Host "OU '$nombreOU' creada correctamente." -ForegroundColor Green
    }

    # 3. Creación del Grupo "distancia"
    $grupoNombre = "distancia"
    if (-not (Get-ADGroup -Filter "Name -eq '$grupoNombre'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $grupoNombre -SamAccountName $grupoNombre -Path $ouPath `
                    -GroupCategory Security -GroupScope Global `
                    -Description "grupo de distancia" -ErrorAction Stop
        Write-Host "Grupo 'distancia' creado dentro de la OU." -ForegroundColor Cyan
    }

    # 4. Procesamiento de Usuarios desde el Fichero
    $fichero = "datos.txt" # El archivo con formato alvaro,martinez
    if (-not (Test-Path $fichero)) { throw "El archivo $fichero no existe." }

    $usuariosProcesados = Get-Content $fichero
    $contadorCreados = 0

    foreach ($linea in $usuariosProcesados) {
        if ([string]::IsNullOrWhiteSpace($linea)) { continue }

        # Separar nombre y apellido
        $datos = $linea.Split(",")
        $nombre = $datos[0].Trim()
        $apellido = $datos[1].Trim()

        # Generar Login: inicial del nombre + apellido (ej: amartinez)
        $login = ($nombre.Substring(0,1) + $apellido).ToLower()
        
        # Preguntar si se desea deshabilitar
        $pregunta = Read-Host "¿Deseas crear a $nombre $apellido ($login) como DESHABILITADO? (S/N)"
        $estado = $true
        if ($pregunta.ToUpper() -eq "S") { $estado = $false }

        # Crear Usuario
        # Contraseña igual al nombre, convertida a SecureString
        $securePass = ConvertTo-SecureString $nombre -AsPlainText -Force
        
        try {
            New-ADUser -Name "$nombre $apellido" `
                       -SamAccountName $login `
                       -GivenName $nombre `
                       -Surname $apellido `
                       -Path $ouPath `
                       -Enabled $estado `
                       -AccountPassword $securePass `
                       -ChangePasswordAtLogon $true `
                       -ErrorAction Stop
            
            $contadorCreados++

            # 5. Añadir al grupo si NO está deshabilitado
            if ($estado -eq $true) {
                Add-ADGroupMember -Identity $grupoNombre -Members $login -ErrorAction Stop
            }
        } catch {
            Write-Host "Error al crear a $login: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # 6. Informar y Listar
    Write-Host "`nSe han creado correctamente $contadorCreados usuarios." -ForegroundColor Yellow
    
    Write-Host "`n--- LISTADO DE USUARIOS EN OU: $nombreOU ---" -ForegroundColor Cyan
    Get-ADUser -Filter * -SearchBase $ouPath | Select-Object Name, SamAccountName, Enabled | Format-Table

} catch {
    Write-Host "Se produjo un error crítico: $($_.Exception.Message)" -ForegroundColor Red
}