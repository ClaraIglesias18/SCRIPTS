#!/bin/bash

# 1. Control de errores inicial: Verificar que se pasa un parámetro
if [ $# -ne 1 ]; then
    echo "Error: Uso incorrecto."
    echo "Uso: $0 <nombre_del_fichero>"
    exit 1
fi

FICHERO=$1
DIR_OLD="OLD"
CONTADOR_OPC3=0

# 2. Comprobar si el fichero existe antes de operar
if [ ! -f "$FICHERO" ]; then
    echo "Error: El fichero '$FICHERO' no existe o no es un fichero regular."
    exit 2
fi

# 3. Gestión del directorio OLD
if [ ! -d "$DIR_OLD" ]; then
    echo "Creando el directorio $DIR_OLD..."
    mkdir "$DIR_OLD"
fi

# 4. Copiar y borrar el fichero original
cp "$FICHERO" "$DIR_OLD/"
if [ $? -eq 0 ]; then
    rm "$FICHERO"
    echo "El fichero '$FICHERO' se ha movido a $DIR_OLD."
else
    echo "Error crítico: No se pudo copiar el fichero. Operación abortada."
    exit 3
fi

# 5. Menú interactivo
OPCION=0
while [ "$OPCION" -ne 4 ]; do
    echo -e "\n--- MENÚ DE GESTIÓN ---"
    echo "1._ Mostrar directorios"
    echo "2._ Informar ficheros"
    echo "3._ Eliminar temporales"
    echo "4._ Salir"
    read -p "Elige una opción: " OPCION

    case $OPCION in
        1)
            echo "Listado de directorios dentro de $DIR_OLD:"
            # Listamos solo los directorios (-d */)
            (cd "$DIR_OLD" && ls -d */ 2>/dev/null || echo "No hay subdirectorios.")
            ;;
        2)
            # Contar solo ficheros (excluyendo carpetas)
            NUM_FICH=$(find "$DIR_OLD" -maxdepth 1 -type f | wc -l)
            echo "El directorio $DIR_OLD contiene $NUM_FICH fichero(s)."
            ;;
        3)
            echo "Eliminando ficheros .tmp en $DIR_OLD y subcarpetas..."
            # find busca de forma recursiva y elimina
            find "$DIR_OLD" -name "*.tmp" -type f -delete
            echo "Limpieza completada."
            CONTADOR_OPC3=$((CONTADOR_OPC3 + 1))
            ;;
        4)
            echo "Saliendo del programa..."
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
done

# 6. Informe final
echo "------------------------------------------------"
echo "La opción 3 (Eliminar temporales) se ejecutó $CONTADOR_OPC3 veces."
echo "------------------------------------------------"