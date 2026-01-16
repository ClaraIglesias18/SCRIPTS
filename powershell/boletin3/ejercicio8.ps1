# 1. Definimos la ruta del archivo
$archivo = "dnis.txt"

# Mensaje inicial
Write-Host "--- Registro de DNIs ---" -ForegroundColor Cyan
Write-Host "Escribe 'fin' para terminar de introducir datos.`n"

do {
    # 2. Solicitar el DNI
    $entrada = Read-Host "Introduce un DNI"

    # 3. Comprobar si el usuario quiere salir
    if ($entrada -ne "fin" -and -not [string]::IsNullOrWhiteSpace($entrada)) {
        
        # 4. Guardar en el fichero. 
        # -Append es fundamental para no borrar lo que ya existe.
        $entrada | Out-File -FilePath $archivo -Append -Encoding utf8
        
        Write-Host "DNI '$entrada' guardado correctamente." -ForegroundColor Green
    }

} while ($entrada -ne "fin")

Write-Host "`nProceso finalizado. Los datos están en $archivo" -ForegroundColor Yellow