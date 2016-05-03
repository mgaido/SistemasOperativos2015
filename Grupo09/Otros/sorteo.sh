#!/bin/bash
# Comando: Start

Num=2
Vect=1
while [ $Num -lt 169 ]; do
	Vect="$Vect,$Num"
	Num=$[$Num+1]
done
echo $Vect

Num=1

while [ $Num -lt 169 ]; do
	Random=$[($RANDOM%168)+1]
	Num1=1
	ExpReg="'s/'"
	while [ $Num1 -lt 168 ]; do
		if [ $Num1 -eq $Random ]; then
			ExpReg=$ExpReg"\([0-9]*\),"
		else
			ExpReg=$ExpReg"[0-9]*,"
		fi
	done
	ExpReg=$ExpReg"[0-9]*"
done
