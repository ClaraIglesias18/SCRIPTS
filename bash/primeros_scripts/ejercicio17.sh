#!/bin/bash

# 1. Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Debes ejecutar este script con sudo."
    exit 1
fi

# 2. Controlar que se pase el nombre del usuario como parámetro
if [ $# -ne 1 ]; then
    echo "Uso: $0 <nombre_del_usuario>"
    exit 1
fi

USUARIO=$1

# 3. Comprobar si el usuario existe en el sistema
if ! id "$USUARIO" >/dev/null 2>&1; then
    echo "Error: El usuario '$USUARIO' no existe."
    exit 2
fi

# 4. Comprobar si está bloqueado
# Buscamos en /etc/shadow si la contraseña empieza por !
ESTA_BLOQUEADO=$(grep "^$USUARIO:" /etc/shadow | cut -d: -f2 | grep "^!")

if [ -n "$ESTA_BLOQUEADO" ]; then
    echo "El usuario '$USUARIO' está bloqueado. Procediendo al desbloqueo..."
    
    # 5. Desbloquear la cuenta
    passwd -u "$USUARIO"
    
    # 6. Establecer la contraseña abc123
    echo "${USUARIO}:abc123" | chpasswd
    
    echo "Éxito: Usuario desbloqueado y contraseña restablecida a 'abc123'."
else
    echo "El usuario '$USUARIO' existe pero NO está bloqueado."
fi