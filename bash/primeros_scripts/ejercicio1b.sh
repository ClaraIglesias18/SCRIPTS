#!/bin/bash

# 1. Solicitar el nombre del fichero al usuario
read -p "Introduce el nombre del fichero para darle permisos de ejecución: " FICHERO

# 2. Controlar que el nombre no esté vacío
# -z comperuba que si la cadena esta vacia
if [ -z "$FICHERO" ]; then
    echo "Error: No has introducido ningún nombre."
    exit 1
else
    # 4. Dar permisos de ejecución
    chmod +x "$FICHERO"
fi