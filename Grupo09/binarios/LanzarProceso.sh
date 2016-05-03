#!/bin/bash
# *************************************************************************** #
#           TP Sistemas Operativos - Grupo 09 1er Cuatrimestre 2016           #
# *************************************************************************** #
# *********************** "LanzarProceso.sh" ******************************** #
# *************************************************************************** #
#                           Descripción:                                      #
#                                                                             #
# Esta funcion tiene como objetivo disparar los procesos que se le pasan por  #
# parámetro.                                                                  #
# Parámetros: nombre del proceso que se va a ejecutar.                        #
#   1- Verifica que la cantidad de parámetros sea correcta. De no ser         #
#     correcta se registra el evento en el log.                               #
#   2- Verifica que el ambiente este preparado antes de invocar al proceso.   #
#     En caso de no estar inicializado, se registra el evento en el log.      #
#   3- Verifica que el proceso no esté en ejecución. De ser asi, registra en  #
#     el log que el proceso ya esta en ejecución, e incluye el PID en el log. #
#   4- De ser correctas las validaciones, ejecuta el proceso y loggea         #
#     el evento.                                                              #
# *************************************************************************** #

# Variable de comando
comando="LanzarProceso"

obtenerProcessID(){
  proceso=$1
  PID=$(ps aux | grep ./$proceso | grep -v "grep" | head -1 | awk '{ print $2 }')
  echo $PID
  if [ -z $PID ]; then
  	echo 0
    return
  else
  	echo 1";"$PID
  	return
  fi
}

main(){
  # Validación de los parámetros.
  cantidadParametros=$1
  if [ $cantidadParametros -ne 1 ]; then
    echo 'La cantidad de parámetros con los que se invocó LanzarProceso es inválida'
    bash GrabarBitacora.sh $comando 'La cantidad de parámetros con los que se invocó LanzarProceso es inválida' 'ERR'
  	return
  fi
  comandoObjetivo=$2

  # Validación de la inicialización del ambiente.
  if [ -z "$PREPARARAMBIENTE" ] || [ $PREPARARAMBIENTE != "SI" ]; then
    echo 'No se puede iniciar el proceso '$comandoObjetivo' porque el ambiente no esta preparado.'
    bash GrabarBitacora.sh $comando 'No se puede iniciar el proceso '$comandoObjetivo' porque el ambiente no esta preparado.' 'ERR'
    return
  fi

  # Se trata de obtener el ID del proceso a invocar, en caso de ya estar en ejecución.
  resultadoObtenerProcessID=`obtenerProcessID $comandoObjetivo`
  codigoRetorno=$(echo $resultadoObtenerProcessID | cut -f1 -d';')

  # Si no se encontro el ID, entonces se lanza el proceso
  if [[ $codigoRetorno == 0 ]]; then
    ./$comandoObjetivo &
    echo 'Se lanzó el proceso '$comandoObjetivo'.'
    bash GrabarBitacora.sh $comando 'Se lanzó el proceso '$comandoObjetivo'.' 'INFO'
    return
  # De lo contrario se advierte que ya está ejecutado.
  else
    PID=$(echo $resultadoObtenerProcessID | cut -f2 -d';')
    bash GrabarBitacora.sh $comando 'El proceso '$comandoObjetivo' ya está en ejecución bajo el id de preoceso: '$PID'.' 'WAR'
  	echo 'El proceso $comandoObjetivo ya está en ejecución bajo el id de preoceso: '$PID'.'
    return
  fi
}
main $# $@
