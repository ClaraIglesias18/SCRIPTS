@echo off
setlocal EnableDelayedExpansion

:: 1. Control de errores de parametros
:: se verifica que el primer parametro no este vacio
if "%1"=="" (
    echo ERROR: Debes indicar el fichero de alumnado.
    echo Uso: %0 alumnado.txt
    goto FIN
)

if not exist %1 (
    echo ERROR: El fichero %1 no existe.
    goto FIN
)

:: Variables de contadores
set /a total_usuarios=0
set /a total_habilitados=0

:: 2. Crear Unidad Organizativa EXAMEN [cite: 36]
echo Creando Unidad Organizativa EXAMEN...
dsadd ou "ou=EXAMEN,dc=dominio,dc=local" 2>nul
if %errorlevel%==0 (
	echo OU Creada.
) else (
	echo La OU ya existe o hubo un error.
)

:: 3. Procesar el fichero línea por línea [cite: 26, 35]
:: Tokens: 1=Nombre, 2=Curso, 3=Habilitar. Delimitador: coma.
for /f "skip=1 tokens=1,2,3 delims=," %%a in (%1) do (
    
    set "nombre=%%a"
    set "curso=%%b"
    set "habilitar=%%c"
    
    :: Limpieza de espacios en blanco (por si acaso el csv tiene espacios extra)
    set "nombre=!nombre: =!"
    set "curso=!curso: =!"
    set "habilitar=!habilitar: =!"

    :: --- CREACION DE GRUPOS (Punto 2) [cite: 37] ---
    dsadd group "cn=!curso!,ou=EXAMEN,dc=dominio,dc=local" 2>nul
    
    :: --- GENERACION DEL LOGIN (Punto 3) [cite: 38, 29] ---
    :: Extraemos la primera letra del nombre
    set "inicial=!nombre:~0,1!"
    :: Login = Inicial + Curso (Ej: Pedro, dam2 -> pdam2)
    set "login=!inicial!!curso!"
    
    :: Convertimos login a minusculas (estético, opcional en batch pero recomendable)
    :: (En batch puro es complejo, asumimos que entra bien o AD lo acepta igual)

    :: --- CONFIGURAR ESTADO (HABILITADO/DESHABILITADO) [cite: 39] ---
    set "estado=yes"
    if /i "!habilitar!"=="SI" (
        set "estado=no"
        set /a total_habilitados+=1
    )
    
    :: --- CREACION DEL USUARIO ---
    :: -pwd abc123: Contraseña fija [cite: 40]
    :: -memberof: Añadir al grupo del curso [cite: 39]
    :: -profile: Perfil móvil [cite: 41]
    :: -desc: Descripción personalizada [cite: 42]
    :: -disabled: Según columna 3
    
    echo Creando usuario: !login! (!nombre!) en grupo !curso!...
    
    dsadd user "cn=!login!,ou=EXAMEN,dc=dominio,dc=local" ^
        -samid !login! ^
        -pwd abc123 ^
        -memberof "cn=!curso!,ou=EXAMEN,dc=dominio,dc=local" ^
        -profile "\\servidor\perfiles\!login!" ^
        -desc "Usuario del curso !curso!" ^
        -disabled !estado! ^
        -mustchpwd no ^
        -canchpwd no
        
    if !errorlevel! EQU 0 (
        echo [OK] Usuario !login! creado correctamente.
        set /a total_usuarios+=1
    ) else (
        echo [ERROR] No se pudo crear el usuario !login!.
    )
)

:: 4. Mensaje final con resumen [cite: 43, 44]
echo.
echo ======================================================================
echo Se han creado %total_usuarios% usuarios de los cuales %total_habilitados% han quedado habilitados.
echo ======================================================================

:FIN
pause