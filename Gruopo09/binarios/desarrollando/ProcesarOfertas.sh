#!/bin/bash
# *************************************************************************** #
#           TP Sistemas Operativos - Grupo 09 1er Cuatrimestre 2016           #
# *************************************************************************** #
# *****************  Proceso "procesarOfertas.sh" *************************** #
# *************************************************************************** #
#                           Descripción:                                      #
#                                                                             #
# Procesa todos los archivos en la carpeta de archivos aceptados ($OKDIR).    #
#   1- Al iniciar la ejecucion escribe en el log el evento, y detalla la      #
#     cantidad de archivos a procesar.                                        #
# Detalle del proceso (en cada archivo a procesar):                           #
#   2- Verifica que el archivo no sea duplicado chequeando contra la carpeta  #
#     de procesados ($PROCDIR). Si hay un duplicado se registra en el log.    #
#   3- Valida la cantidad de campos del primer registro. Si la cantidad de    #
#     campos no es la correspondiente, se registra el evento en el log.       #
#
# En caso de fallar las anteriores validaciones, el archivo se mueve a el     #
# directorio de archivos (completos) rechazados ($NOKDIR).                    #
#                                                                             #
# En caso de ser un archivo válido, se empieza procesar el archivo:           #
#                                                                             #
#   4- Se graba en el log "Archivo a procesar: <nombre del archivo>"          #
#   5- Por cada registro se realizan las validaciones pertinentes al negocio. #
#                                                                             #
# En caso de ser aceptado el registro se realiza escribe una entrada en el    #
# directorio de registros válidos, en su archivo correspondiente (.txt).      #
# En caso de ser rechazado el registro, se realiza una escritura en el        #
# archivo correspondiente (.rech) en el directorio de registros rechazados.   #
#
# A cada registro que se procesa, se actualizan los contadores de registros   #
# procesados, validos y rechazados.                                           #
# Al finalizar el procesamiento de un archivo, se colocan en 0 nuevamente los #
# contadores.                                                                 #
#                                                                             #
# Al procesar el ultimo archivo se escribe en el log "Fin de ProcesarOfertas" #
#                                                                             #
# *************************************************************************** #

# Variable de comando
comando="ProcesarOfertas"

# Variables de directorio TODO USAR LAS DEFINIDAS EN OTRO SCRIPT
GRUPO="$(dirname "$PWD")"
OKDIR=$GRUPO/aceptados
NOKDIR=$GRUPO/rechazados
BINDIR=$GRUPO/binarios
PROCDIR=$GRUPO/procesados
INFODIR=$GRUPO/informes
ARRIDIR=$GRUPO/arribados
MAEDIR=$GRUPO/maestros
LOGDIR=$GRUPO/bitacoras
CONFDIR=$GRUPO/config

logInicio(){
  cantidadArchivos=$(ls -l $OKDIR/*.csv.xls | wc -l)
  echo 'Inicio de '$comando
  bash GrabarBitacora.sh $comando 'Inicio de '$comando 'INFO'
  echo 'Cantidad de archivos a procesar: '$cantidadArchivos
  bash GrabarBitacora.sh $comando 'Cantidad de archivos a procesar: '$cantidadArchivos 'INFO'
}

chequearDuplicados(){
  if [ -f "$PROCDIR/$1" ]
  then
    echo 1
    return
  else
    echo 0
    return
  fi
}

chequearEstructuraArchivo(){
  local linea=$1
  # Chequeo la cantidad de delimitadores
  cantidadDemilitadores=$(echo $linea | grep -o ";" | wc -l)
  if [ $cantidadDemilitadores != 1 ]
  then
    echo 1
    return
  else
    echo 0
    return
  fi
}

buscarContratoFusionado(){
  local grupo=$1
  local orden=$2
  padron=$MAEDIR/temaK_padron.csv.xls

  for linea in $(cat "$padron"); do
    grupoPadron=$(echo $linea | cut -f1 -d';')
    ordenPadron=$(echo $linea | cut -f2 -d';')
    if [ $grupoPadron -eq $grupo ] && [ $ordenPadron -eq $padron ]
    then
      echo $linea
      return
    fi
  done
  echo 0
  return
}


procesarRegistro(){
  local linea=$1
  contratoFusionado=$(echo $linea | cut -f1 -d';') # TODO chequear que cada linea tenga la cantidad de campos correctos
  importe=$(echo $linea | cut -f2 -d';')
  if [ ${#contratoFusionado} -ne 7 ]
  then
    echo 0
    return
  else
    grupo=${contratoFusionado:0:4}
    orden=${contratoFusionado:4:7}
    lineaPadronExistente=`buscarContratoFusionado $grupo $orden`

    if [ $lineaPadronExistente -ne 0 ]
    then

    else
      echo 0
      return
  fi

  return
}

procesarArchivo(){
  local filename=$1
  IFS=$'\n'       # make newlines the only separator
  set -f          # disable globbing
  for linea in $(cat "$filename"); do
    echo `procesarRegistro $linea`
  done
}

main(){
  logInicio

  for filename in $OKDIR/*.csv.xls; do
      duplicado=`chequearDuplicados $(basename $filename)`
      if [ $duplicado -eq 0 ]
      then
        firstLine=$(head -n 1 $filename)
        estructuraInvalida=`chequearEstructuraArchivo $firstLine`
        if [ $estructuraInvalida -eq 0 ]
        then
          echo `procesarArchivo $filename`
        else
          echo 'Se rechaza archivo '$(basename $filename)' porque no corresponde con el formato esperado'
          bash GrabarBitacora.sh $comando 'Se rechaza archivo '$(basename $filename)' porque no corresponde con el formato esperado' 'WAR'
        fi
      else
        echo 'Se rechaza archivo '$(basename $filename)' por estar duplicado'
        bash GrabarBitacora.sh $comando 'Se rechaza archivo '$(basename $filename)' por estar duplicado' 'WAR'
      fi
  done
}
main
