@echo off
setlocal enabledelayedexpansion

:: =================================================================
:: CONFIGURACIÓN INICIAL Y DE ENTIDAD
:: =================================================================

:: Define el dominio base. AJUSTA ESTO A TU DOMINIO REAL
set "dominio=dc=dominio,dc=local"

:: Variables para conteo
set /a usuarios_count=0
set /a profesor_count=0
set /a alumno_count=0


:: =================================================================
:: 1. CREACIÓN DE UNIDADES ORGANIZATIVAS (UO) JERÁRQUICAS
:: =================================================================

echo #################################################
echo # 1. CREACIÓN DE UNIDADES ORGANIZATIVAS
echo #################################################

:: --- UO: Usuarios ---
set "ou_usuarios=ou=Usuarios,%dominio%"
echo.
echo Intentando crear UO: %ou_usuarios%...
dsadd ou "%ou_usuarios%"
if errorlevel 1 (
    echo [ERROR] No se pudo crear la UO %ou_usuarios%. Puede que ya exista.
) else (
    echo [INFO] UO creada correctamente.
)

:: --- UO: Profesores ---
set "ou_profesores=ou=Profesores,%ou_usuarios%"
echo.
echo Intentando crear UO: %ou_profesores%...
dsadd ou "%ou_profesores%"
if errorlevel 1 (
    echo [ERROR] No se pudo crear la UO %ou_profesores%.
) else (
    echo [INFO] UO creada correctamente.
)

:: --- UO: Alumnos ---
set "ou_alumnos=ou=Alumnos,%ou_usuarios%"
echo.
echo Intentando crear UO: %ou_alumnos%...
dsadd ou "%ou_alumnos%"
if errorlevel 1 (
    echo [ERROR] No se pudo crear la UO %ou_alumnos%.
) else (
    echo [INFO] UO creada correctamente.
)

:: --- UO: ASIR1 ---
set "ou_asir1=ou=ASIR1,%ou_alumnos%"
echo.
echo Intentando crear UO: %ou_asir1%...
dsadd ou "%ou_asir1%"
if errorlevel 1 (
    echo [ERROR] No se pudo crear la UO %ou_asir1%.
) else (
    echo [INFO] UO creada correctamente.
)

:: --- UO: ASIR2 ---
set "ou_asir2=ou=ASIR2,%ou_alumnos%"
echo.
echo Intentando crear UO: %ou_asir2%...
dsadd ou "%ou_asir2%"
if errorlevel 1 (
    echo [ERROR] No se pudo crear la UO %ou_asir2%.
) else (
    echo [INFO] UO creada correctamente.
)


:: =================================================================
:: 2. CREACIÓN DE GRUPOS
:: =================================================================

echo.
echo #################################################
echo # 2. CREACIÓN DE GRUPOS
echo #################################################

:: --- Grupo: Profesores_AD ---
echo Intentando crear grupo Profesores...
dsadd group "cn=profesores, %ou_profesores%" -desc "Grupo de profesores
if errorlevel 1 (
    echo [ERROR] No se pudo crear el grupo %nombre_grupo_profesores%.
) else (
    echo [INFO] Grupo %nombre_grupo_profesores% creado correctamente.
)

:: --- Grupo: Alumnos_ASIR ---

echo Intentando crear grupo Alumnos...
dsadd group "cn=alumnos, %ou_alumnos%" -desc "Grupo de alumnos"
if errorlevel 1 (
    echo [ERROR] No se pudo crear el grupo %GROUP_NAME_ALUMNO%.
) else (
    echo [INFO] Grupo %GROUP_NAME_ALUMNO% creado correctamente.
)

set "DN_GRUPO_PROFESORES=cn=profesores,%ou_profesores%"
set "DN_GRUPO_ALUMNOS=cn=alumnos,%ou_alumnos%"




:: =================================================================
:: 3. PROCESAMIENTO DE PARÁMETROS (CREACIÓN DE USUARIOS)
:: =================================================================
echo.
echo #################################################
echo # 3. CREACIÓN Y CONFIGURACIÓN DE USUARIOS
echo #################################################

:: FOR /F: Lee el archivo. tokens=1,2 asigna la primera columna a %%a y la segunda a %%b. delims=, usa la coma como separador.
for /f "tokens=1,2,3 delims=," %%a in (%1) do (
    
    set "login=%%a"
    set "tipo=%%b"
    set "nombre=%%a"
    set "asir=%%c" 

    :: 3a. Determinar UO y Grupo (No se necesita GOTO, es secuencial)
    
    echo OK

    set "ou_destino="
    set "grupo_destino="

    echo OK

    if /i "!tipo!"=="Profesor" (
        set "ou_destino=%ou_profesores%"
        set "grupo_destino=%DN_GRUPO_PROFESORES%"
        set /a profesor_count+=1
    ) else if /i "!tipo!"=="Alumno" (
        if /i "!asir!"=="ASIR1" (
            set "ou_destino=%ou_asir1%"
            set "grupo_destino=%DN_GRUPO_ALUMNOS%"
            set /a alumnos_count+=1
        ) else if /i "!asir!"=="ASIR2" (
            set "ou_destino=%ou_asir2%"
            set "grupo_destino=%DN_GRUPO_ALUMNOS%"
            set /a alumnos_count+=1
        ) else (
            echo [ADVERTENCIA] Sub-rol (!asir!) no reconocido para !login!. Saltando usuario.
            goto :skip_user
        )
        
    ) else (
        echo [ADVERTENCIA] Rol (!tipo!) no reconocido para !login!. Saltando usuario.
        goto :skip_user
    )

    :: 3b. Preguntar si se desea deshabilitar (Aún requerimos interacción aquí)
    :habilitar
    set "disable_flag="
    set /p disable_flag="¿Desea deshabilitar !login!? [S/N]: "

    if /i "!disable_flag!"=="S" (
        set "desahilitado=yes"
        dsadd user "cn=!login!,!ou_destino!" -disabled !desahilitado!
    ) else if /i "!disable_flag!"=="N" (
        set "desahilitado=no"
        dsadd user "cn=!login!,!ou_destino!" -pwd "!login!" -disabled !desahilitado!
    ) else (
        echo [ADVERTENCIA] Opción no válida. Inténtelo de nuevo.
        goto :habilitar
    )
    
    :: 3c. Creación del usuario (Contraseña = Nombre de usuario, sin deshabilitar por defecto)
    echo Creando usuario !login! en !ou_destino!...
    
    
    
    if errorlevel 1 (
        echo [ERROR] Falló la creación de !login!.
    ) else (
        echo [INFO] Usuario !login! creado correctamente.
        set /a usuarios_count+=1
        set "USER_DN=cn=!login!,!ou_destino!"
        :: 3d. Añadir a grupo
        echo Añadiendo !login! al grupo !grupo_destino!...
        dsmod group "!grupo_destino!" -addmbr "!USER_DN!"
        if errorlevel 1 (
            echo [ERROR] No se pudo añadir el usuario !login! al grupo.
        ) else (
            echo [INFO] Usuario añadido al grupo correctamente.
        )
    )
    
    :skip_user
)

:: =================================================================
:: 4. INFORME FINAL
:: =================================================================

echo.
echo #################################################
echo # 4. INFORME DE CREACIÓN
echo #################################################
echo Se procesaron %INDEX% intentos de creación.
echo Total de usuarios creados exitosamente: %usuarios_count%
echo - Profesores creados: %profesor_count%
echo - Alumnos creados: %alumno_count%
echo Los detalles de los usuarios se encuentran en el archivo: %LOG_FILE%

:: =================================================================
:: 5. MOSTRAR LISTADO DE UO SOLICITADA
:: =================================================================

:ask_ou_list
echo.
echo #################################################
echo # 5. LISTADO DE USUARIOS
echo #################################################
set "ou_choice="
set /p ou_choice="¿De qué UO desea ver el listado de usuarios (Profesores/Alumnos/ASIR1/ASIR2)? [Escriba el nombre]: "

set "LIST_OU="

if /i "%ou_choice%"=="Profesores" set "LIST_OU=%ou_profesores%"
if /i "%ou_choice%"=="Alumnos" set "LIST_OU=%ou_alumnos%"
if /i "%ou_choice%"=="ASIR1" set "LIST_OU=%ou_asir1%"
if /i "%ou_choice%"=="ASIR2" set "LIST_OU=%ou_asir2%"

if defined LIST_OU (
    echo.
    echo Listando usuarios en: %LIST_OU%
    echo -----------------------------------------------------
    :: dsquery busca los usuarios y -name muestra el CN (Nombre Común)
    dsquery user "%LIST_OU%" -name
    if errorlevel 1 (
        echo [ADVERTENCIA] dsquery falló. Compruebe la ruta o que el servicio esté disponible.
    )
    goto :eof
) else (
    echo [ADVERTENCIA] Opción de UO no reconocida o ruta no definida.
    goto :ask_ou_list
)

endlocal