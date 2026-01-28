#!/bin/bash

# 1. Control de errores inicial: Verificar parámetros
if [ $# -ne 2 ]; then
    echo "Error: Uso incorrecto."
    echo "Uso: $0 <directorio_origen> <directorio_destino>"
    exit 1
fi

DIR_ORIGEN=$1
DIR_DESTINO=$2
INFO_FILE="inf.txt"

# 2. Comprobar si el primer parámetro es un directorio válido
if [ ! -d "$DIR_ORIGEN" ]; then
    echo "Error: El directorio de origen '$DIR_ORIGEN' no existe."
    exit 2
fi

# 3. Creación del fichero inf.txt con los encabezados requeridos
FECHA=$(date +"%d/%m/%Y")
HORA=$(date +"%H:%M")

echo "Fichero creado el día $FECHA a la hora $HORA por el usuario $USER" > "$INFO_FILE"
echo "Lista de los ficheros del directorio raíz" >> "$INFO_FILE"
echo "----------------------------------------" >> "$INFO_FILE"

# Listado simple de archivos del directorio pasado como parámetro
ls -1 "$DIR_ORIGEN" >> "$INFO_FILE"

echo "----------------------------------------" >> "$INFO_FILE"
# Contar el número de archivos (usamos ls -1 y wc -l)
NUM_FICH=$(ls -1 "$DIR_ORIGEN" | wc -l)
echo "Número de los ficheros del directorio raíz: $NUM_FICH" >> "$INFO_FILE"

echo "Informe $INFO_FILE generado con éxito."

# 4. Menú interactivo
OPCION=""
while [ "$OPCION" != "C" ] && [ "$OPCION" != "c" ]; do
    echo -e "\n--- MENÚ DE OPCIONES ---"
    echo "M) Mostrar contenido de inf.txt"
    echo "B) Copiar inf.txt a la carpeta destino"
    echo "C) Salir"
    read -p "Elige una opción: " OPCION

    case $OPCION in
        [Mm])
            echo -e "\n--- Contenido de $INFO_FILE ---"
            cat "$INFO_FILE"
            ;;
        [Bb])
            # Comprobar si el directorio destino existe
            if [ -d "$DIR_DESTINO" ]; then
                cp "$INFO_FILE" "$DIR_DESTINO/"
                echo "Fichero copiado correctamente a $DIR_DESTINO"
            else
                echo "Error: El directorio destino '$DIR_DESTINO' no existe."
            fi
            ;;
        [Cc])
            echo "Saliendo del script..."
            ;;
        *)
            echo "Opción no válida, intenta de nuevo."
            ;;
    esac
done