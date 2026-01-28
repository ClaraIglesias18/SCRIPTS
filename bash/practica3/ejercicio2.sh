#!/bin/bash

# 1. Verificar privilegios de root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Este script debe ejecutarse con sudo."
    exit 1
fi

# 2. Pedir el número de grupos a crear
read -p "Introduce cuántos grupos deseas crear: " N

# Validar que la entrada sea un número entero positivo
if [[ ! "$N" =~ ^[0-9]+$ ]] || [ "$N" -eq 0 ]; then
    echo "Error: Debes introducir un número entero mayor que 0."
    exit 2
fi

echo "Iniciando la creación de $N grupos con el patrón grupox (de 2 en 2)..."

# 3. Bucle para crear los grupos
# i es el contador de grupos creados
# x es el número que acompaña al nombre (0, 2, 4...)
x=0
for (( i=1; i<=N; i++ ))
do
    NOMBRE_GRUPO="grupo$x"

    # Comprobar si el grupo ya existe para evitar errores
    if getent group "$NOMBRE_GRUPO" > /dev/null; then
        echo "Aviso: El grupo '$NOMBRE_GRUPO' ya existe. Saltando..."
    else
        groupadd "$NOMBRE_GRUPO"
        if [ $? -eq 0 ]; then
            echo "Grupo '$NOMBRE_GRUPO' creado correctamente."
        else
            echo "Error al crear el grupo '$NOMBRE_GRUPO'."
        fi
    fi

    # Incrementamos x en 2 para el siguiente grupo
    x=$((x + 2))
done

# 4. Mostrar las últimas N líneas del fichero de grupos
echo "------------------------------------------------"
echo "Mostrando las últimas $N líneas de /etc/group:"
tail -n "$N" /etc/group