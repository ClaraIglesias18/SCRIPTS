#!/bin/bash

# 1. Solicitar los números uno por uno
echo "--- Calculadora de Suma ---"

read -p "Introduce el primer número: " NUM1
read -p "Introduce el segundo número: " NUM2
read -p "Introduce el tercer número: " NUM3

# 2. Control de errores: verificar que no estén vacíos y que sean números
# Usamos una expresión regular sencilla para validar
if [[ ! $NUM1 =~ ^[0-9]+$ ]] || [[ ! $NUM2 =~ ^[0-9]+$ ]] || [[ ! $NUM3 =~ ^[0-9]+$ ]]; then
    echo "Error: Debes introducir solo números enteros positivos."
    exit 1
fi

# 3. Realizar la operación aritmética
SUMA=$((NUM1 + NUM2 + NUM3))

# 4. Mostrar el resultado
echo "---------------------------"
echo "La suma de $NUM1 + $NUM2 + $NUM3 es: $SUMA"

#!/bin/bash

echo "--- Calculadora de Suma con Bucle ---"

SUMA=0
NUMEROS_INTRODUCIDOS=""

for i in {1..3}; do
    read -p "Introduce el número $i: " ACTUAL
    
    # Validar que sea un número
    if [[ ! $ACTUAL =~ ^[0-9]+$ ]]; then
        echo "Error: '$ACTUAL' no es un número válido."
        exit 1
    fi
    
    # Sumar al total
    SUMA=$((SUMA + ACTUAL))
    
    # Guardar el número para mostrarlo al final (opcional)
    if [ $i -eq 1 ]; then
        NUMEROS_INTRODUCIDOS="$ACTUAL"
    else
        NUMEROS_INTRODUCIDOS="$NUMEROS_INTRODUCIDOS + $ACTUAL"
    fi
done

echo "---------------------------"
echo "La suma de $NUMEROS_INTRODUCIDOS es: $SUMA"