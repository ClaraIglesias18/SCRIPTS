#!/bin/bash

# 1. Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Debes ejecutar este script con sudo."
    exit 1
fi

echo "--- Configurador de Compartición NFS ---"

# 2. Pedir datos al usuario
read -p "1. Introduce la ruta completa de la carpeta a compartir: " CARPETA
read -p "2. Introduce la red o equipo permitido (ej. 192.168.1.0/24 o *): " CLIENTE
echo "3. Selecciona el modo de compartición:"
echo "   rw -> Lectura y escritura"
echo "   ro -> Solo lectura"
read -p "Modo: " MODO

# 3. Comprobar que la carpeta existe
if [ ! -d "$CARPETA" ]; then
    echo "Error: La carpeta '$CARPETA' no existe."
    exit 2
fi

# 4. Comprobar que el modo sea válido (básico)
if [ "$MODO" != "rw" -a "$MODO" != "ro" ]; then
    echo "Error: El modo debe ser 'rw' o 'ro'."
    exit 3
fi

# 5. Realizar la compartición
# Añadimos la línea al final de /etc/exports
# sync: asegura que los datos se escriban antes de responder
# no_subtree_check: mejora la fiabilidad en NFS
echo "$CARPETA $CLIENTE($MODO,sync,no_subtree_check)" >> /etc/exports

# 6. Aplicar los cambios
echo "Aplicando cambios en el servidor NFS..."
exportfs -a
systemctl restart nfs-kernel-server

# 7. Verificar el resultado
if [ $? -eq 0 ]; then
    echo "------------------------------------------------"
    echo "¡Éxito! Carpeta compartida correctamente."
    echo "Estado actual de /etc/exports:"
    tail -n 1 /etc/exports
else
    echo "Error al intentar reiniciar el servicio NFS."
fi