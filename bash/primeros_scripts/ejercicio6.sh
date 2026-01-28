#!/bin/bash

# Comprobar si el script se ejecuta como root (necesario para ver bloqueos)
if [ "$EUID" -ne 0 ]; then 
  echo "Por favor, ejecuta este script con sudo."
  exit 1
fi

echo "--- INFORME DE SISTEMA ---"

# 1. Cantidad de usuarios bloqueados
# En /etc/shadow, los usuarios bloqueados suelen tener '!' o '*' en el campo de contraseña
#wc words count -l cuenta el numero de lineas
BLOQUEADOS=$(grep -E '^[^:]+:[!*]' /etc/shadow | wc -l)
echo "Usuarios bloqueados: $BLOQUEADOS"

# 2. Cantidad de usuarios logueados (conectados)
# El comando 'who' muestra quién está, 'wc -l' cuenta las líneas
CONECTADOS=$(who | wc -l)
echo "Usuarios conectados actualmente: $CONECTADOS"

# 3. Lista de usuarios autorizados a hacer sudo
# Miramos el grupo 'sudo' (en Debian/Ubuntu) o 'wheel' (en RedHat/CentOS)
echo "Usuarios con privilegios sudo:"
grep '^sudo:.*' /etc/group | cut -d: -f4 | tr ',' ' '
grep '^wheel:.*' /etc/group | cut -d: -f4 | tr ',' ' '

echo "--------------------------------"

# 4. Generar fichero con lista de archivos de un usuario
read -p "Introduce el nombre de un usuario para listar sus ficheros: " USUARIO

# Comprobar si el usuario existe
if id "$USUARIO" >/dev/null 2>&1; then
    echo "Buscando ficheros de '$USUARIO'... esto puede tardar."
    # Buscamos en todo el sistema (-find /) archivos cuyo usuario (-user) sea el indicado
    find / -user "$USUARIO" > datos.txt 2>/dev/null
    echo "Lista generada con éxito en el archivo: datos.txt"
else
    echo "Error: El usuario '$USUARIO' no existe."
fi