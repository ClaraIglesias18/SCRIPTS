#!/bin/bash

# 1. Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Debes ejecutar este script con sudo."
    exit 1
fi

echo "--- Configurador de Cliente NFS ---"

# 2. Pedir datos al usuario
read -p "1. Introduce la IP del servidor NFS: " IP_SERVIDOR
read -p "2. Introduce la ruta de la carpeta compartida en el servidor: " CARPETA_REMOTA
read -p "3. Introduce la carpeta local donde se montará (punto de montaje): " PUNTO_MONTAJE

# 3. Comprobar conectividad con el servidor (hacemos 2 pings rápidos)
echo "Comprobando conexión con el servidor $IP_SERVIDOR..."
if ! ping -c 2 "$IP_SERVIDOR" > /dev/null 2>&1; then
    echo "Error: No hay conexión con el servidor. Revisa la IP o la red."
    exit 2
fi

# 4. Comprobar que la carpeta local existe
if [ ! -d "$PUNTO_MONTAJE" ]; then
    echo "Error: El punto de montaje local '$PUNTO_MONTAJE' no existe."
    echo "Sugerencia: Puedes crearla con 'mkdir -p $PUNTO_MONTAJE'"
    exit 3
fi

# 5. Realizar el montaje temporal
echo "Intentando montar $IP_SERVIDOR:$CARPETA_REMOTA en $PUNTO_MONTAJE..."
mount -t nfs "$IP_SERVIDOR:$CARPETA_REMOTA" "$PUNTO_MONTAJE"

if [ $? -eq 0 ]; then
    echo "¡Éxito! La carpeta se ha montado correctamente."
else
    echo "Error: No se pudo realizar el montaje. Revisa que el servidor tenga la carpeta compartida para tu IP."
    exit 4
fi

# 6. Ofrecer montaje automático (Persistencia)
echo "------------------------------------------------"
read -p "¿Deseas que esta carpeta se monte automáticamente al iniciar el sistema? (s/n): " RESPUESTA

if [ "$RESPUESTA" = "s" -o "$RESPUESTA" = "S" ]; then
    # Añadimos la línea al archivo /etc/fstab
    # _netdev asegura que el sistema espere a tener red antes de intentar el montaje
    LINEA_FSTAB="$IP_SERVIDOR:$CARPETA_REMOTA  $PUNTO_MONTAJE  nfs  defaults,_netdev  0  0"
    
    # Evitar duplicados: solo añadimos si no existe ya esa línea
    if grep -q "$IP_SERVIDOR:$CARPETA_REMOTA" /etc/fstab; then
        echo "Aviso: Ya existe una entrada para este servidor en /etc/fstab."
    else
        echo "$LINEA_FSTAB" >> /etc/fstab
        echo "Configuración guardada en /etc/fstab."
    fi
fi

echo "Proceso finalizado."