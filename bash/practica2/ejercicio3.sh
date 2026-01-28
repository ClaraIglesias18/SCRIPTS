#!/bin/bash

FICHERO="clientes"
RESULTADO="resultado"

# 1. Control de errores inicial: Verificar parámetros
if [ $# -ne 2 ]; then
    echo "Error: Uso incorrecto."
    echo "Uso: $0 <localidad> <operador>"
    exit 1
fi

LOCALIDAD_BUSCADA=$1
OPERADOR_BUSCADO=$2

# 2. Verificar si el fichero de origen existe
if [ ! -f "$FICHERO" ]; then
    echo "Error: El fichero '$FICHERO' no existe."
    # Creamos uno vacío para que el script pueda continuar con la parte de añadir datos
    touch "$FICHERO"
    echo "Se ha creado un fichero '$FICHERO' vacío."
fi

# 3. Filtrar y generar el fichero 'resultado'
# Usamos awk con separador de campo ';' (-F';')
# $5 es Localidad y $4 es Operador según el formato dado
awk -F';' -v loc="$LOCALIDAD_BUSCADA" -v ope="$OPERADOR_BUSCADO" \
    '$5 == loc && $4 == ope { print $0 }' "$FICHERO" > "$RESULTADO"

echo "Filtrado completado. Se han guardado las coincidencias en '$RESULTADO'."

# 4. Parte repetitiva: Añadir información
echo -e "\n--- Añadir nuevos clientes ---"
read -p "¿Deseas añadir un nuevo cliente? (s/n): " RESPUESTA

while [ "$RESPUESTA" = "s" -o "$RESPUESTA" = "S" ]; do
    echo "Introduce los datos del cliente:"
    read -p "Nombre: " NOM
    read -p "Primer Apellido: " APE1
    read -p "Segundo Apellido: " APE2
    read -p "Operador: " OPE
    read -p "Localidad: " LOC
    read -p "Ciudad: " CIU

    # Validar que no haya campos vacíos
    if [ -z "$NOM" ] || [ -z "$APE1" ] || [ -z "$LOC" ]; then
        echo "Error: Nombre, Apellido y Localidad son obligatorios. No se guardó el registro."
    else
        # Guardar en el fichero con el formato correcto
        echo "$NOM;$APE1;$APE2;$OPE;$LOC;$CIU" >> "$FICHERO"
        echo "Cliente añadido con éxito."
    fi

    echo "------------------------------"
    read -p "¿Deseas añadir otro cliente? (s/n): " RESPUESTA
done

echo "Script finalizado."