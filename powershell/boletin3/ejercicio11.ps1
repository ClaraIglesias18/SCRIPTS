# 1. Importar el módulo de Active Directory
Import-Module ActiveDirectory

# 2. Solicitar datos al usuario
$nombreOU = Read-Host "Nombre para la Unidad Organizativa"
$nombreUsuario = Read-Host "Nombre del usuario (samAccountName)"
$nombreGrupo = Read-Host "Nombre del grupo"

# Obtener el Distinguished Name (DN) del dominio automáticamente
$dominioDN = (Get-ADDomain).DistinguishedName

# 3. Crear la Unidad Organizativa (OU)
try {
    $ouPath = "OU=$nombreOU,$dominioDN"
    New-ADOrganizationalUnit -Name $nombreOU -Path $dominioDN -ErrorAction Stop
    Write-Host "OU creada correctamente: $ouPath" -ForegroundColor Green

    # 4. Crear el Usuario dentro de la OU
    New-ADUser -Name $nombreUsuario -SamAccountName $nombreUsuario -Path $ouPath -Enabled $true -ErrorAction Stop
    Write-Host "Usuario '$nombreUsuario' creado correctamente." -ForegroundColor Green

    # 5. Crear el Grupo dentro de la OU
    New-ADGroup -Name $nombreGrupo -SamAccountName $nombreGrupo -Path $ouPath -GroupCategory Security -GroupScope Global -ErrorAction Stop
    Write-Host "Grupo '$nombreGrupo' creado correctamente." -ForegroundColor Green

    # 6. Agregar Usuario al Grupo
    Add-ADGroupMember -Identity $nombreGrupo -Members $nombreUsuario -ErrorAction Stop
    Write-Host "Usuario agregado al grupo con éxito." -ForegroundColor Green

} catch {
    Write-Host "Error en la creación de objetos: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Consulta final de los elementos creados
Write-Host "`n--- RESUMEN DE ELEMENTOS EN AD ---" -ForegroundColor Cyan
Get-ADObject -Filter "DistinguishedName -like '*$nombreOU*'" -SearchBase $ouPath | Select-Object Name, ObjectClass, DistinguishedName | Format-Table