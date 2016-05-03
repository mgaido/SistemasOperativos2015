#!/bin/bash
# Comando: MostrarBitacora
LOGDIR="../bitacoras"

Error=1
OK=0

if [ $# -lt 1 -o $# -gt 2 ]; then
	exit $Error
else
	if [ -f $LOGDIR/$1.log ]; then
		Bitacora=`grep "$2" $LOGDIR/$1.log | sed -e 's/^\[\([^]]*\)] \= \[\([^]]*\)] \= \[\([^]]*\)] \= \[\([^]]*\)] \= \[\([^]]*\)]/"\1" "\2" "\3" "\4" "\5"\\\n/g'`
		echo -e $Bitacora
	else
		exit $Error
	fi
fi
