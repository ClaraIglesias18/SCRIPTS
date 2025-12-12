@echo off
setlocal EnableDelayedExpansion

if "%1"=="" (
    echo ERROR: Tienes que pasar el fichero de usuarios como parametro
    goto :eof
)

if not exist %1 (
    echo ERROR: El fichero %1 no existe
    goto :eof
)

echo ----- Creacion de UO -----
set /p uo="Introduzca el nombre de la Unidad Organizativa: "

if %uo%=="" (
    echo ERROR: No se ha introducido ningun nombre.
    goto :eof
)

dsadd ou "ou=%uo%,dc=dominio,dc=local"

dsadd group "cn=distancia,ou=%uo%,dc=dominio,dc=local" -desc "Grupo de distancia"
pause

cls

set /a contadorUsuarios=0

echo %1
echo ----- Creacion de Usuarios -----
for /f "tokens=1,2 delims=," %%a in (%1) do (
    set "nombre=%%a"
    set "inicial=!nombre:~0,1!"
    set "login=!inicial!%%b"

    :PREGUNTA
    set /p "habilitado=Desea habilitar el usuario !login!? (s/n): "

    if /i !habilitado!==s (
        dsadd user "cn=!login!, ou=%uo%,dc=dominio,dc=local" -display "!login!" -pwd %%a -disabled no
    ) else if /i !habilitado!==n (
        dsadd user "cn=!login!, ou=%uo%,dc=dominio,dc=local" -display "!login!" -disabled yes
        dsmod group "cn=distancia,ou=%uo%,dc=dominio,dc=local" -addmbr "cn=!login!, ou=%uo%,dc=dominio,dc=local"
    ) else if not "!habilitado!"=="s" if not "!habilitado!"=="n" (
        echo Opción no válida. Inténtelo de nuevo.
        goto :PREGUNTA
    )

    set /a contadorUsuarios+=1
)

echo Se han creado %contadorUsuarios% usuarios
dsquery user "ou=%uo%,dc=dominio,dc=local" -name *

pause
exit /b