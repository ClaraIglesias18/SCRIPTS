@echo off
setlocal enabledelayedexpansion

set "FICHERO=datos.txt"

:: --- Parte 1: Introducción de Datos ---
:introducir_datos
echo.
echo ===========================================
echo    INTRODUCCIÓN DE DATOS DE AUTOMÓVILES
echo ===========================================
echo Escribe 'fin' en la Marca para terminar.
echo.

:bucle_entrada
    set "MARCA="
    set "MODELO="
    set "MATRICULA="
    set "ANO="
    
    set /p "MARCA=Introduce la Marca: "
    if /i "!MARCA!"=="fin" goto :menu_principal
    
    set /p "MODELO=Introduce el Modelo: "
    set /p "MATRICULA=Introduce la Matrícula: "
    set /p "ANO=Introduce el Año de lanzamiento: "
    
    :: Control de errores básico: Verificar que los campos no estén vacíos
    if "!MARCA!"=="" (
        echo Error: La marca no puede estar vacía. Inténtalo de nuevo.
        goto bucle_entrada
    )
    if "!MODELO!"=="" (
        echo Error: El modelo no puede estar vacío. Inténtalo de nuevo.
        goto bucle_entrada
    )
    if "!MATRICULA!"=="" (
        echo Error: La matricula no puede estar vacía. Inténtalo de nuevo.
        goto bucle_entrada
    )
    if "!ANO!"=="" (
        echo Error: El año no puede estar vacío. Inténtalo de nuevo.
        goto bucle_entrada
    )

    :: Formatear y guardar la línea en el archivo (append >>)
    echo !MARCA!:!MODELO!:!MATRICULA!:!ANO!>> "%FICHERO%"
    echo -> Datos guardados correctamente en %FICHERO%.
    echo.
goto bucle_entrada


:: --- Parte 2: Menú Principal ---
:menu_principal
echo.
echo ===========================================
echo            MENÚ DE OPCIONES
echo ===========================================
echo 1. Listado de coches por Marca
echo 2. Listado de coches por Año de lanzamiento
echo 3. Salir
echo.

set /p "OPCION=Seleccione una opcion (1-3): "

if "%OPCION%"=="1" goto :listar_marca
if "%OPCION%"=="2" goto :listar_ano
if "%OPCION%"=="3" goto :salir

echo Error: Opcion no valida. Intentalo de nuevo.
goto :menu_principal


:: --- Parte 3: Opciones de Listado ---

:listar_marca
    if not exist "%FICHERO%" (
        echo Error: El fichero de datos "%FICHERO%" no existe.
        goto :menu_principal
    )
    echo.
    echo ===========================================
    echo    LISTADO DE COCHES AGRUPADOS POR MARCA
    echo ===========================================
    
    :: El comando 'sort' ordena por el primer campo, que es la Marca
    :: El comando 'findstr /V /R "^$" ' elimina las líneas vacías
    (
        echo Marca^|Modelo^|Matricula^|Año
        echo ---^|---^|---^|---
        :: la parte de findstr nos la podemos saltar por que sabemos que no hay lineas vacias
        type "%FICHERO%" | findstr /V /R "^$" | sort /+1
    ) > "%FICHERO%_LISTA_MARCA.tmp"

    type "%FICHERO%_LISTA_MARCA.tmp"
    del "%FICHERO%_LISTA_MARCA.tmp" 2>nul
    
    goto :menu_principal

:listar_ano
    if not exist "%FICHERO%" (
        echo Error: El fichero de datos "%FICHERO%" no existe.
        goto :menu_principal
    )
    echo.
    echo ==================================================
    echo    LISTADO DE COCHES AGRUPADOS POR AÑO (DESC)
    echo ==================================================
    
    set "TEMPORAL=%FICHERO%_REORDENADO.tmp"
    set "LISTA_FINAL=%FICHERO%_LISTA_ANO.tmp"

    :: 1. Reordenar los campos en un archivo temporal:
    :: Extraemos los 4 tokens, usando ':' como delimitador.
    :: El nuevo orden en el TEMPORAL será: Año:Marca:Modelo:Matricula
    
    (
    for /f "tokens=1-4 delims=:" %%a in ('type "%FICHERO%"') do (
        :: %%a=Marca, %%b=Modelo, %%c=Matricula, %%d=Ano
        echo %%d:%%a:%%b:%%c
    )
    ) > "%TEMPORAL%"
    
    :: 2. Ordenar el archivo temporal por el primer campo (que ahora es el Año)
    :: Usamos sort /+1 /R para ordenar por el primer caracter (el Año) de forma descendente.
    (
        echo Año:Marca:Modelo:Matricula
        echo ---:---:---:---
        type "%TEMPORAL%" | sort /+1 /R
    ) > "%LISTA_FINAL%"
    
    :: Mostrar resultado y limpiar
    type "%LISTA_FINAL%"
    del "%TEMPORAL%" 2>nul
    del "%LISTA_FINAL%" 2>nul
    
    goto :menu_principal


:: --- Parte 4: Salida ---
:salir
echo.
echo Saliendo del script. ¡Hasta pronto!
endlocal
pause
exit /b 0