@echo off
REM Comprueba que se ha pasado un parámetro
if "%~1"=="" (
    echo Uso: procesa nombre_archivo.txt
    exit /b
)

REM Guarda el nombre sin extensión
set "NOMBRE=%~n1"

REM Copia el contenido a preguntas.txt
copy "%~1" preguntas.txt >nul

REM Ejecuta el otro batch
call conversor_v3.bat

REM Renombra preguntas.html a preguntas-x.html
if exist preguntas.html (
    ren preguntas.html "preguntas-%NOMBRE%.html"
)

REM Borra preguntas.txt
del preguntas.txt
del preguntas_original.txt