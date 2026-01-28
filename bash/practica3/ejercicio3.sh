#!/bin/bash

# 1. Control de errores inicial: Verificar parámetros
if [ $# -ne 2 ]; then
    echo "Error: Uso incorrecto."
    echo "Uso: $0 <nombre_grupo> <numero_usuarios>"
    exit 1
fi

GRUPO=$1
N=$2

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Debes ejecutar este script con sudo."
    exit 1
fi

# 2. Crear el grupo si no existe
if getent group "$GRUPO" > /dev/null; then
    echo "Aviso: El grupo '$GRUPO' ya existe."
else
    groupadd "$GRUPO"
    echo "Grupo '$GRUPO' creado con éxito."
fi

# 3. Obtener los últimos N usuarios y añadirlos si no están bloqueados
echo "Procesando los últimos $N usuarios del sistema..."

# Sacamos los nombres de los últimos N usuarios de /etc/passwd
ULTIMOS_USUARIOS=$(tail -n "$N" /etc/passwd | cut -d: -f1)

for USUARIO in $ULTIMOS_USUARIOS; do
    # Comprobar si está bloqueado (si la contraseña en /etc/shadow empieza por ! o *)
    BLOQUEADO=$(grep "^$USUARIO:" /etc/shadow | cut -d: -f2 | grep -E "^(!|\*)")

    if [ -z "$BLOQUEADO" ]; then
        usermod -aG "$GRUPO" "$USUARIO"
        echo "Usuario '$USUARIO' añadido al grupo '$GRUPO'."
    else
        echo "Usuario '$USUARIO' saltado (está BLOQUEADO)."
    fi
done

# 4. Posibilidad de crear usuarios nuevos e introducirlos
echo "------------------------------------------------"
read -p "¿Deseas crear un nuevo usuario y añadirlo al grupo? (s/n): " RESPUESTA

while [[ "$RESPUESTA" =~ ^[sS]$ ]]; do
    read -p "Nombre del nuevo usuario: " NUEVO_USUARIO
    
    if id "$NUEVO_USUARIO" >/dev/null 2>&1; then
        echo "El usuario ya existe, solo se añadirá al grupo."
        usermod -aG "$GRUPO" "$NUEVO_USUARIO"
    else
        # Crear usuario con home y shell por defecto
        useradd -m -g "$GRUPO" -s /bin/bash "$NUEVO_USUARIO"
        # Asignar contraseña por defecto
        echo "${NUEVO_USUARIO}:abc123" | chpasswd
        echo "Usuario '$NUEVO_USUARIO' creado y añadido a '$GRUPO'."
    fi

    read -p "¿Deseas añadir otro más? (s/n): " RESPUESTA
done

echo "Proceso finalizado."