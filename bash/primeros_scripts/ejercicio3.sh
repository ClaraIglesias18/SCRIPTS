#!/bin/bash

# 1. Número de identificación del usuario (UID) y de su grupo (GID)
# El comando 'id' muestra ambos de forma clara
echo "--- Identificación del Usuario ---"
id

# 2. Información del usuario actual en /etc/passwd
# Buscamos la línea que empieza con nuestro nombre de usuario
echo -e "\n--- Registro en /etc/passwd ---"
grep "^$USER:" /etc/passwd

# 3. Directorio HOME del usuario actual
# Usamos la variable de entorno $HOME
echo -e "\n--- Directorio Personal (HOME) ---"
echo "Tu directorio principal es: $HOME"

exit 0