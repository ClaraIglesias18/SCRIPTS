
#!/bin/bash

# 1. Control de errores inicial: Verificar que se pasan dos ficheros
if [ $# -ne 2 ]; then
    echo "Error: Se requieren exactamente dos ficheros como parámetros."
    echo "Uso: $0 <fichero1> <fichero2>"
    exit 1
fi

FICHERO1=$1
FICHERO2=$2
OPCION=0
CONTADOR_OPC3=0

while [ "$OPCION" -ne 4 ]; do
    echo -e "\n      MENU DE PROCESOS"
    echo "=============================="
    echo "1.- Localizar PPID"
    echo "2.- Lista de Procesos"
    echo "3.- Procesos con TTY (1-7)"
    echo "4.- Salir al Shell"
    echo "=============================="
    read -p "Elige una opción: " OPCION

    case $OPCION in
        1)
            read -p "Introduce el nombre del proceso: " NOMBRE_PROC
            # Buscamos PID ($2) y PPID ($3) usando ps
            INFO=$(ps -ef | grep -v "grep" | grep -i "$NOMBRE_PROC" | awk '{print "PID: "$2", PPID: "$3}')
            
            if [ -z "$INFO" ]; then
                echo "Error: El proceso '$NOMBRE_PROC' no existe en el sistema."
            else
                echo "Información encontrada:"
                echo "$INFO"
            fi
            ;;
        2)
            echo "¿Qué desea ver?"
            echo "a) Procesos en segundo plano (de esta sesión)"
            echo "b) Procesos de crontab (tareas programadas)"
            read -p "Opción (a/b): " SUBOPCION
            
            if [ "$SUBOPCION" = "a" ]; then
                jobs 2>/dev/null || echo "No hay procesos en segundo plano activos."
            elif [ "$SUBOPCION" = "b" ]; then
                echo "--- Tareas Crontab del usuario actual ---"
                crontab -l 2>/dev/null || echo "No hay tareas programadas para este usuario."
            else
                echo "Subopción no válida."
            fi
            ;;
        3)
            echo "Calculando procesos con TTY asignado (tty1 a tty7)..."
            # Filtramos procesos que tengan tty1, tty2... tty7 en la columna TTY
            TOTAL_TTY=$(ps -ae -o tty | grep -E "tty[1-7]" | wc -l)
            echo "Actualmente hay $TOTAL_TTY procesos con un TTY (1-7) asignado."
            CONTADOR_OPC3=$((CONTADOR_OPC3 + 1))
            ;;
        4)
            echo "Saliendo al Shell..."
            echo "La opción 3 se ha ejecutado un total de $CONTADOR_OPC3 veces."
            ;;
        *)
            echo "Opción incorrecta. Por favor, selecciona del 1 al 4."
            ;;
    esac
done