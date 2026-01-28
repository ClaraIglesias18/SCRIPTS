#!/bin/bash

# Inicializamos variables
OPCION=0
CONTADOR_OPC2=0

while [ "$OPCION" -ne 4 ]; do
    echo -e "\n        INFORMACION DEL SISTEMA"
    echo "        1.- Personas conectadas."
    echo "        2.- Procesos activos en el sistema."
    echo "        3.- Procesos activos de un usuario."
    echo "        4.- Salir al shell."
    echo "----------------------------------------"
    read -p "Elige una opción: " OPCION

    case $OPCION in
        1)
            echo -e "\n--- Usuarios conectados actualmente ---"
            who
            ;;
        2)
            echo -e "\n--- Listado de procesos del sistema ---"
            # ps -e muestra todos los procesos
            ps -e | head -n 20 # Mostramos los primeros 20 para no saturar
            CONTADOR_OPC2=$((CONTADOR_OPC2 + 1))
            ;;
        3)
            read -p "Introduce el nombre del usuario: " USUARIO
            if id "$USUARIO" >/dev/null 2>&1; then
                echo -e "\n--- Procesos del usuario: $USUARIO ---"
                ps -u "$USUARIO"
            else
                echo "Error: El usuario '$USUARIO' no existe."
            fi
            ;;
        4)
            echo -e "\nSaliendo al shell..."
            echo "La opción 2 (Procesos del sistema) se ejecutó $CONTADOR_OPC2 veces."
            ;;
        *)
            echo "Opción no válida, intenta de nuevo."
            ;;
    esac
done