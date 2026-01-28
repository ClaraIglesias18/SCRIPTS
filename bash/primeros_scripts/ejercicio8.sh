#!/bin/bash

# 1. Pedir el número al usuario
read -p "Introduce un número: " NUMERO

# 2. Validar que la entrada sea realmente un número
if [[ ! $NUMERO =~ ^-?[0-9]+$ ]]; then
    echo "Error: Por favor, introduce un número entero válido."
    exit 1
fi

# 3. Comparar con el número 10
if [ "$NUMERO" -gt 10 ]; then
    echo "El número $NUMERO es MAYOR que 10."
elif [ "$NUMERO" -lt 10 ]; then
    echo "El número $NUMERO es MENOR que 10."
else
    echo "El número introducido es exactamente 10."
fi