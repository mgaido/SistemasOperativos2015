## Tp Sisop - Grupo 9

## Integrantes del grupo:
- Fatur, Ivan
- Gaido, Matías
- Goicoa, Ignacio
- Gonzalez, Cristian
- Ledesma, Nicolas

## Instrucciones para la instalación

### Arranque desde el USB

Para iniciar el sistema operativo Ubuntu 14.04 LTS en modo Live, seleccionar como opción de arranque de la PC el dispositivo USB. 

## Requisitos

En caso de que *Perl* no esté instalado, ejecutar los siguientes comandos:

	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get install -y perl 

### Instalador

Luego de iniciar el SO, dirigirse al directorio */home/ubuntu/*, copiar allí:

- Grupo9.tar.gz 
- Instalador.sh

Ejecutar el script Instalador.sh con el comando:

	. Instalador.sh

## Estructura de directorios y archivos generados por defecto luego de ejecutar el instalador:

```
Grupo9
├── aceptados
├── arribados
├── binarios
│   ├── DeterminarGanadores.pl
│   ├── GenerarSorteo.sh
│   ├── GrabarBitacora.sh
│   ├── LanzarProceso.sh
│   ├── MostrarBitacora.sh
│   ├── MoverArchivos.sh
│   ├── PrepararAmbiente.sh
│ 	└── ProcesarOfertas.sh
├── bitacoras
├── config
│	└── CIPAK.cnf
├── datos
├── informes
├── maestros
│   ├── concesionarios.csv.xls
│   ├── FechasAdj.csv
│   ├── grupos.csv.xls
│   └──temaK_padron.csv.xls
├── procesados
├── rechazados
└── reportes


## Preparar el ambiente de ejecución

Finalizada la instalación, ingresar al directorio *Grupo9/binarios* mediante el comando:

cd /home/usuario/Grupo9/binario

 Luego, ejecutar el script PrepararAmbiente.sh:
 	
	. PrepararAmbiente.sh


Finalizada la inicialización, se da la posibilidad de arrancar a recibir ofertas. En caso de impedir el arranque, puede ejecutarlo manualmente con el siguiente comando: 

	. LanzarProceso.sh RecibirOfertas.sh


## Sobre la ejecucion del programa:

Para lanzar cualquier proceso se utiliza el comando Lanzar proceso de la siguiente manera:

	. LanzarProceso.sh <Nombre del proceso o comando a ejecutar>

Para detener cualquier proceso se utiliza el comando detener proceso de la siguiente manera:

	. DetenerProceso.sh <Nombre del proceso o comando a detener>