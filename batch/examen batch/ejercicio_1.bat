@echo off
:: Deshabilita la visualización de comandos en la ventana
setlocal EnableDelayedExpansion
:: Permite que las variables se actualicen dentro de bucles FOR e IF (usando !)

:: Título y control de parámetros para la fecha (Opción 2)
set "FECHA_PARAM=%1"
:: Asigna el primer parámetro pasado al script (si existe) a la variable FECHA_PARAM

:MENU
cls
:: Limpia la pantalla
echo CONTROLADORES INSTALADOS EN EL EQUIPO %COMPUTERNAME%
echo ===================================================
echo 1.- MOSTRAR LISTA
echo 2.- BUSCAR POR FECHA
echo 3.- INFORMACION FILE SYSTEM
echo 4.- SALIR
echo.

::choice /c 1234 /n /m "Elige una opcion: "

::if errorlevel 4 goto FIN
::if errorlevel 3 goto OP3
::if errorlevel 2 goto OP2
::if errorlevel 1 goto OP1

set /p op="Elige una opcion: "
:: Pide al usuario que ingrese una opción y la guarda en la variable 'op'

if "%op%"=="1" goto OP1
if "%op%"=="2" goto OP2
if "%op%"=="3" goto OP3
if "%op%"=="4" goto FIN

echo Opcion no valida.
pause
goto MENU
:: Si la opción no es válida, vuelve al menú

:OP1
:: OPCION 1: Mostrar solo la primera columna (Nombre de modulo)
cls
echo LISTADO DE NOMBRES DE CONTROLADORES:
echo ------------------------------------
:: Ejecuta driverquery en formato CSV sin cabeceras (/NH)
for /f "tokens=1 delims=," %%a in ('driverquery /FO CSV /NH') do (
    :: El bucle FOR procesa la salida, tomando solo el primer token (columna) delimitado por comas
    echo %%~a
)
pause
goto MENU

:OP2
:: OPCION 2: Buscar por fecha pasada como parámetro y contar coincidencias
cls
if "%FECHA_PARAM%"=="" (
    :: Control de error: Verifica si se pasó la fecha como parámetro
    echo ERROR: Debes pasar una fecha como parametro al script para usar esta opcion.
    echo Ejemplo: ejercicio1.bat 08/12/2023
    pause
    goto MENU
)

echo Buscando controladores con fecha: %FECHA_PARAM%
set /a contador=0
:: Inicializa el contador de coincidencias a cero

:: Buscamos la fecha en la salida de driverquery usando la tubería (|) y FIND
for /f "tokens=*" %%i in ('driverquery ^| find "%FECHA_PARAM%"') do (
    echo %%i
    set /a contador+=1
    :: Incrementa el contador por cada línea que contenga la fecha
)

echo.
echo Numero de coincidencias encontradas: !contador!
:: Muestra el contador, usando ! ! para expansión retardada
pause
goto MENU

:OP3
:: OPCION 3: Listar tipo "File System" y mostrar línea especifica
cls
echo Generando lista de File System...
set "tempFile=filesystem_list.txt"

:: Filtramos por "File System" (inglés) y guardamos en temporal
driverquery | find /i "File System" > !tempFile!
:: Filtramos por "Sistema de archivos" (español, como contingencia) y añadimos al temporal (>>)
::driverquery | find /i "Sistema de archivos" >> !tempFile!

:: Mostramos la lista numerada para que el usuario elija
findstr /n "^" %tempFile% 2>nul
:: FINDSTR /n añade el número de línea seguido de dos puntos (ej: 1:texto)

echo.
set /p linea="Indica el numero de linea que quieres ver: "
:: Pide al usuario el número de línea

:: Validacion simple de numero
if "%linea%"=="" goto MENU

:: Mostramos solo la linea indicada
echo.
echo CONTENIDO DE LA LINEA %linea%:
echo -----------------------------
set /a saltar=%linea%-1
:: Calculamos cuántas líneas debe saltar MORE (N-1)

if %saltar% LSS 0 set saltar=0
:: Asegura que no sea un número negativo

:: muestra las lineas desde la que dijimos que salte filtra numerando de nuevo
:: ahora busca la linea que empiece con la cadena 1
more +%saltar% !tempFile! | findstr /n "^" | findstr "^1:"
:: MORE salta las primeras N-1 líneas. La tubería luego numera de nuevo (1:...) y se queda solo con la primera línea nueva (el "^1:").

:: Limpieza
del !tempFile!
:: Borra el archivo temporal
pause
goto MENU

:FIN
exit /b
:: Termina la ejecución del script