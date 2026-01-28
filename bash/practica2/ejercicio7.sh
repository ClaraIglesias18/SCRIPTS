#!/bin/bash

# 1. Control de errores: Verificar que se ha pasado el directorio como parámetro
if [ $# -ne 1 ]; then
    echo "Error: Uso incorrecto."
    echo "Uso: $0 <directorio>"
    exit 1
fi

DIRECTORIO=$1

# 2. Control de errores: Verificar si el parámetro es un directorio y existe
if [ ! -d "$DIRECTORIO" ]; then
    echo "Error: '$DIRECTORIO' no es un directorio válido o no existe."
    exit 2
fi

# 3. Solicitar el número de inicio del inodo al usuario
read -p "Introduce el número por el que debe comenzar el inodo: " NUMERO

# Validar que el usuario haya introducido un número
if [[ ! "$NUMERO" =~ ^[0-9]+$ ]]; then
    echo "Error: Debes introducir un número entero."
    exit 3
fi

# 4. Definir el nombre del fichero de salida (listaX)
FICHERO_SALIDA="lista$NUMERO"

echo "Buscando elementos en '$DIRECTORIO' cuyo inodo comience por $NUMERO..."

# 5. Obtener el listado y procesarlo
# ls -ai: lista todos los archivos incluyendo ocultos con su inodo
# awk: nos permite formatear la salida y filtrar por la primera columna (inodo)
# El patrón ^$NUMERO busca que el inodo empiece por ese número
ls -ai "$DIRECTORIO" | awk -v n="$NUMERO" '$1 ~ "^"n {print $1";"$2}' >> "$FICHERO_SALIDA"

# 6. Comprobar si se encontraron resultados
if [ $? -eq 0 ]; then
    echo "El proceso ha finalizado. Los resultados se han añadido a '$FICHERO_SALIDA'."
    echo "--- Últimas entradas de $FICHERO_SALIDA ---"
    tail -n 5 "$FICHERO_SALIDA"
else
    echo "No se encontraron coincidencias o hubo un problema al escribir el fichero."
fi