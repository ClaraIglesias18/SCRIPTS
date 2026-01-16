# 1. Importamos los datos directamente
# No usamos -Header porque ya están en la primera línea del archivo
$datos = Import-Csv -Path "profesores.txt" -Delimiter ";"

# 2. Recorremos los datos
foreach ($profe in $datos) {
    # Mostramos la frase usando las cabeceras del archivo original
    Write-Host "El profesor ""$($profe.nombre)"" ""$($profe.apellido)"" da clase en el ciclo ""$($profe.ciclo)""."
}