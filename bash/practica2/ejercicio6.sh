#!/bin/bash

# 1. Verificar privilegios de administrador
if [ "$EUID" -ne 0 ]; then
    echo "Error: Este script debe ejecutarse con sudo."
    exit 1
fi

# 2. Obtener la IP y la Máscara automáticamente (Interfaz activa principal)
# Extraemos la IP de la interfaz que tiene la ruta por defecto
INTERFAZ=$(ip route | grep default | awk '{print $5}')
#-o para mostrar la salida del comando en una sola linea por interfaz
IP_COMPLETA=$(ip -o -4 addr show $INTERFAZ | awk '{print $4}')
IP=$(echo $IP_COMPLETA | cut -d/ -f1)

# Obtener el primer octeto para determinar la clase
PRIMER_OCTETO=$(echo $IP | cut -d. -f1)

echo "--- Información de Red ---"
echo "Interfaz detectada: $INTERFAZ"
echo "Dirección IP: $IP"

# 3. Determinar la clase de la IP
if [ $PRIMER_OCTETO -ge 1 -a $PRIMER_OCTETO -le 126 ]; then
    CLASE="A"
elif [ $PRIMER_OCTETO -ge 128 -a $PRIMER_OCTETO -le 191 ]; then
    CLASE="B"
elif [ $PRIMER_OCTETO -ge 192 -a $PRIMER_OCTETO -le 223 ]; then
    CLASE="C"
elif [ $PRIMER_OCTETO -ge 224 -a $PRIMER_OCTETO -le 239 ]; then
    CLASE="D (Multicast)"
elif [ $PRIMER_OCTETO -ge 240 -a $PRIMER_OCTETO -le 255 ]; then
    CLASE="E (Experimental)"
else
    CLASE="Desconocida / Loopback"
fi

echo "La IP pertenece a la Clase: $CLASE"

# 4. Realizar ping al Broadcast
# Calculamos la dirección de broadcast usando el comando 'ip'
BROADCAST=$(ip addr show $INTERFAZ | grep 'brd' | awk '{print $4}')

echo "------------------------------------------------"
echo "Realizando ping a la dirección de broadcast: $BROADCAST"
# -b permite ping a broadcast, -c 2 envía dos paquetes, -W 2 espera 2 segundos
if ping -b -c 2 -W 2 $BROADCAST > /dev/null 2>&1; then
    echo "RESULTADO: La dirección de broadcast está ACCESIBLE."
else
    echo "RESULTADO: La dirección de broadcast NO responde (puede estar bloqueado o inaccesible)."
fi

# 5. Preguntar si se desea reiniciar el servicio
echo "------------------------------------------------"
read -p "¿Deseas reiniciar el servicio de red ahora? (s/n): " RESPUESTA

if [ "$RESPUESTA" = "s" -o "$RESPUESTA" = "S" ]; then
    echo "Reiniciando el servicio de red..."
    # Intentamos con NetworkManager que es el estándar actual
    systemctl restart NetworkManager || systemctl restart networking
    echo "Servicio reiniciado."
else
    echo "Operación cancelada."
fi