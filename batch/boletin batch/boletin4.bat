@echo off
setlocal

:: Nombre del archivo de datos pasado como parámetro
set "FICHERO=%~1"
set "CONTRASEÑA=abc123"
set "DESCRIPCION_BASE=examen de tunombre"

:: Contadores para el informe final
set /a OU_CREADAS=0
set /a GRUPOS_CREADOS=0
set /a USUARIOS_CREADOS=0
set /a ERRORES=0

:: --- Verificación de parámetros y archivo ---
if "%FICHERO%"=="" (
    echo Error: Debes proporcionar el nombre del archivo de datos como parámetro.
    echo Uso: %~n0 nombre_archivo.txt
    set /a ERRORES+=1
    goto :fin
)

if not exist "%FICHERO%" (
    echo Error: El archivo "%FICHERO%" no existe.
    set /a ERRORES+=1
    goto :fin
)

echo.
echo =========================================================
echo Iniciando proceso de creacion de objetos en Active Directory
echo Archivo de datos: %FICHERO%
echo =========================================================
echo.

:: --- Proceso del archivo línea por línea ---
:: Se salta la primera línea (cabecera: UO;GRUPO;USUARIOS)
for /f "skip=1 tokens=1-3 delims=;" %%a in ('type "%FICHERO%"') do (
    set "UO=%%a"
    set "GRUPO=%%b"
    set "LISTA_USUARIOS=%%c"
    
    echo ---------------------------------------------------------
    echo Procesando linea: UO=%%a, Grupo=%%b, Usuarios=%%c
    
    
    :: 1. Crear Unidad Organizativa (UO)
    echo.
    echo [UO] Creando UO: %%a
    dsadd ou "ou=%%a,dc=tudominio,dc=com" >nul 2>&1
    if errorlevel 1 (
        :: dsadd puede fallar si ya existe, no es necesariamente un error fatal.
        :: En un entorno real, se debería verificar si el error es de 'ya existe'
        :: Aquí asumimos que si falló, ya existe o hay otro problema.
        echo Advertencia o Error: No se pudo crear la UO '%%a'. (Puede que ya exista)
    ) else (
        echo UO '%%a' creada correctamente.
        set /a OU_CREADAS+=1
    )
    
    
    :: 2. Crear Grupo dentro de la UO
    echo.
    echo [GRUPO] Creando Grupo: %%b en UO '%%a'
    dsadd group "cn=%%b,ou=%%a,dc=tudominio,dc=com" -secgrp yes -scope global >nul 2>&1
    if errorlevel 1 (
        echo Advertencia o Error: No se pudo crear el Grupo '%%b'. (Puede que ya exista)
    ) else (
        echo Grupo '%%b' creado correctamente.
        set /a GRUPOS_CREADOS+=1
    )
    
    
    :: 3. Crear Usuarios y añadirlos al Grupo
    echo.
    echo [USUARIOS] Procesando usuarios para UO '%%a' y Grupo '%%b'
    
    :: Dividir la lista de usuarios (separados por coma)
    for %%u in (%%c) do (
        set "USUARIO=%%u"
        set "DN_USUARIO=cn=%%u,ou=%%a,dc=tudominio,dc=com"
        set "DN_GRUPO=cn=%%b,ou=%%a,dc=tudominio,dc=com"
        set "DESCRIPCION=examen de tunombre - %%u"
        
        echo   -> Creando usuario: %%u
        
        :: a) Crear usuario
        :: La contraseña es 'abc123'
        :: -mustchpwd no: el usuario no tiene que cambiar la contraseña en el próximo inicio de sesión
        :: -upn %USUARIO%@tudominio.com: User Principal Name
        :: -desc %DESCRIPCION%: La descripción solicitada
        dsadd user "!DN_USUARIO!" -pwd "%CONTRASEÑA%" -samid %%u -desc "!DESCRIPCION!" -mustchpwd no -upn %%u@tudominio.com >nul 2>&1
        
        if errorlevel 1 (
            echo   -> Advertencia o Error al crear usuario '%%u'. (Puede que ya exista)
        ) else (
            echo   -> Usuario '%%u' creado y listo para iniciar sesion (Contraseña: %CONTRASEÑA%)
            set /a USUARIOS_CREADOS+=1
            
            :: b) Agregar usuario al grupo
            echo   -> Añadiendo usuario '%%u' al grupo '%%b'
            dsmod group "!DN_GRUPO!" -addmbr "!DN_USUARIO!" >nul 2>&1
            if errorlevel 1 (
                echo   -> Error al añadir usuario '%%u' al grupo '%%b'.
            ) else (
                echo   -> Usuario '%%u' agregado al grupo '%%b' correctamente.
            )
        )
    )
)

:fin
echo.
echo =========================================================
echo Proceso finalizado.
echo =========================================================
echo Unidades Organizativas creadas correctamente: %OU_CREADAS%
echo Grupos creados correctamente: %GRUPOS_CREADOS%
echo Usuarios creados correctamente: %USUARIOS_CREADOS%
echo Errores y Advertencias (no críticos): %ERRORES%
echo.

endlocal
pause