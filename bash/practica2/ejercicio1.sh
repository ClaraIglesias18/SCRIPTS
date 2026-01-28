#!/bin/bash

# Inicializamos el contador de números introducidos
CONTADOR=0
NUMERO=-1  # Inicializamos con un valor distinto de 0 para que entre al bucle

echo "--- Calculadora del Doble (Pulsa 0 para salir) ---"

# El bucle se repite mientras el número no sea 0
while [ "$NUMERO" -ne 0 ]; do
    read -p "Introduce un número: " NUMERO

    # Verificamos si es un número válido (enteros positivos o negativos)
    if [[ ! "$NUMERO" =~ ^-?[0-9]+$ ]]; then
        echo "Error: Por favor, introduce un número válido."
        continue
    fi

    # Si el usuario pulsa 0, el bucle terminará en la siguiente comprobación
    if [ "$NUMERO" -ne 0 ]; then
        DOBLE=$((NUMERO * 2))
        echo "El doble de $NUMERO es: $DOBLE"
        
        # Incrementamos el contador
        CONTADOR=$((CONTADOR + 1))
    fi
done

echo "--------------------------------------------------"
echo "Has introducido un total de $CONTADOR números."
echo "Saliendo del programa..."