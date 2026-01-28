#!/bin/bash

# 1. Control de errores: Verificar parámetros
if [ $# -ne 2 ]; then
    echo "Error: Se requieren dos ficheros como parámetros (aunque no se usen en la lógica actual)."
    echo "Uso: $0 <fichero1> <fichero2>"
    exit 1
fi

OPCION=0
CONTADOR_OPC2=0

while [ "$OPCION" -ne 4 ]; do
    echo -e "\nMENU DE CONFIGURACIÓN IP"
    echo "========================="
    echo "1.- Localizar IP"
    echo "2.- Número de adaptadores"
    echo "3.- Localizar MAC"
    echo "4.- Salir al shell"
    read -p "Elige una opción: " OPCION

    case $OPCION in
        1)
            read -p "Introduce la dirección IP a buscar: " IP_BUSCADA
            # Comprobamos si la IP está asignada a alguna interfaz
            INFO_IP=$(ip addr | grep -w "$IP_BUSCADA")
            
            if [ -n "$INFO_IP" ]; then
                # Si coincide, extraemos el broadcast de esa misma línea
                BROADCAST=$(ip addr | grep -w "$IP_BUSCADA" | awk '{print $4}')
                echo "¡Coincidencia encontrada! La IP está asignada al equipo."
                echo "La dirección de Broadcast correspondiente es: $BROADCAST"
            else
                echo "La IP introducida no pertenece a este equipo."
            fi
            ;;
        2)
            # Contamos las interfaces (excluyendo el encabezado y líneas vacías)
            # 'ls /sys/class/net' es la forma más limpia de contar adaptadores físicos y lógicos
            NUM_ADAPTADORES=$(ls /sys/class/net | wc -l)
            echo "El equipo tiene $NUM_ADAPTADORES adaptador(es) de red."
            CONTADOR_OPC2=$((CONTADOR_OPC2 + 1))
            ;;
        3)
            read -p "Introduce el nombre del fabricante (ej: Intel, Realtek, Atheros): " FABRICANTE
            # Buscamos en el listado de dispositivos PCI el término "Network" o "Ethernet"
            # y filtramos por el nombre del fabricante
            BUSQUEDA=$(lspci | grep -iE "network|ethernet" | grep -i "$FABRICANTE")
            
            if [ -n "$BUSQUEDA" ]; then
                echo "Se ha encontrado hardware de $FABRICANTE en el equipo:"
                echo "$BUSQUEDA"
            else
                echo "No se ha detectado ningún adaptador del fabricante: $FABRICANTE"
            fi
            ;;
        4)
            echo "Saliendo al shell..."
            echo "La opción 2 se ha ejecutado $CONTADOR_OPC2 veces."
            ;;
        *)
            echo "Opción no válida. Intente de nuevo."
            ;;
    esac
done