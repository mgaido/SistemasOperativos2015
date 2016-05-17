#!/bin/bash

comando="PrepararAmbiente"

main()
{
	cargarVariables
	if yaInicializado; then
		bash GrabarBitacora.sh $comando 'Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente' 'INFO'
		echo Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente
	else
		(verificarInstalacion && verificarPermisos) || return 1
		setearVariablesAmbiente
		procesoCompleto
		comenzarRecibirOfertas
	fi
}

leerRespuestaUsuario()
{
	bash GrabarBitacora.sh $comando 'Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente' 'INFO'
	echo "$1 (Si - No)"
	read answ
	answ=$(echo $answ | awk '{print tolower($0)}')
	if [[ $answ = "si" ]]; then
		bash GrabarBitacora.sh $comando 'Ingresa SI' 'INFO'
		echo Ingresa SI
		return 0
	else
		if [[ $answ = "no" ]]; then
			bash GrabarBitacora.sh $comando 'Ingresa NO' 'INFO'
			echo Ingresa NO
		else
			bash GrabarBitacora.sh $comando 'Ingresa un valor no valido. No se inicia el proceso' 'WAR'
			echo Ingresa un valor no valido. No se inicia el proceso
		fi
		return 1
	fi
}

cargarVariables()
{
	GRUPO="$(get_var GRUPO)"
	BINDIR="$(get_var BINDIR)"
	CONFDIR="$(get_var CONFDIR)"
	MAEDIR="$(get_var MAEDIR)"
	ARRIDIR="$(get_var ARRIDIR)"
	OKDIR="$(get_var OKDIR)"
	PROCDIR="$(get_var PROCDIR)"
	INFODIR="$(get_var INFODIR)"
	LOGDIR="$(get_var LOGDIR)"
	NOKDIR="$(get_var NOKDIR)"
	LOGSIZE="$(get_var LOGSIZE)"
	SLEEPTIME="$(get_var SLEEPTIME)"
	BACKUP="$(get_var BACKUP)"
	echo Variables Cargadas
}

get_var()
{
	echo $(grep '^'"$1"'=' "../config/CIPAK.cnf" | cut -d '=' -f 2)
}


verificarArchivosFaltantes()
{
	#Verifico los maestros
	[[ -f "$MAEDIR/FechasAdj.csv" ]] || return 0
	[[ -f "$MAEDIR/concesionarios.csv.xls" ]] || return 0
	[[ -f "$MAEDIR/grupos.csv.xls" ]] || return 0
	#Verifico los scripts
	[[ -f "$BINDIR/PrepararAmbiente.sh" ]] || return 0
	[[ -f "$BINDIR/RecibirOfertas.sh" ]] || return 0
	[[ -f "$BINDIR/GenerarSorteo.sh" ]] || return 0
	[[ -f "$BINDIR/ProcesarOfertas.sh" ]] || return 0
	[[ -f "$BINDIR/DeterminarGanadores.pl" ]] || return 0
	[[ -f "$BINDIR/LanzarProceso.sh" ]] || return 0
	[[ -f "$BINDIR/DetenerProceso.sh" ]] || return 0
	[[ -f "$BINDIR/MoverArchivos.sh" ]] || return 0
	[[ -f "$BINDIR/GrabarBitacora.sh" ]] || return 0
	[[ -f "$BINDIR/MostrarBitacora.sh" ]] || return 0
	return 1
}

verificarInstalacion()
{
	if verificarArchivosFaltantes; then
		bash GrabarBitacora.sh $comando 'Estado de la instalacion: INCOMPLETA' 'WAR'
		bash GrabarBitacora.sh $comando "Componentes Faltantes:  $mostrarFaltantes" 'WAR'
		echo Estado de la instalacion: INCOMPLETA
		echo Componentes Faltantes: $(mostrarFaltantes)
		if ofrecerReparar "Desea intentar reparar la instalacion ?"; then
			repararInstalacion
		else
			return 1
		fi
		return 0
	fi
}

ofrecerReparar()
{
	echo "$1 (Si - No)"
	read answ
	answ=$(echo $answ | awk '{print tolower($0)}')
	if [[ $answ = "si" ]]; then
		bash GrabarBitacora.sh $comando 'Se procede a reparar la instalacion' 'INFO'
		echo Ingresa SI
		if copiarFaltantes; then
			return 0
		else
			return 1
		fi
	else
		if [[ $answ = "no" ]]; then
			bash GrabarBitacora.sh $comando 'No se repara la instalacion' 'INFO'
			echo Ingresa NO
		else
			bash GrabarBitacora.sh $comando 'Ingresa un valor no valido. No se inicia el proceso' 'WAR'
			echo Ingresa un valor no valido. No se inicia el proceso
		fi
		return 1
	fi
}

repararInstalacion()
{

	return 0
}

copiarFaltantes()
{
	#Copio maestros:
	cd ..
	copiar ./resguardo/masestros/FechasAdj.csv "$MAEDIR/FechasAdj.csv"
	copiar ./resguardo/masestros/concesionarios.csv.xls "$MAEDIR/concesionarios.csv.xls"
	copiar ./resguardo/masestros/grupos.csv.xls.csv "$MAEDIR/grupos.csv.xls"
	#Copio los scripts
	copiar ./resguardo/binarios/PrepararAmbiente.sh "$BINDIR/PrepararAmbiente.sh"
	copiar ./resguardo/binarios/RecibirOfertas.sh "$BINDIR/RecibirOfertas.sh"
	copiar ./resguardo/binarios/enerarSorteo.sh "$BINDIR/GenerarSorteo.sh"
	copiar ./resguardo/binarios/ProcesarOfertas.sh "$BINDIR/ProcesarOfertas.sh"
	copiar $BACKUP/binarios/DeterminarGanadores.pl "$BINDIR/DeterminarGanadores.pl"
	copiar $BACKUP/binarios/LanzarProceso.sh "$BINDIR/LanzarProceso.sh"
	copiar $BACKUP/binarios/DetenerProceso.sh "$BINDIR/DetenerProceso.sh"
	copiar ./resguardo/binarios/MoverArchivos.sh "$BINDIR/MoverArchivos.sh"
	copiar ./resguardobinarios/GrabarBitacora.sh "$BINDIR/GrabarBitacora.sh"
	copiar ./resguardo/binarios/MostrarBitacora.sh "$BINDIR/MostrarBitacora.sh"
}

copiar()
{
	if [[ ! -f "$2" ]]; then
		if [[ -f "$1" ]]; then
			cp -n "$1" "$2"
		else
			echo No se puede reparar la instalacion, pues no se encuentra $1
			exit 1
		fi
	fi
}

verificarPermisos()
{
	verificarPermisoLectura "$MAEDIR/FechasAdj.csv" || return 1
	verificarPermisoLectura "$MAEDIR/concesionarios.csv.xls" || return 1
	verificarPermisoLectura "$MAEDIR/grupos.csv.xls" || return 1
	verificarPermisoEjecucion "$BINDIR/PrepararAmbiente.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/RecibirOfertas.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/GenerarSorteo.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/ProcesarOfertas.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/DeterminarGanadores.pl" || return 1
	verificarPermisoEjecucion "$BINDIR/LanzarProceso.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/DetenerProceso.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/MoverArchivos.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/GrabarBitacora.sh" || return 1
	verificarPermisoEjecucion "$BINDIR/MostrarBitacora.sh" || return 1
}

procesoCompleto()
{
	echo
	echo
	bash GrabarBitacora.sh $comando 'Estado de la instalacion: INICIALIZDO' 'INFO'
	echo Estado de la instalacion: INICIALIZDO
}

list_dir()
{
	echo "$(ls "$1" | tr "\n" " ")"
}

mostrarFaltantes()
{
	output=""
	[[ -d "$GRUPO" ]] || output="$output $(obtenerPath "$GRUPO")"
	[[ -d "$BINDIR" ]] || output="$output $(obtenerPath "$BINDIR")"
	[[ -d "$MAEDIR" ]] || output="$output $(obtenerPath "$MAEDIR")"
	[[ -d "$ARRIDIR" ]] || output="$output $(obtenerPath "$ARRIDIR")"
	[[ -d "$OKDIR" ]] || output="$output $(obtenerPath "$OKDIR")"
	[[ -d "$PROCDIR" ]] || output="$output $(obtenerPath "$PROCDIR")"
	[[ -d "$INFODIR" ]] || output="$output $(obtenerPath "$INFODIR")"
	[[ -d "$LOGDIR" ]] || output="$output $(obtenerPath "$LOGDIR")"
	[[ -d "$NOKDIR" ]] || output="$output $(obtenerPath "$NOKDIR")"
	[[ -d "$LOGSIZE" ]] || output="$output $(obtenerPath "$LOGSIZE")"
	[[ -d "$SLEEPTIME" ]] || output="$output $(obtenerPath "$SLEEPTIME")"
	#Maestros
	[[ -f "$MAEDIR/FechasAdj.csv" ]] || output="$output FechasAdj.csv"
	[[ -f "$MAEDIR/concesionarios.csv.xls" ]] || output="$output concesionarios.csv.xls"
	[[ -f "$MAEDIR/grupos.csv.xls" ]] || output="$output grupos.csv.xls"
	#Scripts
	[[ -f "$BINDIR/PrepararAmbiente.sh" ]] || output="$output PrepararAmbiente.sh"
	[[ -f "$BINDIR/RecibirOfertas.sh" ]] || output="$output RecibirOfertas.sh"
	[[ -f "$BINDIR/GenerarSorteo.sh" ]] || output="$output GenerarSorteo.sh"
	[[ -f "$BINDIR/ProcesarOfertas.sh" ]] || output="$output ProcesarOfertas.sh"
	[[ -f "$BINDIR/DeterminarGanadores.pl" ]] || output="$output DeterminarGanadores.pl"
	[[ -f "$BINDIR/LanzarProceso.sh" ]] || output="$output LanzarProceso.sh"
	[[ -f "$BINDIR/DetenerProceso.sh" ]] || output="$output DetenerProceso.sh"
	[[ -f "$BINDIR/MoverArchivos.sh" ]] || output="$output MoverArchivos.sh"
	[[ -f "$BINDIR/GrabarBitacora.sh" ]] || output="$output GrabarBitacora.sh"
	[[ -f "$BINDIR/MostrarBitacora.sh" ]] || output="$output MostrarBitacora.sh"
	echo $output
}

verificarPermisoEjecucion()
{
	#Si no se puede leer > no se puede ejecutar
	verificarPermisoLectura "$1" || return 1
	if ! [[ -x "$1" ]]; then
		name="$(obtenerNombreArchivo "$1")"
		bash GrabarBitacora.sh $comando "Intentando setear permiso de ejecucion a:  $name" 'INFO'
		echo Intentando setear permiso de ejecucion a $name
		chmod +x "$1"
		if ! [[ $? -eq 0 ]]; then
			bash GrabarBitacora.sh $comando "No se puede setear permiso de ejecucion a:  $name" 'INFO'
			echo No se puede setear permiso de ejecucion a $name
			return 1
		fi
	fi
}

verificarPermisoLectura()
{
	if ! [[ -r "$1" ]]; then
		name="$(obtenerNombreArchivo "$1")"
		bash GrabarBitacora.sh $comando "Seteando permiso de lectura a: $name " 'INFO'
		echo Seteando permiso de lectura a $name
		chmod +r "$1"
		if ! [[ $? -eq 0 ]]; then
			bash GrabarBitacora.sh $comando "No se pudo setear permiso de lectura a: $name " 'INFO'
			echo No se pudo setear permiso de lectura a $name
			return 1
		fi
	fi
}

obtenerNombreArchivo()
{
	echo "$(echo $1 | sed "s#.*/##")"
}

obtenerPath()
{
	echo "$(echo "$1" | sed "s#$GRUPO/##")"
}

yaInicializado()
{
	return $([[ $PREPARARAMBIENTE == "SI" ]])
}

setearVariablesAmbiente()
{
	export PREPARARAMBIENTE="SI"
	export GRUPO
	export BINDIR
	export MAEDIR
	export ARRIDIR
	export OKDIR
	export CONFDIR
	export PROCDIR
	export INFODIR
	export LOGDIR
	export NOKDIR
	export LOGSIZE
	export SLEEPTIME
	bash GrabarBitacora.sh $comando 'Variables de Ambiente Seteadas' 'INFO'
	echo Variables de Ambiente Seteadas
}

ofrecerIniciarRecibirOfertas()
{
	status=$(ps -aef | grep "$BINDIR/RecibirOfertas.sh" | wc -l)
	if [[ $status -ne 2 ]]; then
		#Ejecuto RecibirOfertas.
		"$BINDIR"/RecibirOfertas.sh & #"RecibirOfertas"
	fi
	pid="$(ps -aef | grep "$BINDIR/RecibirOfertas.sh" | awk 'NR==1 {print $2}')"
	bash GrabarBitacora.sh $comando "RecibirOfertas corriendo bajo el no.:  $pid " 'INFO'
	echo RecibirOfertas corriendo bajo el no.: $pid
}

comenzarRecibirOfertas()
{
	if leerRespuestaUsuario "Desea comenzar a Recibir Ofertas?"; then
		ofrecerIniciarRecibirOfertas
	else
		bash GrabarBitacora.sh $comando 'Para activar RecibirOfertas ejecute . $GRUPO/binarios/RecibirOfertas.sh' 'INFO'
		echo Para activar RecibirOfertas ejecute . $GRUPO/RecibirOfertas.sh
	fi
}

main
