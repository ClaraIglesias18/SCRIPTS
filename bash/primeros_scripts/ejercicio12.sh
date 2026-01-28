#!/bin/bash

# 1. Verificar si se ejecuta con sudo (necesario para gestionar servicios)
if [ "$EUID" -ne 0 ]; then
    echo "Error: Debes ejecutar este script con sudo."
    exit 1
fi

# 2. Verificar que se ha pasado la acción como parámetro (iniciar, parar, reiniciar)
if [ $# -ne 1 ]; then
    echo "Uso: $0 {iniciar|parar|reiniciar}"
    exit 1
fi

ACCION_USUARIO=$1

# Convertir la palabra del usuario al comando técnico de systemctl
case "$ACCION_USUARIO" in
    "iniciar")   ACCION="start"   ;;
    "parar")     ACCION="stop"    ;;
    "reiniciar") ACCION="restart" ;;
    *)
        echo "Acción no válida. Usa: iniciar, parar o reiniciar."
        exit 1
        ;;
esac

# 3. Mostrar menú de selección de servicio
echo "      SERVICIOS DEL SISTEMA"
echo "-----------------------------------"
echo "1) Servicio Webmin"
echo "2) Servicio ssh"
echo "3) Servicio de red (NetworkManager)"
echo "4) Servicio de cuotas (quota)"
echo "-----------------------------------"
read -p "Selecciona el servicio que deseas $ACCION_USUARIO (1-4): " OPCION

# 4. Ejecutar la acción sobre el servicio correspondiente
case "$OPCION" in
    1) SERVICIO="webmin" ;;
    2) SERVICIO="ssh" ;;
    3) SERVICIO="NetworkManager" ;; # En sistemas modernos es NetworkManager o systemd-networkd
    4) SERVICIO="quota" ;;
    *)
        echo "Opción de servicio no válida."
        exit 1
        ;;
esac

echo "Ejecutando: $ACCION sobre el servicio $SERVICIO..."
systemctl $ACCION $SERVICIO

# 5. Comprobar si hubo éxito
if [ $? -eq 0 ]; then
    echo "Operación realizada con éxito."
    # Mostrar el estado actual para confirmar
    systemctl status $SERVICIO | grep "Active:"
else
    echo "Error: No se pudo realizar la acción. ¿Está el servicio instalado?"
fi