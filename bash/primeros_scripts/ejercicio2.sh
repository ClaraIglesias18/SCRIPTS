#!/bin/bash

# 1. Saludo al usuario conectado
# Usamos la variable de entorno $USER o el comando whoami
echo "Hola, $USER. ¡Bienvenido de nuevo!"

# 2. Mostrar la fecha y la hora actuales
# El comando date muestra la fecha en formato legible
echo -n "Hoy es: "
date

# 3. Listado del directorio raíz (/)
echo "-------------------------------------"
echo "Contenido del directorio raíz (/):"
ls /

# Finalizar el script
exit 0