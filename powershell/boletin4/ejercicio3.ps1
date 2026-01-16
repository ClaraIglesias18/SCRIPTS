# 1. Importar módulos y pedir el patrón
Import-Module ActiveDirectory
$patron = Read-Host "Introduce el patrón para los usuarios (ej: alu o usr)"
$rutaBaseCarpeta = "C:\usuarios" # Cambia esto por tu ruta real

# 2. Crear la carpeta base y el grupo del patrón
if (-not (Test-Path $rutaBaseCarpeta)) { New-Item -Path $rutaBaseCarpeta -ItemType Directory }

if (-not (Get-ADGroup -Filter "Name -eq '$patron'")) {
    New-ADGroup -Name $patron -SamAccountName $patron -GroupCategory Security -GroupScope Global
    Write-Host "Grupo '$patron' creado." -ForegroundColor Cyan
}

# 3. Leer el fichero y procesar usuarios
# Asumimos que el CSV tiene cabecera: Num,nombre,apellido1,apellido2
$usuarios = Import-Csv -Path "usuarios.txt" -Delimiter ","

foreach ($linea in $usuarios) {
    # Generar el SAMAccountName (ej: alu01)
    $samName = $patron + $linea.Num
    $nombreCompleto = "$($linea.nombre) $($linea.apellido1) $($linea.apellido2)"
    $rutaUsuario = Join-Path $rutaBaseCarpeta $samName

    try {
        # 4. Crear el Usuario en AD
        # Definimos la HomeDirectory (Carpeta Personal)
        New-ADUser -Name $samName `
                   -SamAccountName $samName `
                   -DisplayName $nombreCompleto `
                   -Enabled $true `
                   -HomeDirectory $rutaUsuario `
                   -HomeDrive "Z:" `
                   -ErrorAction Stop

        # 5. Añadir al grupo
        Add-ADGroupMember -Identity $patron -Members $samName

        # 6. Crear carpeta física y asignar permisos
        if (-not (Test-Path $rutaUsuario)) {
            New-Item -Path $rutaUsuario -ItemType Directory
            # Otorgar control total al usuario en su propia carpeta
            $acl = Get-Acl $rutaUsuario
            $permiso = New-Object System.Security.AccessControl.FileSystemAccessRule($samName, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
            $acl.SetAccessRule($permiso)
            Set-Acl $rutaUsuario $acl
        }

        Write-Host "Usuario $samName creado y carpeta configurada." -ForegroundColor Green
    } catch {
        Write-Host "Error con el usuario $samName : $($_.Exception.Message)" -ForegroundColor Red
    }
}