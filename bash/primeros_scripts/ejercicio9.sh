#!/bin/bash

# 1. Obtener la hora actual (formato 00-23)
HORA=$(date +%H)

# 2. Determinar el saludo según el rango
# Rango 06:00 a 12:59 -> Buenos días
# Rango 13:00 a 20:59 -> Buenas tardes
# Rango 21:00 a 05:59 -> Buenas noches

if [[ $HORA -ge 6 && $HORA -lt 13 ]]; then
    echo "¡Buenos días!"
elif [[ $HORA -ge 13 && $HORA -lt 21 ]]; then
    echo "¡Buenas tardes!"
else
    echo "¡Buenas noches!"
fi

#if [ "$HORA" -ge 6 -a "$HORA" -lt 13 ]; then
#    echo "¡Buenos días!"
#elif [ "$HORA" -ge 13 -a "$HORA" -lt 21 ]; then
#    echo "¡Buenas tardes!"
#else
#    echo "¡Buenas noches!"
#fi

# Opcional: Mostrar la hora exacta para confirmar
echo "Son las $(date +%H:%M)."