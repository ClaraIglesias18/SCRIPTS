#!/bin/bash

# Definimos los nombres de lo que queremos buscar
FICHERO="datos"
CARPETA="informes"

echo "--- Verificación de Existencia ---"

# 1. Comprobar si el fichero 'datos' existe
# El operador -f verifica si es un fichero regular
if [ -f "$FICHERO" ]; then
    echo "Fichero: El archivo '$FICHERO' existe correctamente."
else
    echo "Fichero: El archivo '$FICHERO' NO existe."
fi

# 2. Comprobar si la carpeta 'informes' existe
# El operador -d verifica si es un directorio
if [ -d "$CARPETA" ]; then
    echo "Carpeta: El directorio '$CARPETA' existe correctamente."
else
    echo "Carpeta: El directorio '$CARPETA' NO existe."
fi

echo "----------------------------------"