#!/bin/bash
# Comando: GenerarSorteo
PROCDIR="../procesados"
MAEDIR="../maestros"
OKDIR="../aceptados"
NOKDIR="../rechazados"

function Fvector {
	ValoresPorSortear=168
	NumArch=1
	Vect=''
	while [ $NumArch -le $ValoresPorSortear ]; do
		if [ $NumArch -ne $ResultadoSorteo ]; then
			if [ $NumArch -ne 0 ]; then
				Vect="$Vect,$NumArch"
				NumArch=$[$NumArch+1]
			else
				Vect="$NumArch"
				NumArch=$[$NumArch+1]
			fi
		else
			NumArch=$[$NumArch+1]
		fi
	done
	Vect=$Vect,
	#echo $Vect>plop
}

function FCvector {
	Vect=`echo $Vect | sed s/,$ResultadoSorteo,/,/g`
	#echo $Vect>plop
	#echo $Vect
}

if ! [ -a $MAEDIR"/FechasAdj.csv" ]; then
	exit
fi
Lineas=`wc -l $MAEDIR"/FechasAdj.csv" | sed 's/^\([0-9]*\).*/\1/g'`
Palabras=`wc -w $MAEDIR"/FechasAdj.csv" | sed 's/^\([0-9]*\).*/\1/g'`
if [ $Lineas -eq 0 ]; then
	./MoverArchivos.sh "$MAEDIR/FechasAdj.csv" $NOKDIR
	exit
elif [ $Palabras -lt 1 ]; then
	./MoverArchivos.sh "$MAEDIR/FechasAdj.csv" $NOKDIR
	exit
else
	for (( linea=1; linea<=$Lineas; linea=$[$linea+1] )); do
		./GrabarBitacora.sh GenerarSorteo "Inicio de Sorteo" INFO
		IdSorteo=1
		nombreArch=`head -$linea $MAEDIR"/FechasAdj.csv" | tail -1 | sed 's/^\([^;]*\).*/\1/g' | sed 's/\//-/g'`
		ResultadoSorteo=169
		IteracionSorteo=1
		Fvector
		#echo $Vect
		while [ $IteracionSorteo -le 168 ]; do
			Random=$[($RANDOM%$ValoresPorSortear)+1]
			ExpReg="s/,"
			#echo "VAlor RAndom $Random"
			Num1=1
			while [ $Num1 -le $ValoresPorSortear ]; do
				if [ $Num1 -ne $ValoresPorSortear ]; then
					if [ $Num1 -eq $Random ]; then
						ExpReg=$ExpReg"\([0-9]*\),"
					else
						ExpReg=$ExpReg"[0-9]*,"
					fi
				else
					if [ $Num1 -eq $Random ]; then
						ExpReg=$ExpReg"\([0-9]*\),"
					else
						ExpReg=$ExpReg"[0-9]*,"
					fi
				fi
				Num1=$[$Num1+1]
			done
			ExpReg=$ExpReg"/\1/g"
			ValoresPorSortear=$[$ValoresPorSortear-1]
			ResultadoSorteo=`echo $Vect | sed $ExpReg`
			#echo "Valor que sale por ER "$ResultadoSorteo
			if ! [ -d $PROCDIR"/sorteos" ]; then
				`mkdir $PROCDIR"/sorteos"`
			fi
			
			if [ -a $PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt" ]; then
				CantLineas=`wc -l $PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt" | sed 's/^\([0-9]*\).*/\1/g'`
				while [ $CantLineas -gt 167 ]; do
					IdSorteo=$[$IdSorteo+1]
					if [ -a $PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt" ]; then
					CantLineas=`wc -l $PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt" | sed 's/^\([0-9]*\).*/\1/g'`
					else
					CantLineas=0
					fi
				done
				if [ -a $PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt" ]; then
					echo "Numero de Orden $IteracionSorteo -> $ResultadoSorteo">>$PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt"
				else
					echo "Numero de Orden $IteracionSorteo -> $ResultadoSorteo">$PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt"
				fi
			else
				echo "Numero de Orden $IteracionSorteo -> $ResultadoSorteo">$PROCDIR"/sorteos/ID$IdSorteo"_$nombreArch".txt"
			fi
			IteracionSorteo=$[$IteracionSorteo+1]
			FCvector
	

		done
		./GrabarBitacora.sh GenerarSorteo "Fin de Sorteo" INFO
	done
	#echo "">$MAEDIR"FechasAdj.csv"
	./MoverArchivos.sh "$MAEDIR/FechasAdj.csv" $OKDIR
fi
