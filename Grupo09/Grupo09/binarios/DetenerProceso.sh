comando="DetenerProceso"

obtenerProcessID(){
  proceso=$1
  PID=$(ps -ef --sort=start_time | grep ./$proceso | grep -v "grep" | head -1 | awk '{ print $2 }')
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
    echo 'La cantidad de parámetros con los que se invocó DetenerProceso es inválida'
    bash GrabarBitacora.sh $comando 'La cantidad de parámetros con los que se invocó DetenerProceso es inválida' 'ERR'
  	return
  fi
  comandoObjetivo=$2

  # Se trata de obtener el ID del proceso a invocar, en caso de ya estar en ejecución.
  resultadoObtenerProcessID=`obtenerProcessID $comandoObjetivo`
  codigoRetorno=$(echo $resultadoObtenerProcessID | cut -f1 -d';')

  # Si no se encontro el ID, entonces se lanza el proceso
  if [[ $codigoRetorno == 0 ]]; then
    echo 'No se encontro ningun proceso llamado '$comandoObjetivo'.'
    bash GrabarBitacora.sh $comando 'No se encontro ningun proceso llamado '$comandoObjetivo'.' 'INFO'
    return
  # De lo contrario se advierte que ya está ejecutado.
  else
    PID=$(echo $resultadoObtenerProcessID | cut -f2 -d';')
    kill $PID
    bash GrabarBitacora.sh $comando 'El proceso '$comandoObjetivo' corriendo bajo el PID '$PID' fue detenido.' 'WAR'
  	echo 'El proceso '$comandoObjetivo' corriendo bajo el PID '$PID' fue detenido.'
    return
  fi
}
main $# $@
