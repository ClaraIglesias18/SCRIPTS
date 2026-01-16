@echo off
setlocal enabledelayedexpansion

set /p curso=Dime el nombre del curso:
set /p num=Dime cuantos usuarios quieres crear:
set /a contador=0


:: COMPROBAMOS QUE NO EXISTE LA OU
dsquery ou -name !curso! | find "clara" > tmp

:: VERIFICAMOS SI SE PUEDE CREAR LA UO
if !errorlevel! equ 0 ( 
    echo La unidad organizativa que corresponde a ese curso YA está creada
    goto fin
) else dsadd ou ou=!curso!,dc=clara,dc=local > tmp

for /l %%a in (1,1,!num!) do (
    set usuario=!curso!%%a
    dsadd user cn=!usuario!,ou=!curso!,dc=carina,dc=local -disabled no -pwd abc123. > tmp
    if !errorlevel! equ 0 ( 
        echo El usuario !usuario! se ha creado correctamente
        set /a contador+=1
    ) else echo No se ha podido crear el usuario !usuario!
)

echo se han creado !contador! usuarios en la UO !curso!

:fin
