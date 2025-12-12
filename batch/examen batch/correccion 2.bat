@echo off
setlocal enabledelayedexpansion

if "%1" == "" goto error

if not exist controladores.txt (
	driverquery /FO CSV > controladores.txt
)
	
echo CONTROLADORES INSTALADOS EN EL EQUIPO !computername!
echo ====================================================
echo 1.-MOSTRAR LISTA
echo 2.-BUSCAR POR FECHA
echo 3.-INFORMACION FILE SYSTEM

choice /m "Elige una opcion: " /c:123

if errorlevel 3 goto opcion3
if errorlevel 2 goto opcion2
if errorlevel 1 goto opcion1

:opcion1
for /F "tokens=1,2,3,4 delims=," %%a in (controladores.txt) do (
	echo %%a
)

:opcion2
echo "Controladores de fecha %1 - Listado y nÃºmero de coincidencias"
driverquery | find "%1"
driverquery | find "%1" /c


:opcion3
driverquery | find "File System" /i /n 
driverquery | find "File System" /i /n > system.txt
set /p linea="Que linea quieres mostrar?: "
echo.
type system.txt | find "!linea!" /i


goto :eof

:error
echo Debes indicar un parametro