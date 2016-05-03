#!/bin/bash
#Nombre del archivo: RecibirOfertas.sh
#       Descripcion: es el script encargado de detectar la llegada de archivos de novedades al directorio de arribos, y aceptar o rechazar estos archivos según corresponda.

#El proposito de este comando es detectar la llegada de archivos al directorio "$ARRIDIR" y aceptar o rechazar estos archivos según corresponda.
#Es el segundo en orden de ejecución.
#Es un proceso del tipo “Demonio”.
#Se dispara con "PrepararAmbiente" o a través del "LanzarProceso".
#Se detiene a través del "DetenerProceso".
#Mueve los archivos a través del "MoverArchivos".
#Graba en el archivo de Log a través del "GrabarBitacora".
#Invoca, si corresponde, el siguiente proceso: "ProcesarOfertas".

: <<'DEBUG'
#ESTO ES SOLO PARA DEPURAR EL PROGRAMA, QUITAR PARA LA INTEGRACIÓN:
declare EJECUTADOEN="/home/kubuntu/Documents/so2016/Grupo09/binarios/";
#Declaro las variables necesarias para poder probrar este script:
declare -x ARRIDIR="${EJECUTADOEN}../arribados";
declare -x BINDIR="${EJECUTADOEN}../binarios";
declare -x MAEDIR="${EJECUTADOEN}../maestros";
declare -x NOKDIR="${EJECUTADOEN}../rechazados";
declare -x OKDIR="${EJECUTADOEN}../aceptados";
declare -x SLEEPTIME=3;
#Declaro las variables necesarias para poder usar "GrabarBitacora":
declare -x LOGDIR="${EJECUTADOEN}../bitacoras";
declare -x LOGSIZE=4000;
DEBUG


#Declaro la constante que indica el nombre con el que este programa ingresa mensajes en el archivo de log.
declare -r NOMBRE_PROGRAMA="RecibirOfertas.sh";
#Declaro la constante que indica el nombre del archivo correspondiente al script "ProcesarOfertas" (lo necesito para buscarlo en la tabla de procesos).
declare -r PROCESAROFERTAS_ARCHIVO="ProcesarOfertas.sh";
#Declaro la constante que indica la ruta al script ProcesarOfertas.
declare -r PROCESAROFERTAS="${BINDIR}/${PROCESAROFERTAS_ARCHIVO}";
#Declaro las constantes que indican los nombres de los archivos maestros que este programa utiliza.
declare -r CONCESIONARIOS_ARCHIVO_NOMBRE="concesionarios.csv";
declare -r FECHAS_ADJ_ARCHIVO_NOMBRE="FechasAdj.csv";
#Declaro la constante que indica la ruta al archivo maestro de concesionarios.
declare -r CONCESIONARIOS_ARCHIVO="${MAEDIR}/${CONCESIONARIOS_ARCHIVO_NOMBRE}";
#Declaro la constante que indica la ruta al archivo maestro de fechas de adjudicación.
declare -r FECHAS_ARCHIVO="${MAEDIR}/${FECHAS_ADJ_ARCHIVO_NOMBRE}";
#Declaro la constante que indica la ruta al script que hace el logging.
declare -r LOGGER="${BINDIR}/GrabarBitacora.sh";
#Declaro la constante que indica la ruta al script que hace el movimiento de archivos.
declare -r MOVER="${BINDIR}/MoverArchivos.sh";

#Este script (o un script que lanza) necesita los archivos CONCESIONARIOS_ARCHIVO y FECHAS_ARCHIVO.
declare -r ARCHIVOS_NECESARIOS=(CONCESIONARIOS_ARCHIVO FECHAS_ARCHIVO LOGGER MOVER PROCESAROFERTAS);
declare -r ARCHIVOS_NECESARIOS_R=(CONCESIONARIOS_ARCHIVO FECHAS_ARCHIVO LOGGER MOVER PROCESAROFERTAS);
declare -r ARCHIVOS_NECESARIOS_X=(LOGGER MOVER PROCESAROFERTAS);

#Este script (o un script que lanza) necesita las variables ARRIDIR, BINDIR, MAEDIR, NOKDIR, OKDIR, SLEEPTIME, LOGDIR, y LOGSIZE.
declare -r VARIABLES_NECESARIAS=(ARRIDIR BINDIR MAEDIR NOKDIR OKDIR SLEEPTIME LOGDIR LOGSIZE);
#Este script (o un script que lanza) necesita los directorios ARRIDIR, BINDIR, MAEDIR, NOKDIR, OKDIR, y LOGDIR.
declare -r DIRECTORIOS_NECESARIOS=(ARRIDIR BINDIR MAEDIR NOKDIR OKDIR LOGDIR);
declare -r DIRECTORIOS_NECESARIOS_R=(ARRIDIR BINDIR MAEDIR NOKDIR OKDIR LOGDIR);
declare -r DIRECTORIOS_NECESARIOS_W=(ARRIDIR NOKDIR OKDIR LOGDIR);
declare -r DIRECTORIOS_NECESARIOS_X=(ARRIDIR BINDIR MAEDIR NOKDIR OKDIR LOGDIR);

: <<'LOGGEADOR'
Se encarga de llamar a "GrabarBitacora".
LOGGEADOR
function LOGGEADOR {
	"${LOGGER}" "${NOMBRE_PROGRAMA}" "${1}" "${2}";
	if [[ ${?} != 0 ]];
	then
		echo "ERROR: No se pudo grabar con \"${LOGGER}\".";
		echo "El mensaje era: ${1} ${2}";
	fi;
}

: <<'MOVEDOR'
Se encarga de mover los archivos en forma inteligente.
MOVEDOR
function MOVEDOR {
	"${MOVER}" "${1}" "${2}" "${NOMBRE_PROGRAMA}";
	if [[ ${?} != 0 ]];
	then
		LOGGEADOR "ERROR: No se pudo mover con \"${MOVER}\". Se queria mover \"${1}\" a \"${2}\"." "ERR";
	fi;
}


#No se puede ejecutar este comando si la inicializacion de ambiente no fue realizada.
#Chequeo las variables que se necesitan (tanto en este script como en el script "ProcesarOfertas", que es invocado desde este script).
#Me fijo que esten asignadas. "-o" significa "OR"; y "-z" siginifica que no sea una cadena de largo igual a cero; la expansion pone una cadena de largo igual a cero si no esta definida la variable.
for ITERADOR in ${VARIABLES_NECESARIAS[*]};
do
	TEMP="${!ITERADOR}";
	if [ -z "${TEMP:-}" ];
	then
		echo "ERROR: No se puede ejecutar \"${NOMBRE_PROGRAMA}\" si la inicializacion de ambiente no fue realizada.";
		echo "ERROR: No existe la variable de entorno: \"${ITERADOR}\"." ;
		exit 1;
	fi;
done;

#Chequeo que existan los directorios necesarios.
for ITERADOR in ${DIRECTORIOS_NECESARIOS[*]};
do
	if [ ! -d "${!ITERADOR}" ];
	then
		echo "ERROR: No existe el directorio: \"${!ITERADOR}\"." ;
		exit 2;
	fi;
done;

#Chequeo que los directorios necesarios tengan el permiso de lectura.
for ITERADOR in ${DIRECTORIOS_NECESARIOS_R[*]};
do
	if [ ! -r "${!ITERADOR}" ];
	then
		echo "ERROR: No esta pemitido leer el directorio: \"${!ITERADOR}\"." ;
		exit 3;
	fi;
done;

#Chequeo que los directorios necesarios tengan el permiso de escritura.
for ITERADOR in ${DIRECTORIOS_NECESARIOS_W[*]};
do
	if [ ! -w "${!ITERADOR}" ];
	then
		echo "ERROR: No esta pemitido escribir el directorio: \"${!ITERADOR}\"." ;
		exit 4;
	fi;
done;

#Chequeo que los directorios necesarios tengan el permiso de ejecucion.
for ITERADOR in ${DIRECTORIOS_NECESARIOS_X[*]};
do
	if [ ! -x "${!ITERADOR}" ];
	then
		echo "ERROR: No esta pemitido ejecutar el directorio: \"${!ITERADOR}\"." ;
		exit 5;
	fi;
done;

#Chequeo que existan los archivos necesarios.
for ITERADOR in ${ARCHIVOS_NECESARIOS[*]};
do
	if [ ! -e "${!ITERADOR}" ];
	then
		echo "ERROR: No existe el archivo: \"${!ITERADOR}\"." ;
		exit 6;
	fi;
done;

#Chequeo que los archivos necesarios tengan el permiso de lectura.
for ITERADOR in ${ARCHIVOS_NECESARIOS_R[*]};
do
	if [ ! -r "${!ITERADOR}" ];
	then
		echo "ERROR: No esta pemitido leer el archivo: \"${!ITERADOR}\"." ;
		exit 7;
	fi;
done;

#Chequeo que los archivos necesarios tengan el permiso de ejecucion.
for ITERADOR in ${ARCHIVOS_NECESARIOS_X[*]};
do
	if [ ! -x "${!ITERADOR}" ];
	then
		echo "ERROR: No esta pemitido ejecutar el archivo: \"${!ITERADOR}\"." ;
		exit 8;
	fi;
done;

#En el enunciado se pide que la variable que almacena el valor del intervalo se llame "SLEEPTIME".
if [[ "${SLEEPTIME}" == *[!0-9]* ]];
then
	echo "ERROR: El tiempo de intervalo (en segundos) no es un valor numérico.";
	exit 9;
fi;


#Declaro estas variables aca afuera de los ciclos para que no se re-declaren al iterar.
NRO_CICLO=0;

#El ciclo infinito del "demonio".
while ( true );
do
	#Grabar el registro de ejecución.
	LOGGEADOR "${NOMBRE_PROGRAMA} ciclo nro. $[++NRO_CICLO]" "INFO";

	#Modifico la variable de bash "IFS", para poder iterar en un "for-loop" de bash, a traves de las entradas provenientes de una lista cuyo separador es el salto de linea y que puede contener uno o más espacios dentro de sus registros.
	IFS_BACKUP=${IFS};
	IFS=$'\n';

	#Un ciclo para recorrer uno por uno los archivos del directorio de arribos.
	ls "-1" "-v" "-p" "${ARRIDIR}" | grep '[^/]$';
	for ARCHIVO_NOMBRE in $(ls "-1" "-v" "-p" "${ARRIDIR}" | grep '[^/]$');
	do
		#Veo si es un archivo de texto.
		if [[ $(file --mime-type "${ARRIDIR}/${ARCHIVO_NOMBRE}" | grep -c "text" -) == 0 ]];
		then
			#El archivo no es de texto.
			#echo "\"${ARCHIVO_NOMBRE}\""$'\t'"no es un archivo de texto.";
			LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"no es un archivo de texto." "WAR";
			MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${NOKDIR}/";
		else
			#Ver si el nombre del archivo cumple con el formato.
			if [[ $(echo "${ARCHIVO_NOMBRE}" | grep -c '^[0-9]\{7\}_[0-9]\{8\}.csv.xls$') != 1 ]];
			then
				#El nombre del archivo no cumple con el formato.
				#echo "\"${ARRIDIR}/${ARCHIVO_NOMBRE}\""$'\t'"no cumple con el formato de nombre de archivo.";
				LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"no cumple con el formato de nombre de archivo." "WAR";
				MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${NOKDIR}/";
			else
				#Ver si la fecha en el nombre del archivo es válida.
				$(date -d "${ARCHIVO_NOMBRE:8:4}${ARCHIVO_NOMBRE:12:2}${ARCHIVO_NOMBRE:14:2}" &> /dev/null);
				EXIT_STATUS=$(echo "$?");
				if [[ "${EXIT_STATUS}" -ne 0 ]];
				then
					#La fecha en el nombre del archivo no es válida.
					#echo "\"${ARRIDIR}/${ARCHIVO_NOMBRE}\""$'\t'"no tiene una fecha válida en su nombre de archivo.";
					LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"no tiene una fecha válida en su nombre de archivo." "WAR";
					MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${NOKDIR}/";
				else
					#Ver si el nombre del archivo tiene un código de concesionario existe en el archivo maestro de concesionarios.
					if [[ $(grep -c '.*;'"${ARCHIVO_NOMBRE:0:4}"'$' "${CONCESIONARIOS_ARCHIVO}") == 0 ]];
					then
						#El nombre del archivo tiene un código de concesionario que no existe en el archivo maestro de concesionarios.
						#echo "\"${ARRIDIR}/${ARCHIVO_NOMBRE}\""$'\t'"tiene un nombre con un código de concesionario que no existe en el archivo maestro.";
						LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"tiene un nombre con un código de concesionario que no existe en el archivo maestro." "WAR";
						MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${NOKDIR}/";
					else
						#Ver si la fecha en el nombre del archivo es menor o igual que la fecha actual.
						FECHA_ACTUAL=$(date +%Y%m%d);
						FECHA_NOMBRE_ARCHIVO="${ARCHIVO_NOMBRE:8:4}${ARCHIVO_NOMBRE:12:2}${ARCHIVO_NOMBRE:14:2}";
						if [[ "${FECHA_NOMBRE_ARCHIVO}" -gt "${FECHA_ACTUAL}" ]];
						then
							#El nombre del archivo tiene una fecha que no es menor o igual que la fecha actual.
							#echo "\"${ARRIDIR}/${ARCHIVO_NOMBRE}\""$'\t'"tiene una fecha en el nombre de archivo que no es menor o igual que la fecha actual.";
							LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"tiene una fecha en el nombre de archivo que no es menor o igual que la fecha actual." "WAR";
							MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${NOKDIR}/";
						else
							#Ver si la fecha en el nombre del archivo es mayor que la fecha del último acto de adjudicación.
							PRIMER_ADJUDICACION="true";
							SALIR="false";
							for ITERADOR_FECHA in $(sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9]\{4\}\).*-\3\2\1-g' "${FECHAS_ARCHIVO}" | sort -n -r);
							do
								#Busco la fecha de adjudicación anterior.
								if [[ "${ITERADOR_FECHA}" -lt "${FECHA_ACTUAL}" ]];
								then
									PRIMER_ADJUDICACION="false";
									if [[ "${ITERADOR_FECHA}" -lt "${FECHA_NOMBRE_ARCHIVO}" ]];
									then
										#El nombre del archivo tiene una fecha que es mayor que la fecha del último acto de adjudicación.
										#echo "\"${ARRIDIR}/${ARCHIVO_NOMBRE}\""$'\t'"es aceptado.";
										LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"es aceptado." "INFO";
										MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${OKDIR}/";
										SALIR="true";
									else
										#El nombre del archivo tiene una fecha que no es mayor que la fecha del último acto de adjudicación.
										#echo "\"${ARRIDIR}/${ARCHIVO_NOMBRE}\""$'\t'"tiene una fecha en el nombre de archivo que no es mayor que la fecha del último acto de adjudicación.";
										LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"tiene una fecha en el nombre de archivo que no es mayor que la fecha del último acto de adjudicación." "WAR";
										MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${NOKDIR}/";
										SALIR="true";
									fi;
								fi;
								if [[ "${SALIR}" == "true" ]];
								then
									break;
								fi;
							done;
							if [[ "${PRIMER_ADJUDICACION}" == "true" ]];
							then
								#no hay actos de adjudicación anteriores a la fecha actual.
								#echo "\"${ARRIDIR}/${ARCHIVO_NOMBRE}\""$'\t'"es aceptado.";
								LOGGEADOR "\"${ARCHIVO_NOMBRE}\""$'\t'"es aceptado." "INFO";
								MOVEDOR "${ARRIDIR}/${ARCHIVO_NOMBRE}" "${OKDIR}/";
							fi;
						fi;
					fi;
				fi;
			fi;
		fi;
	done;
	IFS=${IFS_BACKUP};

	#Si hay archivos en el directorio de aceptados...
	if [[ -n $(ls "-1" "-p" "${OKDIR}" | grep '[^/]$') ]];
	then
		ESTA_EJECUTANDOSE="false";
		IFS=$'\n';
		#Veo si se esta ejecutando el script "ProcesarOfertas".
		for PROCESO in $(ps -e | grep "${PROCESAROFERTAS_ARCHIVO}" | awk '{ print $4 }');
		do
			if [[ "${PROCESO}" == "${PROCESAROFERTAS_ARCHIVO}" ]];
			then
				ESTA_EJECUTANDOSE="true";
				LOGGEADOR "${PROCESAROFERTAS_ARCHIVO} ya se encuentra ejecutandose." "INFO";
			fi;
		done;
		#Si no se esta ejecutando el script "ProcesarOfertas"...
		if [[ ${ESTA_EJECUTANDOSE} == "false" ]];
		then
			#Lo lanzo en segundo plano.
			"${PROCESAROFERTAS}" &
		fi;
		IFS="${IFS_BACKUP}";
	fi;

	#Duermo el proceso durante "SLEEPTIME" segundos.
	sleep "${SLEEPTIME}";
done;