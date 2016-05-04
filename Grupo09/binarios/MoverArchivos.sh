#!/bin/bash
# Comando: MoverArchivos

Error=1
OK=0
Invocador=""

if [ $# -lt 2 -o $# -gt 3 ]; then
	exit $Error
else
	if  [ $# -eq 3 ]; then
		Invocador=$3
	fi

	Archivo=${1##*/}
	Origen=${1%/*}
	Destino=$2

	if [ ! -d "$Origen" -o  ! -d "$Destino" ]; then
		if [ ! $Invocador = "" ]; then
			./GrabarBitacora.sh $Invocador "Error al mover archivo" ERR
		fi
		exit $Error

	elif [ "$Origen" == "$Destino" ]; then
		if [ ! $Invocador = "" ]; then
			./GrabarBitacora.sh $Invocador "Error al mover archivo" ERR
		fi
		exit $Error


	elif [ -f "$Destino/$Archivo" ]; then
		if [ ! -d "$Destino/dpl" ]; then
			`mkdir "$Destino/dpl"`
		fi
    
		Num=001
		while [ -a "$Destino/dpl/$Archivo.$Num" ]; do
			Num=$[$Num+1]
			if [ $Num -gt 9 ]; then
				Num=0$Num
			elif [ $Num -gt 99 ]; then
				Num=$Num
			else
				Num=00$Num
			fi
		done
		
		cp "$Origen/$Archivo" "$Destino/dpl/$Archivo.$Num"
		rm "$Origen/$Archivo"
		exit $Ok
        
    else
	`mv "$Origen/$Archivo" "$Destino"`
 	exit $Ok
    fi
fi
