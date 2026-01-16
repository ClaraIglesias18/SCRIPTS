# 1. Definimos la ruta del directorio (asegúrate de que la carpeta existe)
$ruta = ".\examen"

# 2. Obtenemos los archivos y aplicamos el renombrado
# Get-ChildItem lista los archivos
# Rename-Item cambia el nombre
Get-ChildItem -Path $ruta -File | ForEach-Object {
    
    # Creamos el nuevo nombre reemplazando la palabra
    $nuevoNombre = $_.Name -replace "examen", "control"
    
    # Renombramos el archivo actual ($_)
    Rename-Item -Path $_.FullName -NewName $nuevoNombre
}

Write-Host "Proceso de renombrado finalizado en la carpeta $ruta." -ForegroundColor Green