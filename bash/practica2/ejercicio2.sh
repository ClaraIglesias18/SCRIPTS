#!/bin/bash

# 1. Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Debes ejecutar este script con sudo."
    exit 1
fi

# 2. Verificar si el fichero 'grupos' existe
FICHERO="grupos"
if [ ! -f "$FICHERO" ]; then
    echo "Error: El fichero '$FICHERO' no existe."
    exit 2
fi

echo "--- Iniciando creación de grupos desde el fichero ---"

# 3. Leer el fichero y crear los grupos
while IFS= read -r GRUPO || [ -n "$GRUPO" ]; do
    # Evitar procesar líneas vacías
    if [ -z "$GRUPO" ]; then continue; ffi

    # Comprobar si el grupo ya existe
    if getent group "$GRUPO" > /dev/null; then
        echo "Aviso: El grupo '$GRUPO' ya existe. Omitiendo..."
    else
        groupadd "$GRUPO"
        echo "Grupo '$GRUPO' creado con éxito."
    fi
done < "$FICHERO"

echo "----------------------------------------------------"

# 4. Preguntar si se desea agregar usuarios
read -p "¿Deseas agregar algún usuario a un grupo? (s/n): " RESPUESTA

while [ "$RESPUESTA" = "s" -o "$RESPUESTA" = "S" ]; do
    read -p "Nombre del usuario: " USUARIO
    read -p "Nombre del grupo: " GRUPO_DESTINO

    # Verificar si el usuario existe
    if ! id "$USUARIO" >/dev/null 2>&1; then
        echo "Error: El usuario '$USUARIO' no existe."
    # Verificar si el grupo existe
    elif ! getent group "$GRUPO_DESTINO" >/dev/null; then
        echo "Error: El grupo '$GRUPO_DESTINO' no existe."
    else
        # Añadir usuario al grupo (-a: append, -G: grupos secundarios)
        usermod -aG "$GRUPO_DESTINO" "$USUARIO"
        echo "Usuario '$USUARIO' añadido al grupo '$GRUPO_DESTINO'."
    fi

    echo "----------------------------------------------------"
    read -p "¿Deseas agregar a otro usuario? (s/n): " RESPUESTA
done

echo "Proceso finalizado."