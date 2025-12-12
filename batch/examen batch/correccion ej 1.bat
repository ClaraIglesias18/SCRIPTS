@echo off
setlocal enabledelayedexpansion

set dominio="dc=adso50,dc=local"

if "%1" == "" goto error
if not exist %1 goto error

REM Apartado 1
dsadd ou ou=EXAMEN,!dominio! > nul 2> nul
if !errorlevel! neq 0 (
	echo La UO EXAMEN ya existe
	goto :eof
)

REM Apartado 2
for /F "tokens=1,2,3 delims=, skip=1" %%a in (%1) do (
	dsadd group cn=%%b,ou=EXAMEN,!dominio! > nul 2> nul
)

REM Apartado 3
for /F "tokens=1,2,3 delims=, skip=1" %%a in (%1) do (
	set nombre=%%a
	set login=!nombre:~0,1!%%b
	if "%%c" == "SI" ( 
		dsadd user cn=!login!,ou=EXAMEN,!dominio! -pwd abc123. -profile \\WSERVER19\perfiles -desc "Usuario del grupo %%b" -disabled no > nul 2> nul
		dsmod group cn=%%b,ou=EXAMEN,!dominio! -addmbr cn=!login!,ou=EXAMEN,!dominio! > nul 2> nul
		set /a hab+=1
	) else ( 
		dsadd user cn=!login!,ou=EXAMEN,!dominio! -profile \\WSERVER19\perfiles -desc "Usuario del grupo %%b" > nul 2> nul
		dsmod group cn=%%b,ou=EXAMEN,!dominio! -addmbr cn=!login!,ou=EXAMEN,!dominio! > nul 2> nul
	)
	set /a cont+=1
)

echo Se han creado !cont! usuarios de los cuales !hab! han quedado habilitados

goto :eof
:error
echo Error en el parametro de entrada