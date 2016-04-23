#!/bin/bash
# Comando: GenerarSorteo
LOGSIZE=22
LOGDIR="../bitacoras"


if [ $# -lt 2 -o $# -gt 3 ]; then 
	echo "Cantidad de parámetros inválida"
else
	WHEN=`date`
	WHO=`whoami`
	WHERE=$1
	if [ $# -eq 3 ]; then
		if [ $3 == 'INFO' -o $3 == 'WAR' -o $3 == 'ERR' ]; then
			WHAT=$3
		else
			WHAT='INFO'
		fi


	else 
		WHAT='INFO'
	fi
	WHY=$2
	Separador="="
	Linea="[$WHEN] $Separador [$WHO] $Separador [$WHERE] $Separador [$WHAT] $Separador [$WHY]"

	ArchBitacora="$LOGDIR/$WHERE.log"

	if [ -f "$ArchBitacora" ]; then
		NumLineas=`wc -l "$ArchBitacora" | sed 's/^\([0-9]*\).*/\1/g'`
		NumBytes=`wc -c "$ArchBitacora" | sed 's/^\([0-9]*\).*/\1/g'`
		LOGBYTES=`expr $LOGSIZE \* 1024`

		if [ "$NumBytes" -ge "$LOGBYTES" ]; then
			i=1	
			while [ $NumLineas -gt 50 ]; do
				sed -i '1d' "$ArchBitacora"
				i=`expr $i + 1`
				NumLineas=`wc -l "$ArchBitacora" | cut -f1 -d' '`	
			done
			echo "Log exedido">>"$ArchBitacora"
		fi
		echo $Linea>>"$ArchBitacora"
	else
		echo $Linea>"$ArchBitacora"
	fi

fi
