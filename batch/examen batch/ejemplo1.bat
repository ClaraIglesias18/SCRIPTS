@echo off
set n=0
set suma=0

:empieza

set /a n=%n% + 1

if %n% equ 11 (
	goto fin
)else (
	set /a suma=%suma%+%n%
	goto empieza
)

:fin
echo %suma%