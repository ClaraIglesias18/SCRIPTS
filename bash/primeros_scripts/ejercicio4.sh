#!/bin/bash

# 1. Controlar que se pase el nombre del grupo como parámetro
if [ $# -ne 1 ]; then
    echo "Error: Debes introducir el nombre de un grupo."
    echo "Uso: $0 <nombre_del_grupo>"
    exit 1
fi

GRUPO=$1

# 2. Extraer la línea del grupo de /etc/group
LINEA=$(grep "^$GRUPO:" /etc/group)

# 3. Verificar si el grupo existe
if [ -z "$LINEA" ]; then
    echo "Error: El grupo '$GRUPO' no existe en el sistema."
    exit 2
fi

# 4. Extraer la información usando 'cut'
# El formato de /etc/group es: nombre:contraseña:GID:miembros
NOMBRE=$(echo "$LINEA" | cut -d: -f1)
GID=$(echo "$LINEA" | cut -d: -f3)
MIEMBROS=$(echo "$LINEA" | cut -d: -f4)

# 5. Contar el número de miembros
if [ -z "$MIEMBROS" ]; then
    NUM_MIEMBROS=0
    LISTA_MIEMBROS="(Ninguno)"
else
    # Contamos las comas y sumamos 1 para saber cuántos usuarios hay
    NUM_MIEMBROS=$(echo "$MIEMBROS" | tr ',' '\n' | wc -l)
    LISTA_MIEMBROS=$MIEMBROS
fi

# 6. Mostrar los resultados
echo "Información del grupo:"
echo "---------------------------"
echo "Nombre del grupo:   $NOMBRE"
echo "Número del grupo:   $GID"
echo "Lista de miembros:  $LISTA_MIEMBROS"
echo "Número de miembros: $NUM_MIEMBROS"