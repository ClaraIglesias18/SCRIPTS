@echo off

setlocal EnableDelayedExpansion

set "numero_equipos_des_count=0"
set "numero_ou_count=0"

set "dominio=dc=dominio,dc=local"


:: VALIDACION DE PARAMETROS
if "%1"=="" (
    echo ERROR: Tienes que pasar el fichero de uo como parametro
    goto :eof
)

if "%2"=="" (
    echo ERROR: Tienes que pasar los equipos como parametro
    goto :eof
)


:: CREACION DE UO DESDE FICHERO
for /f "tokens=1,2 delims=, skip=2" %%a in (%1) do (
    dsadd ou "ou=%%a,%dominio%" -desc %%b
    set /a numero_ou_count+=1
)

:: CREACION DE EQUIPOS DESDE FICHERO
for /f "tokens=1,2 delims=: skip=2" %%a in (%2) do (
    
    set /p habilitado="¿Desea deshabilitar el equipo? [S/N]: "

    if /i "!habilitado!"=="S" (
        dsadd computer "cn=%%a,ou=%%b,%dominio%" -disabled yes
        set /a numero_equipos_des_count+=1
    ) else if /i "!habilitado!"=="N" (
        dsadd computer "cn=%%a,ou=%%b,%dominio%" -disabled no
    )
)

echo Se han creado %numero_ou_count% UO's
echo Se han creado %numero_equipos_des_count% equipos deshabilitados

set /p ou_mostrar="Introduzca la UO que desea mostrar los equipos: "

if("%ou_mostrar%"=="") (
    echo ERROR: No se ha introducido ninguna UO.
    goto :eof
) else (
    dsquery computer "ou=%ou_mostrar%,%dominio%"

    if errorlevel 1 (
        echo La UO %ou_mostrar% no existe.
    )
)