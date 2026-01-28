#!/bin/bash

# 1. Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Debes ejecutar este script con sudo."
    exit 1
fi

# 2. Pedir datos iniciales
read -p "Introduce el nombre del grupo (m): " GRUPO
read -p "Introduce el número de usuarios a crear (n): " CANTIDAD

# 3. Comprobar si el grupo existe, si no, crearlo
if ! getent group "$GRUPO" > /dev/null; then
    echo "El grupo '$GRUPO' no existe. Creándolo..."
    groupadd "$GRUPO"
fi

echo "Iniciando la creación de $CANTIDAD usuarios..."

# 4. Bucle para crear los usuarios con el patrón m1xx
# Si m=ventas y n=3, creará: ventas101, ventas102, ventas103
for (( i=1; i<=$CANTIDAD; i++ ))
do
    # Formatear el número para que sea 01, 02, etc. (opcional, para estética)
    NUM_FORMATEADO=$(printf "%02d" $i)
    
    # Construir el nombre de usuario (patrón m1xx)
    # El '1' es fijo según tu enunciado
    USUARIO="${GRUPO}1${NUM_FORMATEADO}"
    
    # Crear el usuario
    # -g: define el grupo principal
    # -m: crea el directorio home
    # -s: define el shell por defecto
    useradd -g "$GRUPO" -m -s /bin/bash "$USUARIO"
    
    # Asignar la contraseña abc123 de forma automática
    echo "${USUARIO}:abc123" | chpasswd
    
    echo "Usuario '$USUARIO' creado con éxito."
done

echo "---------------------------------------"
echo "Proceso finalizado. Se han creado $CANTIDAD usuarios en el grupo '$GRUPO'."