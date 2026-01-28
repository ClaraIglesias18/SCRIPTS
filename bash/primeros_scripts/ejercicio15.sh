#!/bin/bash

# 1. Inicializar la variable que guardará el total
SUMA=0

# 2. Bucle del 1 al 10
# La sintaxis {1..10} genera la secuencia automáticamente
for i in {1..10}
do
    # Sumar el valor de 'i' al total acumulado
    SUMA=$((SUMA + i))
    
    # Opcional: Mostrar el proceso paso a paso
    echo "Sumando $i... Total actual: $SUMA"
done

# 3. Mostrar el resultado final
echo "--------------------------------"
echo "La suma total de los números del 1 al 10 es: $SUMA"