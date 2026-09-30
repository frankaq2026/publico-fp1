@echo off
REM definición de entorno local de ejecución
setlocal enabledelayedexpansion

REM limpieza de pantalla
cls

REM definición de ficheros importantes
set "fichero_txt=preguntas.txt"


REM función de chequeo
CALL :Funcion_Comprobacion_Inicial
if "%Error%"=="1" (
	GOTO Funcion_Ayuda
	) else (
		CALL :Funcion_Borra_Ficheros
		CALL :Funcion_Comprobacion_Estructura
		CALL :Funcion_Reordena_Preguntas
		CALL :Funcion_Conversion_Ascci2html
		CALL :Funcion_Reordenacion
		CALL :Funcion_Txt2Html
	)
GOTO Funcion_Fin

:Funcion_Txt2Html
REM Se trata de leer el fichero 4 temporal y llevarlo a la versión definitiva html
REM con su hoja de estilo y javascript correspondiente
set fichero_tmp=%fichero_txt:~0,-4%
set fichero_tmp4=%fichero_tmp%4.tmp
set fichero_htm=%fichero_tmp%.html

echo ^<!DOCTYPE html^>  > %fichero_htm%
echo ^<html lang="es"^> >>  %fichero_htm%
echo ^<head^> >>  %fichero_htm%
echo ^<meta charset="utf-8"^>  >>  %fichero_htm% 
echo ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>  >>  %fichero_htm%
echo ^<title^>Formulario de Preguntas^</title^>  >>  %fichero_htm%

echo  ^<style^>     >>  %fichero_htm%
echo            h1 {      >>  %fichero_htm%
echo                color: white;      >>  %fichero_htm%
echo                background-color: lightgreen;      >>  %fichero_htm%
echo                padding: 5px;     >>  %fichero_htm%
echo                border: 1px solid black;      >>  %fichero_htm%
echo            }      >>  %fichero_htm%
echo            h2 {      >>  %fichero_htm%
echo                color: black;      >>  %fichero_htm%
echo                padding: 5px;      >>  %fichero_htm%
echo                border: 1px solid black;      >>  %fichero_htm%
echo            }      >>  %fichero_htm%
echo            ol {      >>  %fichero_htm%
echo                color: black;       >>  %fichero_htm%
echo                background-color: white;      >>  %fichero_htm%
echo            }   >>  %fichero_htm%
echo            .correcto {        >>  %fichero_htm%
echo                background-color: green;      >>  %fichero_htm%  
echo            }     >>  %fichero_htm%
echo            .incorrecto {        >>  %fichero_htm%
echo                background-color: red;        >>  %fichero_htm%
echo            }     >>  %fichero_htm%
echo            .box {  >>  %fichero_htm%
echo                  box-shadow: 0 3px 3px rgba(0,0,0,0.2);  >>  %fichero_htm%
echo            }   >>  %fichero_htm%
echo            .shadow-5 {  >>  %fichero_htm%
echo                  box-shadow: 0 1px 1px rgba(0,0,0,0.12),   >>  %fichero_htm%
echo                  0 2px 2px rgba(0,0,0,0.12),   >>  %fichero_htm%
echo                  0 4px 4px rgba(0,0,0,0.12),   >>  %fichero_htm%
echo                  0 8px 8px rgba(0,0,0,0.12),  >>  %fichero_htm%
echo                  0 16px 16px rgba(0,0,0,0.12);  >>  %fichero_htm%
echo            }  >>  %fichero_htm%
echo            .indice1 {  >>  %fichero_htm%
echo            }  >>  %fichero_htm%
echo            .indice2 {  >>  %fichero_htm%
echo            }	  >>  %fichero_htm%
echo ^</style^>  >>  %fichero_htm%

echo ^<body^> >>  %fichero_htm%
echo     ^<h1 class="shadow-5"^>Formulario de Preguntas^</h1^> >>  %fichero_htm%
echo     ^<form id="quizForm"^> >>  %fichero_htm%

set contador=1
set contadorPregunta=1
set "indice_color=indice1"
set indice_estilo=0

for /f "tokens=*" %%a in (%fichero_tmp4%) do (
    set "line=%%a"
    if "!line:~0,8!"=="PREGUNTA" (
        set "pregunta=!line:~9!"
        echo     ^<h2 class="box"^>!pregunta!^</h2^> >>  %fichero_htm%
        echo      ^<ol type="a"^> >>  %fichero_htm%
        set contadorPregunta=1
    ) else if "!line:~0,9!"=="RESPUESTA" (
        set /a "indice_estilo=!contadorPregunta! %% 2"
        set "respuesta=!line:~11!"
        if "!indice_estilo!"=="0" (
            set "indice_color=indice1"
        ) else (
            set "indice_color=indice2"
        )
        echo         ^<li class="!indice_color!"^>^<input type="radio" name="q!contador!" value="!contadorPregunta!"^> !respuesta!^</li^> >>  %fichero_htm%
        set /a "contadorPregunta+=1"
	) else if "!line:~0,6!"=="VALIDA" (
		echo      ^</ol^> >>  %fichero_htm%
		REM --- extraer valor correcto y quitar todos los espacios
		set "respuesta_valida=!line:~7!"
		set "respuesta_valida=!respuesta_valida: =!"
		echo     ^<input type="hidden" name="valida!contador!" value="!respuesta_valida!"^> >>  %fichero_htm%
		echo     ^<input type="hidden" name="totalq!contador!" value="!contadorPregunta!"^> >>  %fichero_htm%
		set /a contador+=1
		set "indice_color=indice1"
	)
)

echo   ^<hr^>  >>  %fichero_htm% 
echo   ^<input type="hidden" name="totalPreguntas" value="!contador!"^>  >>  %fichero_htm%
echo   ^<button type="button" onclick="verificarRespuestas()"^>Enviar^</button^>  >>  %fichero_htm%
echo   ^<input type="reset" onclick="window.location.reload();"^>  >>  %fichero_htm%
echo   ^</form^>  >>  %fichero_htm%

echo ^<script^>     >>  %fichero_htm%

echo function verificarRespuestas() { >>  %fichero_htm%
echo   const Meta_Preguntas = document.getElementsByName("totalPreguntas"); >>  %fichero_htm%
echo   let num_total_preguntas = Meta_Preguntas[0].value; >>  %fichero_htm%
echo   const valida = "valida"; >>  %fichero_htm%
echo   const pregunta = "q"; >>  %fichero_htm%
echo   let Preguntas_Constestadas = Verifica_Preguntas(num_total_preguntas); >>  %fichero_htm%
echo   let respuestas_formulario = 0; >>  %fichero_htm%
echo   for (let ind=1; ind ^<= num_total_preguntas-1; ind++) { >>  %fichero_htm%
echo     let pregunta_tmp = document.getElementsByName(pregunta + ind); >>  %fichero_htm%
echo     let respuesta_tmp = document.getElementsByName(valida + ind); >>  %fichero_htm%
echo     respuestas_formulario += verificarRespuesta(pregunta_tmp, respuesta_tmp[0].value); >>  %fichero_htm%
echo   } >>  %fichero_htm%
echo   alert('Numero de preguntas : ' + (num_total_preguntas - 1) + '\n' + 'Preguntas contestadas : ' + Preguntas_Constestadas + '\n' + 'Preguntas no contestadas : ' + (num_total_preguntas - Preguntas_Constestadas -1 )  + '\n' + 'Preguntas acertadas : ' + respuestas_formulario + '\n' + 'Preguntas falladas : ' + (Preguntas_Constestadas - respuestas_formulario)); >>  %fichero_htm%
echo } >>  %fichero_htm%

echo function verificarRespuesta(respuestas, respuestaCorrecta) { >>  %fichero_htm%
echo   let correctas = 0; >>  %fichero_htm%
echo   for (let i=0;i^<respuestas.length;i++) { >>  %fichero_htm%
echo     if (respuestas[i].checked) { >>  %fichero_htm%
echo       if (respuestas[i].value === respuestaCorrecta) { >>  %fichero_htm%
echo         respuestas[i].insertAdjacentHTML("afterend","<span class='correcto'> BIEN </span>"); >>  %fichero_htm%
echo         correctas++; >>  %fichero_htm%
echo       } else { >>  %fichero_htm%
echo         respuestas[i].insertAdjacentHTML("afterend","<span class='incorrecto'> MAL </span>"); >>  %fichero_htm%
echo         for (let j=0;j^<respuestas.length;j++) { >>  %fichero_htm%
echo           if (respuestas[j].value === respuestaCorrecta) { >>  %fichero_htm%
echo             respuestas[j].insertAdjacentHTML("afterend","<span class='correcto'> BIEN </span>"); >>  %fichero_htm%
echo             break; >>  %fichero_htm%
echo           } >>  %fichero_htm%
echo         } >>  %fichero_htm%
echo       } >>  %fichero_htm%
echo     } >>  %fichero_htm%
echo   } >>  %fichero_htm%
echo   return correctas; >>  %fichero_htm%
echo } >>  %fichero_htm%

echo function Verifica_Preguntas(num_total_preguntas){ >>  %fichero_htm%
echo   let total = 0; >>  %fichero_htm%
echo   for (let ind=1; ind ^<= num_total_preguntas-1; ind++){ >>  %fichero_htm%
echo     let opciones = document.getElementsByName("q"+ind); >>  %fichero_htm%
echo     for (let i=0;i^<opciones.length;i++){ >>  %fichero_htm%
echo       if(opciones[i].checked){ total++; break; } >>  %fichero_htm%
echo     } >>  %fichero_htm%
echo   } >>  %fichero_htm%
echo   return total; >>  %fichero_htm%
echo } >>  %fichero_htm%

echo ^</script^> >>  %fichero_htm%
echo ^</body^> >>  %fichero_htm%
echo ^</html^> >>  %fichero_htm%


REM FIN FUNCION
exit /B


:SubFuncion_Ordenacion_Fichero_Temporal
REM se definen los ficheros a usar 
set fichero_tmp=%fichero_txt:~0,-4%
set fichero_tmp1=%fichero_tmp%1.tmp
set fichero_tmp2=%fichero_tmp%2.tmp
set fichero_tmp3=%fichero_tmp%3.tmp
set fichero_tmp4=%fichero_tmp%4.tmp

set orden_de_respuestas=0
set orden_de_preguntas=0

for /f "tokens=*" %%a in (%fichero_tmp3%) do (
	set "linea=%%a"
	if "!linea:~0,8!"=="PREGUNTA" (
		echo %%a >> %fichero_tmp4%
		set /a "orden_de_preguntas+=1"
	) else if  "!linea:~0,9!"=="RESPUESTA" (
		set "no_orden=!linea:~9,1!"
		set "respuesta_no_ordenada[!no_orden!]=!linea:~11!"
		set /a "orden_de_respuestas+=1"
        REM echo "respuesta_no_ordenada[!no_orden!]=!linea:~11!"
	) else if "!linea:~0,6!"=="VALIDA" (
		REM echo VALOR :  !respuesta_no_ordenada[1]!
		for /L %%p in (1,1,!orden_de_respuestas!) do (
REM			echo Mostrando Pregunta num !orden_de_preguntas! orden de Respuesta %%p !respuesta_no_ordenada[%%p]! >> %fichero_tmp4% 
			echo RESPUESTA%%p:!respuesta_no_ordenada[%%p]! >> %fichero_tmp4% 
		)
		
		echo %%a >> %fichero_tmp4% 
		set orden_de_respuestas=0
	)

)

REM FIN SUBFUNCION
exit /B


:SubFuncion_Reordenacion_PreFinal
REM se definen los ficheros a usar 
set fichero_tmp=%fichero_txt:~0,-4%
set fichero_tmp1=%fichero_tmp%1.tmp
set fichero_tmp2=%fichero_tmp%2.tmp
set fichero_tmp3=%fichero_tmp%3.tmp

REM inicializacion de contador
set contador_respuestas=1
set contador_preguntas=1
set indice_random=1
set contador_interno=1
set nuevo_orden=1


REM se lee el fichero tmp 2 , que contiene el indice de las respuestas cambiados
for /f "tokens=*" %%b in (%fichero_tmp2%) do (
	set "linea[!indice_random!]=%%b"
	set /a "indice_random+=1"
)

for /f "tokens=*" %%a in (%fichero_tmp1%) do (
	set "linea=%%a"
	if "!linea:~0,8!"=="PREGUNTA" (
		echo %%a >> %fichero_tmp3%
		for /L %%k in (1,1,!indice_random!) do (
		    if "%%k"=="!contador_preguntas!" (
			   set "orden_aleatorio=!linea[%%k]!"
			   ) 
		)
			set "orden_aleatorio=!orden_aleatorio:~0,-1!"
			REM echo Pregunta !contador_preguntas! con orden aleatorio !orden_aleatorio!

	) else if  "!linea:~0,9!"=="RESPUESTA" (
		for %%l in (!orden_aleatorio!) do (
			if "!contador_interno!"=="!contador_respuestas!" (
				set nuevo_orden=%%l
			)
			set /a "contador_interno+=1"
		)	
		echo !linea:~0,9!!nuevo_orden!!linea:~10! >> %fichero_tmp3%
		set /a "contador_respuestas+=1"
		set contador_interno=1
		
	) else if "!linea:~0,6!"=="VALIDA" (

		set "respuestas_validas=!linea:~7,1!"
		for %%l in (!orden_aleatorio!) do (
			if "!contador_interno!"=="!respuestas_validas!" (
				set nueva_respuesta=%%l
			)
			set /a "contador_interno+=1"
		)	
		echo !linea:~0,7!!nueva_respuesta! >> %fichero_tmp3%
		set contador_respuestas=1
		set contador_interno=1
		set /a "contador_preguntas+=1"
	)

)

CALL :SubFuncion_Ordenacion_Fichero_Temporal

REM FIN SUBFUNCION
exit /B


:SubFuncion_Reordenacion_Tmp
REM se recibe como segundo parametro una cadena con inicio y final de comilla, no utiles para el procesamiento que quiere hacerse
set cadena=%2
set lista_tmp_random=%cadena:~1,-1%


REM por otro lado se genera un segundo fichero temporal donde ira el nuevo orden de las preguntas
set fichero_tmp=%fichero_txt:~0,-4%
set fichero_tmp=%fichero_tmp%2.tmp

REM Se cuentan los elementos que conforman ese segundo parametro, util para su uso posterior
set count=0
for %%a in (!lista_tmp_random!) do (
    set /a count+=1
)
REM se genera el primer valor aleatorio dentro del intervalo de numeros indicados por 'lista_tmp_random'
set /a "valor_inicial=%RANDOM% %% count" + 1

REM se va a utilizar un bucle doble y por ello hay que definir una serie de Flags o banderas de control
REM Flag de valor encontrado en la nueva lista
set flag_repetido=0

REM nueva lista reordenada
set "nueva_lista="

REM indice de bucle
set bucle_ind=0
set contador=1

:_bucle_while
REM el primer valor generado de manera aleatoria no se repite, 
if "%bucle_ind%"=="0" (
	set "nueva_lista=!valor_inicial!"
	)
:_bucle_correccion
set /a "valor_inicial=%RANDOM% %% count" + 1

for %%k in (%nueva_lista%) do (
    if "%%k"=="%valor_inicial%" (
		REM Si se encuentran valores repetidos hay que activar la alerta
		set "flag_repetido=1"
		) 
)

REM Control de la alerta
if NOT "!flag_repetido!"=="1" (
REM Asignacion del orden numerico generado aleatorio
		set "nueva_lista=%nueva_lista% !valor_inicial!"
		set /a contador+=1
)

set fuerza_valor=0
set flag_repetido=!fuerza_valor!
set /a bucle_ind+=1

REM se fuerza a volver al inicio del bucle interno de ser necesario
if "%bucle_ind%" LSS "%count%" goto _bucle_while
set /a "bucle_ind=%contador% + 1"

REM se fuerza a volver al inicio del bucle externo de ser necesario
if "%contador%" LSS "%count%" goto _bucle_correccion

REM echo Regenera_custionario_aleatorio %1 "!nueva_lista!"
echo Cambiando el orden de las preguntas en la pregunta %1
echo !nueva_lista! >> %fichero_tmp%

REM FIN SUBFUNCION
exit /B


:Funcion_Reordenacion
REM en esta parte se hace uso del fichero creado en la funcion 'Funcion_Conversion_Ascci2html' 
set fichero_tmp=%fichero_txt:~0,-4%
set fichero_tmp=%fichero_tmp%1.tmp

REM esta parte de delicada, por un lado va a obtener el valor de las preguntas y respuestas 
REM pero por otra, va a reordendar las respuestas dentro de cada PREGUNTA

set conta_R=0
set conta_P=0
set conta_RT=0
set conta_E=0

REM se empieza como siempre contando preguntas y respuestas
REM cuando el bucle detecta la opcion de VALIDA invoca una subfuncion para reordenar las respuestas
REM lo que a su vez, fuerza a reescribir en el fichero temporal de salida, la linea de VALIDA para indicar la nueva
REM posicion
REM se le pasa como parametros el numero de la pregunta, y en un array, el indice de cada respuesta.

for /f "tokens=*" %%a in (%fichero_tmp%) do (
    set "linea=%%a"
    if "!linea:~0,8!"=="PREGUNTA" (
		set /a conta_P+=1
		set "lista_tmp="
	) else if "!linea:~0,9!"=="RESPUESTA" (
	    set /a conta_R+=1
		set /a conta_RT+=1
		set pregunta_!conta_P!=!conta_R!
		set "var_tmp=!linea:~9,1!"
		set "valor_tmp=!var_tmp!"
		set "lista_tmp=!lista_tmp! !valor_tmp!"
	) else if "!linea:~0,6!"=="VALIDA" (
	   set "lista_tmp=!lista_tmp:~1!"
	   CALL :SubFuncion_Reordenacion_Tmp !conta_P! "!lista_tmp!"
	   set conta_R=0	   
	) else (
	   set conta_E=1
	)
)

REM esta reordinacion lee el fichero 1 y 2 temporales , y reordena en el fichero 3 a la vez que reescribe la pregunta valida.
CALL :SubFuncion_Reordenacion_PreFinal

REM FIN FUNCION
exit /B


:Funcion_Conversion_Ascci2html
REM Convierte todos los codigos latinos a su equivalente en codigo html
set fichero_tmp=%fichero_txt:~0,-4%
set fichero_tmp=%fichero_tmp%1.tmp

REM Defino mapeo de caracteres
set "á=&aacute;"
set "é=&eacute;"
set "í=&iacute;"
set "ó=&oacute;"
set "ú=&uacute;"
set "ñ=&ntilde;"
set "Á=&Aacute;"
set "É=&Eacute;"
set "Í=&Iacute;"
set "Ó=&Oacute;"
set "Ú=&Uacute;"
set "Ñ=&Ntilde;"
set "¿=&iquest;"

REM Leer archivo de entrada y reemplazar caracteres; usebackq para manejo de caracteres especiales
(for /f "usebackq delims=" %%a in ("%fichero_txt%") do (
    set "linea=%%a"
    set "linea=!linea:á=%á%!"
    set "linea=!linea:é=%é%!"
    set "linea=!linea:í=%í%!"
    set "linea=!linea:ó=%ó%!"
    set "linea=!linea:ú=%ú%!"
    set "linea=!linea:ñ=%ñ%!"
	set "linea=!linea:Á=%Á%!"
    set "linea=!linea:É=%É%!"
    set "linea=!linea:Í=%Í%!"
    set "linea=!linea:Ó=%Ó%!"
    set "linea=!linea:Ú=%Ú%!"
    set "linea=!linea:Ñ=%Ñ%!"
	set "linea=!linea:¿=%¿%!"
    echo !linea!
)) > "%fichero_tmp%"

REM FIN FUNCION
exit /B


:Funcion_Comprobacion_Estructura
REM Revisa el fichero buscando el numero de preguntas y respuestas
echo ------
echo RESUMEN DE PREPROCESAMIENTO
echo ------ 

REM declaracion de variables
set conta_R=0
set conta_P=0
set conta_RT=0
set conta_E=0

for /f "tokens=*" %%a in (%fichero_txt%) do (
    set "linea=%%a"
    if "!linea:~0,8!"=="PREGUNTA" (
		set /a conta_P+=1
		set "lista_tmp="
	) else if "!linea:~0,9!"=="RESPUESTA" (
	    set /a conta_R+=1
		set /a conta_RT+=1
		set pregunta_!conta_P!=!conta_R!
		set "var_tmp=!linea:~9,1!"
		set "valor_tmp=!var_tmp!"
		set "lista_tmp=!lista_tmp! !valor_tmp!"
	) else if "!linea:~0,6!"=="VALIDA" (
	   set conta_R=0	   
	) else (
	   set conta_E=1
	)
)
REM Numero de pregunta totales

if "!conta_P!"=="0" (
    echo Se ha producido un error revisando la estructura del fichero %fichero_txt%. Por favor revise el fichero fuente
	echo Se redirige al menu de ayuda
	pause
	GOTO Funcion_Ayuda
) else if NOT "!conta_E!"=="0" (
    echo Se ha producido un error revisando la estructura del fichero %fichero_txt%. Por favor revise el fichero fuente
	echo Se redirige al menu de ayuda
	pause
	GOTO Funcion_Ayuda
) else (
       echo ------
       echo SE HAN ENCONTRADO
       echo TOTAL PREGUNTAS %conta_P% 
       REM Se muestran las preguntas encontradas
       echo TOTAL RESPUESTAS %conta_RT%
       REM Se muestran las respuestas TOTALES y si hay errores
       echo TOTAL ERRORES %conta_E%
       echo ------
       echo PROCESANDO FICHEROS.. POR FAVOR, ESPERE
       echo.
	)

REM FIN FUNCION
exit /B


:SubFuncion_Borrar_Temporales
REM eliminación de los ficheros temporales creados durante el proceso
REM preguntas1.tmp
REM preguntas2.tmp
REM preguntas3.tmp
REM preguntas4.tmp

set "fichero_tmp=%fichero_txt:~0,-4%"

set "fichero_tmp1=!fichero_tmp!1.tmp"
set "fichero_tmp2=!fichero_tmp!2.tmp"
set "fichero_tmp3=!fichero_tmp!3.tmp"
set "fichero_tmp4=!fichero_tmp!4.tmp"

echo.

if exist "%fichero_tmp1%" (
   echo El fichero %fichero_tmp1% ha sido encontrado y será borrado.
   del /Q "%fichero_tmp1%" > nul
)

if exist "%fichero_tmp2%" (
   echo El fichero %fichero_tmp2% ha sido encontrado y será borrado.
   del /Q "%fichero_tmp2%" > nul
)

if exist "%fichero_tmp3%" (
   echo El fichero %fichero_tmp3% ha sido encontrado y será borrado.
   del /Q "%fichero_tmp3%" > nul
)

if exist "%fichero_tmp4%" (
   echo El fichero %fichero_tmp4% ha sido encontrado y será borrado.
   del /Q "%fichero_tmp4%" > nul
)

REM FIN SUBFUNCION 
exit /B


:Funcion_Borra_Ficheros
REM Dado que es el principio del script se procede a borrar los ficheros que se van a generar. 
REM Con vistas a evitar sobreescrituras o errores

REM eliminación del fichero html preguntas
if exist "%fichero_htm%" (
   echo El fichero %fichero_htm% ha sido encontrado y será borrado.
   del /Q "%fichero_htm%" > nul
)

REM Eliminacion de ficheros temporales
CALL :SubFuncion_Borrar_Temporales

REM FIN FUNCION 
exit /B


:Funcion_Ayuda
REM Se muestra por pantalla una breve ayuda y finaliza la ejecucion del script
cls
echo Para el correcto uso de este script, debe existir un fichero llamado preguntas.txt
echo si el fichero no existe, debera crearlo para que este script funcione de manera adecuada
echo la estructura de este fichero estara compuestas de una linea que sera la PREGUNTA
echo varias lineas - hasta un maximo de 8 - de posibles respuestas
echo y finalmente un linea, que sera la indicacion de cual de las respuestas es la VALIDA
echo este fichero debe estar en el mismo directorio del este aplicativo.
echo PREGUNTA: --texto de la pregunta--
echo RESPUESTA1: --y texto de la respuesta 1--
echo RESPUESTA2: --y texto de la respuesta 2--
echo RESPUESTA3: --y texto de la respuesta 3--
echo RESPUESTA4: --y texto de la respuesta 4--
echo VALIDA:2 , se indicara que la respuesta2 es la respuesta correcta a la pregunta
echo para insertar la siguiente cuestion puede dejar un salto de linea
echo como ejemplo puede ver la siguiente construccion
echo.
echo PREGUNTA:Cual es la capital de Francia?
echo RESPUESTA1:Madrid
echo RESPUESTA2:Paris 
echo RESPUESTA3:Roma 
echo RESPUESTA4:Berlin
echo VALIDA:1
echo. 
echo PREGUNTA:Cual es el rio mas largo del mundo?
echo RESPUESTA1:Nilo
echo RESPUESTA2:Misisipi
echo RESPUESTA3:Amazonas 
echo VALIDA:2
echo.

REM FIN FUNCION 
GOTO Funcion_Fin


:Funcion_Comprobacion_Inicial
REM comprobar si existe fichero 'preguntas.txt'
REM si no existe muestra por pantalla CMD pequeño menu de ayuda

if NOT exist "%fichero_txt%" (
    echo Fichero %fichero_txt% no existe. Por favor genere uno.
	echo Pulse una tecla para continuar para mostrar ayuda
	set Error=1
	pause > nul
)

REM FIN FUNCION 
exit /B

:Funcion_Reordena_Preguntas

REM para comprobar que se copia aleatoriamente, copia del original
type preguntas.txt > preguntas_original.txt

REM Archivo original
set "INPUT=preguntas.txt"
REM Carpeta temporal para bloques
set "TEMP_DIR=%TEMP%\preguntas_shuffle"
REM Archivo resultado
set "OUTPUT=preguntas_mezcladas.txt"

REM Limpiar carpeta temporal si existe
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM Contador de bloques
set /a count=0
set "blockfile="

REM Leer el archivo línea por línea y guardar bloques en archivos separados
for /f "usebackq delims=" %%L in ("%INPUT%") do (
    set "line=%%L"
    if "!line:~0,9!"=="PREGUNTA:" (
        REM Nuevo bloque, aumentar contador y crear archivo nuevo
        set /a count+=1
        set "blockfile=%TEMP_DIR%\block!count!.txt"
        > "!blockfile!" echo(!line!
    ) else (
        REM Añadir línea al archivo actual
        >> "!blockfile!" echo(!line!
    )
)

REM Crear lista de índices
setlocal enabledelayedexpansion
set "indices="
for /L %%i in (1,1,%count%) do set "indices=!indices! %%i"
endlocal & set "indices=%indices%"

REM Barajar lista de índices
setlocal enabledelayedexpansion
set "list=%indices%"
set "shuffled="

:shuffle_loop
if "%list%"=="" goto shuffle_done

set /a len=0
for %%x in (%list%) do set /a len+=1

set /a r=(%random% %% len) + 1

set /a i=0
for %%x in (%list%) do (
    set /a i+=1
    if !i! equ %r% set "chosen=%%x"
)

set "shuffled=!shuffled! !chosen!"

set "newlist="
for %%x in (%list%) do (
    if not %%x==!chosen! set "newlist=!newlist! %%x"
)
set "list=!newlist!"

goto shuffle_loop
:shuffle_done

REM Volcar bloques mezclados en archivo final, con salto entre bloques
> "%OUTPUT%" (
    for %%i in (%shuffled%) do (
        type "%TEMP_DIR%\block%%i.txt"
        echo.
    )
)

REM Limpiar temporales
rd /s /q "%TEMP_DIR%"

REM fichero preguntas.txt se reescribe con la reordinación
type preguntas_mezcladas.txt > preguntas.txt
del /Q preguntas_mezcladas.txt


REM FIN FUNCION
exit /B


:Funcion_Fin
REM se invoca la limpieza de temporales antes de finalizar el script
CALL :SubFuncion_Borrar_Temporales
endlocal
echo pulse cualquier tecla para cerrar esta ventana
pause > nul
rem exit