#!/bin/bash

# 1. Control de errores: Verificar que se pasan exactamente dos parámetros
if [ $# -ne 2 ]; then
    echo "Error: Se requieren dos ficheros como parámetros."
    echo "Uso: $0 <fichero1> <fichero2>"
    exit 1
fi

FICHERO1=$1
FICHERO2=$2

# 2. Mostrar menú y leer opción
echo "      MENÚ DE INFORMES"
echo "============================"
echo "B.- Borrar los ficheros"
echo "C.- Copiar al directorio raíz"
echo "S.- Sumar (concatenar) ficheros"
echo "============================"
read -p "Elige una opción (B, C o S): " OPCION

# Convertir a mayúsculas para evitar errores si el usuario pulsa minúscula
OPCION=${OPCION^^}

case $OPCION in
    "B")
        # Opción B: Borrar
        if [ -f "$FICHERO1" ] && [ -f "$FICHERO2" ]; then
            rm "$FICHERO1" "$FICHERO2"
            echo "Éxito: Los ficheros han sido eliminados."
        else
            echo "Error: Alguno de los ficheros no existe y no se pudo borrar."
        fi
        ;;

    "C")
        # Opción C: Copiar al raíz (requiere sudo)
        if [ -f "$FICHERO1" ] && [ -f "$FICHERO2" ]; then
            if cp "$FICHERO1" "$FICHERO2" /; then
                echo "Éxito: Ficheros copiados al directorio raíz."
            else
                echo "Error: No se pudo copiar. ¿Tienes permisos de root?"
            fi
        else
            echo "Error: Alguno de los ficheros no existe."
        fi
        ;;

    "S")
        # Opción S: Sumar (Concatenar)
        if [ -f "$FICHERO1" ] && [ -f "$FICHERO2" ]; then
            cat "$FICHERO1" "$FICHERO2" > suma
            echo "Éxito: Se ha creado el fichero 'suma' con el contenido de ambos."
        else
            echo "Error: Alguno de los ficheros no existe."
        fi
        ;;

    *)
        echo "Error: Opción no válida."
        ;;
esac