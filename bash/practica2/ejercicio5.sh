#!/bin/bash

# 1. Verificar privilegios de administrador
if [ "$EUID" -ne 0 ]; then
    echo "Error: Este script debe ejecutarse con sudo."
    exit 1
fi

# 2. Pedir el grupo de destino
read -p "Introduce el nombre del grupo al que se añadirán los usuarios: " GRUPO

# 3. Comprobar si el grupo existe, si no, crearlo
if ! getent group "$GRUPO" > /dev/null; then
    echo "El grupo '$GRUPO' no existe. Creándolo..."
    groupadd "$GRUPO"
fi

CONTADOR_EXITO=0
CONTINUAR="s"

# 4. Bucle de creación de usuarios
while [[ "$CONTINUAR" == "s" || "$CONTINUAR" == "S" ]]; do
    read -p "Nombre del nuevo usuario: " USUARIO

    # Comprobar si el usuario ya existe
    if id "$USUARIO" >/dev/null 2>&1; then
        echo "Error: El usuario '$USUARIO' ya existe en el sistema."
    else
        # Crear usuario: -m (crear home), -g (grupo principal), -s (shell)
        if useradd -m -g "$GRUPO" -s /bin/bash "$USUARIO"; then
            
            # Asignar una contraseña temporal para que puedan loguearse
            # (En este caso 'abc123', puedes cambiarla)
            echo "${USUARIO}:abc123" | chpasswd
            
            echo "Usuario '$USUARIO' creado correctamente y listo para iniciar sesión."
            CONTADOR_EXITO=$((CONTADOR_EXITO + 1))
        else
            echo "Hubo un error al intentar crear el usuario '$USUARIO'."
        fi
    fi

    echo "------------------------------------------------"
    read -p "¿Deseas crear otro usuario? (s/n): " CONTINUAR
done

# 5. Informe final
echo -e "\n================ INFORME FINAL ================"
echo "Total de usuarios creados con éxito: $CONTADOR_EXITO"

if [ $CONTADOR_EXITO -gt 0 ]; then
    echo -e "\n--- Líneas en /etc/passwd ---"
    # Buscamos las líneas de los usuarios creados basándonos en el grupo
    # Filtramos por el GID del grupo para ver los últimos añadidos
    GID_GRUPO=$(getent group "$GRUPO" | cut -d: -f3)
    grep ":$GID_GRUPO:" /etc/passwd

    echo -e "\n--- Línea en /etc/group ---"
    getent group "$GRUPO"
fi
echo "==============================================="