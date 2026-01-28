#!/bin/bash

# Función para solicitar el nombre del fichero y verificar que existe
pedir_fichero() {
    read -p "Introduce el nombre (o ruta) del fichero: " FICHERO
    if [ ! -f "$FICHERO" ]; then
        echo "Error: El fichero '$FICHERO' no existe o no es un fichero regular."
        return 1
    fi
    return 0
}

OPCION=0

while [ "$OPCION" -ne 4 ]; do
    echo -e "\n---------- MENÚ DE GESTIÓN ----------"
    echo "1) Mostrar fichero"
    echo "2) Borrar fichero"
    echo "3) Renombrar fichero"
    echo "4) Salir"
    echo "-------------------------------------"
    read -p "Elige una opción (1-4): " OPCION

    case $OPCION in
        1)
            if pedir_fichero; then
                echo "--- Contenido de $FICHERO ---"
                cat "$FICHERO"
                echo "-----------------------------"
            fi
            ;;
        2)
            if pedir_fichero; then
                read -p "¿Estás seguro de que quieres borrar '$FICHERO'? (s/n): " CONFIRM
                if [ "$CONFIRM" = "s" ]; then
                    rm "$FICHERO" && echo "Fichero borrado con éxito."
                else
                    echo "Operación cancelada."
                fi
            fi
            ;;
        3)
            if pedir_fichero; then
                read -p "Introduce el nuevo nombre para '$FICHERO': " NUEVO_NOMBRE
                if [ -n "$NUEVO_NOMBRE" ]; then
                    mv "$FICHERO" "$NUEVO_NOMBRE" && echo "Fichero renombrado a '$NUEVO_NOMBRE'."
                else
                    echo "Error: El nuevo nombre no puede estar vacío."
                fi
            fi
            ;;
        4)
            echo "Saliendo del programa..."
            ;;
        *)
            echo "Opción no válida, intenta de nuevo."
            ;;
    esac
done