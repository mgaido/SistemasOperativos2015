#!/bin/bash
# Comando: Start



Error=1
OK=0

#Pueden venir 2 o 3 parametros.
if [ $# -lt 2 -o $# -gt 3 ]; then
	exit $Error
else
	#Si vienen 3 es porque el ultimo es el invocador, opcional
	if  [ $# -eq 3 ]
	then
		Invocador=$3
	fi
	Archivo=${1##*/}
	Origen=${1%/*}
	Destino=$2

	#Si el origen o el destino no existen retornar error
	if [ ! -d "$Origen" -o  ! -d "$Destino" ]; then
		exit $Error

	#Si el origen es igual al destino no mover
	elif [ "$Origen" == "$Destino" ]; then
		exit $Error

	#Si el Archivo ya existe en el Destino generer un duplicado
	elif [ -f "$Destino/$Archivo" ]; then
		#Si no existe un subdirectorio /dup en Destino
		if [ ! -d "$Destino/dpl" ]; then
		#Creo el subdirectorio
			`mkdir "$Destino/dpl"`
		fi
                
		#Obtengo el numero de secuencia
		NumSec=`cat "$CONFDIR/Installer.conf" | fgrep 'NUMSEC' | cut -f2 -d'='`
	
		#Incremento el numero de secuencia        
        NumSec=`expr $NumSec + 1`
        
        #Obtengo el usuario
        Usuario=`whoami`

		#Obtengo la fecha
		Fecha=`date`
    
		Num=1
		while [ -a $Archivo$Num ]; do
			Num=$[$Num+1]
			if [ $Num -gt 9 ]; then
				Num="0$Num"
			elif [ $Num -gt 99 ]; then
				Num="$Num"
			else
				Num="00$Num"
		done
		

		#Copio el archivo a Destino/dup
		cp "$Origen/$Archivo" "$Destino/dup/$Archivo.$Num"
		
			#Borro el archivo
		rm "$Origen/$Archivo"
		
		exit $Ok
        
    else
	#Muevo de destino
	`mv "$Origen/$Archivo" "$Destino"`
	
 	exit $Ok
    fi
fi
