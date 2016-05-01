tar -xvzf Grupo09.tgz
cd ./Grupo09/config/
if [[ -f CIPAK.cnf ]]; then #si no esta instalado esto da false 
    echo Ya esta creado
else
    echo "GRUPO=/home/$USER/Grupo09=$USER=$(date '+%Y-%m-%d %H:%M:%S')
CONFDIR=/home/$USER/Grupo09/config=$USER=$(date '+%Y-%m-%d %H:%M:%S')
BINDIR=/home/$USER/Grupo09/binarios=$USER=$(date '+%Y-%m-%d %H:%M:%S')
MAEDIR=/home/$USER/Grupo09/maestros=$USER=$(date '+%Y-%m-%d %H:%M:%S')
ARRIDIR=/home/$USER/Grupo09/arribados=$USER=$(date '+%Y-%m-%d %H:%M:%S')
OKDIR=/home/$USER/Grupo09/aceptados=$USER=$(date '+%Y-%m-%d %H:%M:%S')
PROCDIR=/home/$USER/Grupo09/procesados=$USER=$(date '+%Y-%m-%d %H:%M:%S')
INFODIR=/home/$USER/Grupo09/informes=$USER=$(date '+%Y-%m-%d %H:%M:%S')
LOGDIR=/home/$USER/Grupo09/bitacoras=$USER=$(date '+%Y-%m-%d %H:%M:%S')
NOKDIR=/home/$USER/Grupo09/rechazados=$USER=$(date '+%Y-%m-%d %H:%M:%S')
CONFDIR=/home/$USER/Grupo09/config=$USER=$(date '+%Y-%m-%d %H:%M:%S')
IDSORTEO=1=$USER=$(date '+%Y-%m-%d %H:%M:%S')
" > CIPAK.cnf
fi
cd ..