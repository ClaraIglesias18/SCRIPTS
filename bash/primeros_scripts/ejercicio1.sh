#!/bin/bash

# 1. Verificar que se ha pasado exactamente un parámetro
if [ $# -ne 1 ]; then
    echo "Error: Uso incorrecto."
    echo "Sintaxis: $0 <nombre_del_fichero>"
    exit 1
else
    FICHERO=$1
    chmod +x "$FICHERO"
fi



# 2. Verificar si el archivo existe
#if [ ! -e "$FICHERO" ]; then
#    echo "Error: El archivo '$FICHERO' no existe."
#    exit 2
#fi
