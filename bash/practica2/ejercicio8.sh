#!/bin/bash

# 1. Definir el nombre del directorio de la papelera
DIRECTORIO_BASURA="$HOME/basura"

# 2. Crear el directorio si no existe
if [ ! -d "$DIRECTORIO_BASURA" ]; then
    mkdir -p "$DIRECTORIO_BASURA"
    echo "Directorio de basura creado en: $DIRECTORIO_BASURA"
fi

# 3. Pedir al usuario el número de días (n)
read -p "Introduce el número de días (n): " DIAS

# Validar que sea un número
if [[ ! "$DIAS" =~ ^[0-9]+$ ]]; then
    echo "Error: Por favor, introduce un número entero de días."
    exit 1
fi

echo "Buscando archivos modificados hace $DIAS días o más..."

# 4. Localizar y mover archivos
# -maxdepth 1: Para que no busque en subcarpetas del sistema, solo en la actual
# -type f: Solo ficheros (evita mover directorios enteros)
# -mtime +$DIAS: Modificados hace más de n días
# -not -path: Evita que el script intente mover la propia carpeta basura dentro de sí misma
find . -maxdepth 1 -type f -mtime +"$DIAS" -not -path "./basura/*" -exec mv {} "$DIRECTORIO_BASURA" \;

# 5. Informar del estado de la papelera
# Contamos los archivos dentro del directorio basura
NUM_ARCHIVOS=$(ls -1 "$DIRECTORIO_BASURA" | wc -l)

echo "------------------------------------------------"
echo "Proceso completado."
echo "Estado de la papelera ($DIRECTORIO_BASURA):"
echo "Actualmente contiene $NUM_ARCHIVOS archivo(s)."
echo "------------------------------------------------"