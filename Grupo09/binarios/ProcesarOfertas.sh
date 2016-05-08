#!/bin/bash
# *************************************************************************** #
#           TP Sistemas Operativos - Grupo 09 1er Cuatrimestre 2016           #
# *************************************************************************** #
# *****************  Proceso "ProcesarOfertas.sh" *************************** #
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
#                                                                             #
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
#                                                                             #
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
  bash GrabarBitacora.sh $comando 'Inicio de '$comando 'INFO'
  archivosAProcesar=$(find $OKDIR -name '*.csv.xls' | wc -l)
  bash GrabarBitacora.sh $comando 'Cantidad de archivos a procesar: '$archivosAProcesar 'INFO'
}

chequearEntero(){
  regExprEntero='^[0-9]+$'
  if ! [[ $1 =~ $regExprEntero ]] ; then
    echo 0
    return
  else
    echo 1
    return
  fi
}

chequearDecimal(){
  regExprDecimal='^[0-9]+([,][0-9]+)?$'
  if ! [[ $1 =~ $regExprDecimal ]] ; then
    echo 0
    return
  else
    echo 1
    return
  fi
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

rechazarRegistro(){
  nombreArchivo=$1
  razonRechazo=$2
  linea=$3
  linea=${linea%$'\r'}
  codigoConcesionario=$(echo $nombreArchivo | cut -f1 -d'_')

  user=`whoami`
  fecha=`date +%Y%m%d-%H:%M:%S`
  echo $nombreArchivo";"$razonRechazo";"$linea";"$user";"$fecha >> $PROCDIR/rechazadas/$codigoConcesionario.rech
  return
}

aceptarRegistro(){
  nombreArchivo=$1
  codigoConcesionario=$(echo $nombreArchivo | cut -f1 -d'_')
  fechaArchivo=$(echo $nombreArchivo | cut -f2 -d'_')
  contratoFUsionado=$2$3
  grupo=$2
  orden=$3
  importe=$4
  fechaAdjudicacion=$5
  nombreSuscriptor=$6
  user=`whoami`
  fecha=`date +%Y%m%d-%H:%M:%S`

  echo 'estoy aceptando un registro'
  echo $codigoConcesionario";"$fechaArchivo";"$contratoFUsionado";"$grupo";"$orden";"$importe";"$nombreSuscriptor";"$user";"$fecha >> $PROCDIR/validas/$fechaAdjudicacion.txt
  return
}

chequearEstructuraArchivo(){
  local linea=$1
  # Chequeo la cantidad de delimitadores
  cantidadDemilitadores=$(echo $linea | grep -o ";" | wc -l)
  if [[ $cantidadDemilitadores == 1 ]]; then
    echo 0 # Caso correcto
    return
  else
    echo 1 #
    return
  fi
}

buscarFechaAdjudicacion(){
  fechasAdjudicacion=$MAEDIR/FechasAdj.csv
  while read linea; do
    fecha=$(echo $linea | cut -f1 -d';')
    anio=$(echo $fecha | cut -f3 -d'/')
    mes=$(echo $fecha | cut -f2 -d'/')
    dia=$(echo $fecha | cut -f1 -d'/')

    fechaHoY=`date +%Y%m%d`
    fechaAdj=$(echo $anio$mes$dia)
    if [ $fechaAdj -ge $fechaHoY ];
    then
      echo $fechaAdj;
      return
    fi
  done < $fechasAdjudicacion

  bash GrabarBitacora.sh $comando 'No hay fechas de adjudicación futuras' 'ERR'
  echo 0;
}

buscarContratoFusionado(){
  local grupo=$1
  local orden=$2
  padron=$MAEDIR/temaK_padron.csv.xls
  cantidadCoincidencias=$(grep ^$grupo";"$orden $padron | wc -l)

  if [[ $cantidadCoincidencias > 0 ]]; then
    linea=`grep ^$grupo";"$orden $padron | head -1`
    participa=$(echo $linea | cut -f6 -d';')
    if [ $participa == 1 ] || [ $participa == 2 ]; then ## Caso correcto
      nombreSuscriptor=$(echo $linea | cut -f3 -d';')
      echo 0";"$nombreSuscriptor
      return
    else
      echo 1";Suscriptor no puede participar"
      return
    fi
  else
    echo 1";Contrato no encontrado"
    return
  fi
}

chequearGrupo(){
  local grupo=$1
  local grupos=$MAEDIR/grupos.csv.xls

  cantidadCoincidencias=$(grep ^$grupo";" $grupos | wc -l)

  if [[ $cantidadCoincidencias > 0 ]]; then
    linea=`grep ^$grupo";" $grupos | head -1`
    estadoGrupo=$(echo $linea | cut -f2 -d';')
    if [ $estadoGrupo == "ABIERTO" ]; then ## Caso correcto
      valorCuotaPura=$(echo $linea | cut -f4 -d';')
      cuotasPendientes=$(echo $linea | cut -f5 -d';')
      cuotasParaLicitacion=$(echo $linea | cut -f6 -d';')
      echo 0";"$valorCuotaPura";"$cuotasPendientes";"$cuotasParaLicitacion
      return
    else
      echo 1";Grupo CERRADO"
      return
    fi
  else
    # En caso de haber encontrado el grupo en el padrón y no en el archivo de grupos, se hace un log del evento.
    bash GrabarBitacora.sh $comando 'Existe una inconsistencia entre el archivo de padrones y grupos. El grupo '$grupo' que figura en el padrón no existe en el archivo de grupos' 'WAR'
    echo 1";Grupo no encontrado"
    return
  fi
}

chequearValorImporte(){
  importe=$1
  cuotaPura=$2
  cuotasPendientes=$3
  cuotasParaLicitacion=$4

  # Primero se valida que los parámetros numéricos sean correctos.

  importeValidoEntero=`chequearEntero $importe`
  if [[ $importeValidoEntero != 1 ]]; then
    importeValidoDecimal=`chequearDecimal $importe`
    if [[ $importeValidoDecimal != 1 ]]; then
      echo 1";Importe de la oferta invalido"
      return
    fi
  fi

  cuotaPuraValidoEntero=`chequearEntero $cuotaPura`
  if [[ $cuotaPuraValidoEntero != 1 ]]; then
    cuotaPuraValidoDecimal=`chequearDecimal $cuotaPura`
    if [[ $cuotaPuraValidoDecimal != 1 ]]; then
      echo 1";Error en la lectura del valor de la cuota pura"
      return
    fi
  fi

  cuotasPendientesValidoEntero=`chequearEntero $cuotasPendientes`
  if [[ $cuotasPendientesValidoEntero != 1 ]]; then
    echo 1";Error en la lectura de la cantidad de cuotas pendientes"
    return
  fi

  cuotasParaLicitacionValidoEntero=`chequearEntero $cuotasParaLicitacion`
  if [[ $cuotasParaLicitacionValidoEntero != 1 ]]; then
    echo 1;"Error en la lectura de la cantidad de para la licitacion"
    return
  fi

  # Se reemplazan las comas por puntos, para poder operar con los valores de importe y cuota pura.
  # Si los valores no son decimales, no se realiza ningun reemplazo, y el valor queda identico a como estaba.
  importe=$( echo $importe | tr "," .)
  cuotaPura=$( echo $cuotaPura | tr "," .)

  # Se hacen los calculos de monto mínimo y máximo
  montoMinimo=$( echo $cuotaPura*$cuotasParaLicitacion | bc)
  montoMaximo=$( echo $cuotaPura*$cuotasPendientes | bc)

  # Se compara el importe con los montos minimo y maximo obtenidos para validarlo.
  if (( $(echo "$importe > $montoMaximo" | bc -l) )); then
    echo 1";Supera el monto maximo"
    return
  elif (( $(echo "$importe < $montoMinimo" | bc -l) )); then
    echo 1";No alcanza el monto minimo"
    return
  fi
  echo 0
  return
}


procesarRegistro(){
  local linea=$1
  local nombreArchivo=$2
  local fechaAdjudicacion=$3
  contratoFusionado=$(echo $linea | cut -f1 -d';') # TODO chequear que cada linea tenga la cantidad de campos correctos
  importe=$(echo $linea | cut -f2 -d';')
  importe=${importe%$'\r'}
  codigoConcesionario=$(echo $nombreArchivo | cut -f1 -d'_')


  if [[ ${#contratoFusionado} != 7 ]]; then
    razonRechazo="Formato de contrato fusionado invalido"
    rechazarRegistro $nombreArchivo $razonRechazo $linea
    echo 1
    return
  else
    grupo=${contratoFusionado:0:4}
    orden=${contratoFusionado:4:7}

    # Se valida que el contrato fusionado exista y que el suscriptor pueda participar
    resultadoBusqueda=`buscarContratoFusionado $grupo $orden`
    codigoRetorno=$(echo $resultadoBusqueda | cut -f1 -d';')
    if [[ $codigoRetorno != 0 ]]; then
      razonRechazo=$(echo $resultadoBusqueda | cut -f2 -d';')
      rechazarRegistro $nombreArchivo $razonRechazo $linea
      echo 1
      return
    else
      nombreSuscriptor=$(echo $resultadoBusqueda | cut -f2 -d';')
      # Se valida que el grupo este abierto
      resultadoGrupo=`chequearGrupo $grupo`
      codigoRetorno=$(echo $resultadoGrupo | cut -f1 -d';')
      if [[ $codigoRetorno != 0 ]]; then
        razonRechazo=$(echo $resultadoGrupo | cut -f2 -d';')
        rechazarRegistro $nombreArchivo $razonRechazo $linea
        echo 1
        return
      else
        # Se valida el valor del importe
        # La funcion que chequea el grupo retorna lo parámetros necesarios para validad el importe
        valorCuotaPura=$(echo $resultadoGrupo | cut -f2 -d';')
        cuotasPendientes=$(echo $resultadoGrupo | cut -f3 -d';')
        cuotasParaLicitacion=$(echo $resultadoGrupo | cut -f4 -d';')

        resultadoChequeoImporte=`chequearValorImporte $importe $valorCuotaPura $cuotasPendientes $cuotasParaLicitacion`
        codigoRetorno=$(echo $resultadoChequeoImporte | cut -f1 -d';')
        if [[ $codigoRetorno != 0 ]]; then
          razonRechazo=$(echo $resultadoChequeoImporte | cut -f2 -d';')
          rechazarRegistro $nombreArchivo $razonRechazo $linea
          echo 1;
          return
        else
          aceptarRegistro $nombreArchivo $grupo $orden $importe $fechaAdjudicacion $nombreSuscriptor
          echo 0
          return
        fi
      fi
    fi
  fi
}

procesarArchivo(){
  local filename=$1
  local fechaAdjudicacion=$2
  nombreArchivo=$(basename $filename)
  bash GrabarBitacora.sh $comando 'Archivo a procesar: '$nombreArchivo 'INFO'
  contadorProcesados=0
  contadorAceptados=0
  contadorRechazados=0

  IFS=$'\n'       # el separador de lineas es \n
  set -f          # disable globbing
  for linea in $(cat "$filename"); do
    resultadoRegistro=`procesarRegistro $linea $nombreArchivo $fechaAdjudicacion`
    if [[ $resultadoRegistro == 1 ]]; then
      contadorRechazados=$(( $contadorRechazados + 1 ))
    else
      contadorAceptados=$(( $contadorAceptados + 1 ))
    fi
    contadorProcesados=$(( $contadorProcesados + 1 ))
  done
  contadorProcesados=$(printf "%03d" $contadorProcesados)
  contadorRechazados=$(printf "%03d" $contadorRechazados)
  contadorAceptados=$(printf "%03d" $contadorAceptados)
  bash GrabarBitacora.sh $comando "Registros leídos = "$contadorProcesados" : cantidad de ofertas validas "$contadorAceptados" cantidad de ofertas rechazadas = "$contadorRechazados 'INFO'
}

main(){
  logInicio
  archivosAProcesar=$( find $OKDIR -name '*.csv.xls' | wc -l )
  if [[ $archivosAProcesar == 0 ]]; then
    bash GrabarBitacora.sh $comando 'Fin de procesar ofertas' 'INFO'
    return
  fi
  fechaAdjudicacion=`buscarFechaAdjudicacion`
  if [[ $fechaAdjudicacion != 0 ]]; then
    for filename in $OKDIR/*.csv.xls; do
        duplicado=`chequearDuplicados $(basename $filename)`
        if [[ $duplicado == 0 ]]
        then
          firstLine=$(head -n 1 $filename)
          estructuraValida=`chequearEstructuraArchivo $firstLine`
          if [[ $estructuraValida == 0 ]]
          then
            echo `procesarArchivo $filename $fechaAdjudicacion`
            bash MoverArchivos.sh $filename $PROCDIR/procesadas $comando
          else
            echo 'Se rechaza archivo '$(basename $filename)' porque no corresponde con el formato esperado'
            bash MoverArchivos.sh $filename $NOKDIR $comando
            bash GrabarBitacora.sh $comando 'Se rechaza archivo '$(basename $filename)' porque no corresponde con el formato esperado' 'WAR'
          fi
        else
          echo 'Se rechaza archivo '$(basename $filename)' por estar duplicado'
          bash MoverArchivos.sh $filename $NOKDIR $comando
          bash GrabarBitacora.sh $comando 'Se rechaza archivo '$(basename $filename)' por estar duplicado' 'WAR'
        fi
    done
  else
    echo "Error: No hay fechas de adjudicacion futuras"
  fi
  bash GrabarBitacora.sh $comando 'Fin de procesar ofertas' 'INFO'
  return
}
main
exit
