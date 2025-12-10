@echo off
setlocal enabledelayedexpansion

if %1=="" (
    echo Tienes que pasar el fichero de usuarios como parametro
    goto :eof
)

echo ----- Creacion de UO -----
set /p uo="Introduzca el nombre de la Unidad Organizativa: "

if %uo%=="" (
    echo No se ha introducido ningun nombre.
    goto :eof
)

dsadd ou "ou=%uo%,dc=dominio,dc=local"

dsadd group "cn=distancia,ou=%uo%,dc=dominio,dc=local" -dsc "Grupo de distancia"

cls

set /a contadorUsuarios=0

echo ----- Creacion de Usuarios -----
for /f "tokens=1,2 delims=," %%a in (%1) do (
    set "inicial=%%a~0,1"
    set "login=!inicial!%%b"

    set /p "habilitado=Desea habilitar el usuario !login!? (s/n): "

    if habilitado==s (
        dsadd user "cn=!login!, ou=%uo%,dc=dominio,dc=local" -display "!login!" -pwd %%a -disabled no
    ) else habilitado==n (
        dsadd user "cn=!login!, ou=%uo%,dc=dominio,dc=local" -display "!login!" -disabled yes
        dsmod group "cn=distancia,ou=%uo%,dc=dominio,dc=local" -addmbr "cn=!login!, ou=%uo%,dc=dominio,dc=local"
    )

    set /a contadorUsuarios+=1
)

echo Se han creado %contadorUsuarios% usuarios.
dsquery user "ou=Ventas,dc=dominio,dc=local" -name

endlocal
pause
exit




