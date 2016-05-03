#!/usr/bin/perl
use Data::Dumper;

	#
	# #< para leer
$dir_reportes = "/home/cristian/Dropbox/SisOp/tp/sisop/Gruopo09/procesados/reportes/";
$dir_licitacion = "/home/cristian/Dropbox/SisOp/tp/sisop/Gruopo09/procesados/validas/";
$directorio = "/home/cristian/Dropbox/SisOp/tp/sisop/Gruopo09/procesados/sorteos/";
$dir_grupo = "/home/cristian/Dropbox/SisOp/tp/sisop/Grupo09/maestros/grupos.csv.xls";
$dir_clientes = "/home/cristian/Dropbox/SisOp/tp/sisop/Grupo09/maestros/temaK_padron.csv.xls";
$grabar = 0; #seria falso
$cantidad_consultas = 11;

#
# $cadena = "A -a";
# if ($cadena =~ /A$/){print "tiene una A\n";}
# if ($cadena =~ /B$/){print "tiene una B\n";}
# if ($cadena =~ /C$/){print "tiene una C\n";}
# if ($cadena =~ /A -a$/){print "Ayuda A\n";}

if (un_solo_proceso() == 0){
	print "No se puede ejecutar porque ya existe otro comando en ejecución\n";
	exit;
	}
	if (ambiente_inicializado() == 0){
		print "No se puede ejecutar porque al ambiente no inicializo de manera correcta\n";
		print "Por favor revise que las siguientes carpetas existan:\n";
		print "-/procesados/sorteo/\n";
		print "-/procesados/validas/\n";
		exit;
	}
menu_principal();




sub ambiente_inicializado(){
	if (opendir(DIR,$directorio) && opendir(OTRO_DIR,$dir_licitacion)){
		#print "existen ambas carpetas\n";
		close(DIR);
		close(OTRO_DIR);
		return 1;
	}
	else{
		#print "no existen ambas carpetas sorteos";
		return 0;
	}
}

sub un_solo_proceso{
	system("clear");
	if (open(FILE, "ps -Af|")){
		$cont=0;
		while (my $linea = <FILE>){
			if($linea=~/DeterminarGanadores.pl/){
				$cont++;
			}
		}
		if ( 1 < $cont ){
			return 0;
		}
		return 1;
	}
	return 1;
}




sub menu_principal(){
	$cantidad_consultas--;
	system("clear");
	print "Bienvenido al programa para Determinar ganadores                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	print "A - Resultado general del sorteo\n";
	print "B - Ganadores por sorteo\n";
	print "C - Ganadores por licitación\n";
	print "D - Resultados por grupo\n";
	print "Si desea salir, no ingrese ninguna letra\n";
	elegir_opcion();
}

#Esta subrutina se invoca cuando el usuario pide respescto del menu principal
sub menu_principal_ayuda(){
	system("clear");
	print "Bienvenido al programa para Determinar ganadores                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	print "[A] - Resultado general del sorteo\n";
	print "[B] - Ganadores por sorteo\n";
	print "[C] - Ganadores por licitación\n";
	print "[D] - Resultados por grupo\n";
	print "Eliga una opción A B C D\n";
	print "Si desea ayuda para una opción ingrese: [opción] -a (A -a)\n";
	print "Si desea que la consulta sea grabada en un archivo ingrese: [opción] -g (B -g)\n";
	print "Si desea salir, no ingrese ninguna letra\n";
	elegir_opcion();
}

sub solicitar_id{
	print "Por favor ingrese el ID del sorteo que desea procesar:";
	my $id = <STDIN>;
	chomp $id;
	if ($id eq "-a"){
		print "Debe ingresar un valor numérico\n";
		$id = &solicitar_id();
	}
	$id;
}

sub elegir_opcion{
	print "Por favor eliga un opción: ";
	my $opcion = <STDIN>;
	chomp $opcion;
	print "opcion:$opcion";
	if ($opcion ne "") {
		if ($opcion =~ /-g/){
			$grabar = 1;
			print "debo grabar";
			if (!opendir(DIR,$dir_reportes)){system("mkdir $dir_reportes");} else {close(DIR);}
	}else{print "no debo grabar";$grabar = 0;}
		if ($opcion =~ /A$/ || $opcion =~ /A -g$/){&opcion_a();exit;}
		if ($opcion =~ /B$/ || $opcion =~ /B -g$/){&opcion_b();exit;}
		if ($opcion =~ /C$/ || $opcion =~ /C -g$/){&opcion_c();exit;}
		if ($opcion =~ /D$/ || $opcion =~ /D -g$/){&opcion_d();exit;}
		if ($opcion =~ /A -a$/){ayuda_a();exit;}
		if ($opcion =~ /B -a$/){ayuda_b();exit;}
		if ($opcion =~ /C -a$/){ayuda_c();exit;}
		if ($opcion =~ /D -a$/){ayuda_d();exit;}
		if ($opcion eq "-a"){&menu_principal_ayuda();exit;}
	}
}


sub ayuda_a(){
	system("clear");
	print "Bienvenido al programa para Determinar ganadores                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	print "[A] - Resultado general del sorteo\n";
	print "B - Ganadores por sorteo\n";
	print "C - Ganadores por licitación\n";
	print "D - Resultados por grupo\n";
	print "\n";
	print "Con esta opción debe debe ingresar un ID de sorteo\n";
	print "Se mostrará toda la información respecto a ID ingresado\n";
	print "La información a mostrar será con el siguiente formato:\n";
	print "\n";
	print "Nro. de Sorteo XX, le correspondió al número de orden YY\n";
	print "\n";
	print "Si desea salir, no ingrese ninguna letra\n";
	elegir_opcion();
}

sub opcion_a{
	system("clear");
	print "Resultado general del sorteo                                           Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	my $id = &solicitar_id();
	#sorteo tiene el formato sorteo{orden} = sorteo
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
	my %hash_sorteo = &abrir_archivo_sorteo($nombre_archivo);
	#%hash va a seguir el formato %hash{sorteo} = orden;
	my %hash;
	$hash{$hash_sorteo{$_}} = $_ for(keys %hash_sorteo);
	system("clear");
	if ($grabar == 1) {
		print "voy a grabar";
		my $nombre = $dir_reportes.$nombre_archivo.".txt";
		if (open(archivo,">$nombre")){
			print "cree la carpeta";
		}
	}
	if ($grabar == 1){
		print archivo "Resultado general del sorteo $id                                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";

	}
	print "Resultado general del sorteo $id                                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	for($i = 1; $i < 169;$i++){
		my $nro = sprintf("%03d",$i);
		my $cadena =  "Nro. de Sorteo $nro, le correspondió al número de orden $hash{$nro}\n";
		print $cadena;
		if ($grabar == 1){print archivo $cadena;}
	}
	print "\n";
	&realizar_consulta();
}

sub ayuda_b(){
	system("clear");
	print "Bienvenido al programa para Determinar ganadores                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	print "A - Resultado general del sorteo\n";
	print "[B] - Ganadores por sorteo\n";
	print "C - Ganadores por licitación\n";
	print "D - Resultados por grupo\n";
	print "\n";
	print "Con esta opción debe debe ingresar un ID de sorteo\n";
	print "Se mostrará toda la información respecto a ID ingresado y los Grupos ingresados\n";
	print "La información a mostrar será con el siguiente formato:\n";
	print "\n";
	print "Ganador por sorteo del grupo XX: Nro de orden YY,ZZ(Nro de sorteo WW)\n";
	print "\n";
	print "Los grupos que no se encuentren o sean CERRRADOS no se procesan\n";
	print "Si desea salir, no ingrese ninguna letra\n";
	elegir_opcion();
}



sub opcion_b{
	system ("clear");

	print "Ganadores por sorteo                                                   Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	#aca me pude pedir ayuda
	my $id = &solicitar_id();
	my @grupo_lista = &pedir_grupo();
	#print "grabar vale :$grabar\n";
	if ($grabar == 1) {
			print "voy a grabar\n";
			my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
			my @lista_aux = split("_",$nombre_archivo);
			my $nombre = "ID".$id."_".$string_grupo."_".@lista_aux[1];
			#print "nombre del archivo:$nombre\n";
			my $direccion = $dir_reportes.$nombre."txt";
			#print "la dir es:$direccion\n";
			if (open(otro_archivo,">$direccion")){
				print "cree la carpeta";
			}
	}
	system("clear");
	foreach $grupo(@grupo_lista){
		chomp $grupo;
		my @list_sorteo = obtener_ganador_grupo($id,$grupo);
		my $size = @list_sorteo;
		if ($size == 1) {print "El grupo $grupo no se encuentra en la lista\n";}
		else{
			my $cadena = "Ganador por sorteo del grupo $grupo: Nro de orden @list_sorteo[0],@list_sorteo[1](Nro de sorteo @list_sorteo[2])\n";
			print $cadena;
			if ($grabar == 1) {
				#print "ep";
				print otro_archivo $cadena;
				#print otro_archivo "sasasasa";
			}
		}
	}
	print "\n";
	&realizar_consulta();
}

sub ayuda_c(){
	system("clear");
	print "Bienvenido al programa para Determinar ganadores                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	print "A - Resultado general del sorteo\n";
	print "B - Ganadores por sorteo\n";
	print "[C] - Ganadores por licitación\n";
	print "D - Resultados por grupo\n";
	print "\n";
	print "Con esta opción debe debe ingresar un ID de sorteo\n";
	print "Se mostrará toda la información respecto al ID y los Grupos ingresado\n";
	print "La información a mostrar será con el siguiente formato:\n";
	print "\n";
	print "Ganador por licitación del grupo XX: numero de orden YY, /*nombre*/ con /*importe*/ (Nro de Sorteo ZZ)\n";
	print "\n";
	print "Si desea salir, no ingrese ninguna letra\n";
	elegir_opcion();
}


sub opcion_c{
	system ("clear");
	print "Ganadores por licitación                                               Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	my $id = &solicitar_id();
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
	my %hash_sorteo = abrir_archivo_sorteo($nombre_archivo);
	my @grupo_lista = &pedir_grupo();
	system("clear");
	if ($grabar == 1) {
			my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
			my @lista_aux = split("_",$nombre_archivo);
			my $nombre = "ID".$id."_".$string_grupo."_".@lista_aux[1];
			my $direccion = $dir_reportes.$nombre."txt";
			#print "la dir es:$direccion\n";
			open(otro_archivo,">$direccion");
	}
	foreach $grupo(@grupo_lista){
		chomp $grupo;
		my @lista = obtener_ganador_licitacion($id,$grupo);
		my $cadena = "Ganador por licitación del grupo $grupo: numero de orden @lista[0], @lista[1] con @lista[2] (Nro de Sorteo @lista[3])\n";
		if($grabar == 1) {print otro_archivo $cadena;}
		print $cadena;
	}
	print "\n";
	&realizar_consulta();
}

sub ayuda_d(){
	system("clear");
	print "Bienvenido al programa para Determinar ganadores                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	print "A - Resultado general del sorteo\n";
	print "B - Ganadores por sorteo\n";
	print "C - Ganadores por licitación\n";
	print "[D] - Resultados por grupo\n";
	print "\n";
	print "Con esta opción debe debe ingresar un ID de sorteo\n";
	print "Se mostrará toda la información respecto a ID ingresado y los Grupos ingresados\n";
	print "La información a mostrar será con el siguiente formato:\n";
	print "\n";
	print "Ganadores por Grupo en el acto de adjudicación de fecha:XX, Sorteo: IDYY)\n";
	print "/*grupo*/-/*nro de orden*/ S ( /*nombre*/)\n";
	print "/*grupo*/-/*nro de orden*/ L ( /*nombre*/)\n";
	print "\n";
	print "Los grupos que no se encuentren o sean CERRRADOS no se procesan\n";
	print "Si desea salir, no ingrese ninguna letra\n";
	elegir_opcion();
}


sub opcion_d{
	system ("clear");
	print "Ganadores por grupo                                                    Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	my $id = &solicitar_id();
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
	my %hash_sorteo = abrir_archivo_sorteo($nombre_archivo);
	my @list_aux = split("_",$nombre_archivo);
	print "el primer elemento es: @list_aux[0]";
	my $fecha = @list_aux[1];
	my @grupo_lista = &pedir_grupo();
	system("clear");
	print "Ganadores por Grupo en el acto de adjudicación de fecha:$fecha, Sorteo: ID$id)\n";
	foreach $grupo(@grupo_lista){
		chomp $grupo;

		if ($grabar == 1) {
				my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
				my @lista_aux = split("_",$nombre_archivo);
				my $nombre = "ID".$id."_".$grupo."_".$fecha;
				my $direccion = $dir_reportes.$nombre."txt";
				#print "la dir es:$direccion\n";
				open(otro_archivo,">$direccion");
		}

		@lista_licitacion = &obtener_ganador_licitacion($id,$grupo);
		@lista_sorteo = &obtener_ganador_grupo($id,$grupo);
		$una_cadena = "$grupo-@lista_sorteo[0] S ( @lista_sorteo[1])\n";
		$otra_cadena = "$grupo-@lista_licitacion[0] L ( @lista_licitacion[1])\n";

		if ($grabar == 1){
			print otro_archivo $una_cadena;
			print otro_archivo $otra_cadena;
		}
		print $una_cadena;
		print $otra_cadena;
		close(otro_archivo);
	}
	print "\n";
	&realizar_consulta();
}


sub obtener_ganador_licitacion{
	my $id = @_[0];
	my $grupo = @_[1];
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
	my %hash_sorteo = abrir_archivo_sorteo($nombre_archivo);
	my @list_aux = &obtener_ganador_grupo($id,$grupo);
	my %licitacion = &abrir_archivo_licitacion($nombre_archivo,$grupo,@list_aux[0]);
	my @importes = (keys %licitacion);
	my @importes_sort = sort { $b <=> $a } @importes;
	$ordenes_ganadores_cadena = $licitacion{@importes_sort[0]}; #obtengo aquellos de mayor importe
	@ganadores_lista = split(",",$ordenes_ganadores_cadena);
	@ganadores_lista_sort = sort{$hash_sorteo{$b} <=> $hash_sorteo{$a}}@ganadores_lista;
	my $orden_ganador = @ganadores_lista_sort[0];
	my $importe = @importes_sort[0];
	my $nro_sorteo_ganador_lic = $hash_sorteo{$orden_ganador};
	my $nombre_ganador = &obtener_nombre($grupo,$orden_ganador);
	#print "Ganador por licitación del grupo $grupo: numero de orden $orden_ganador, $nombre_ganador con $importe (Nro de Sorteo $nro_sorteo_ganador_lic)\n";
	my @lista_return = ($orden_ganador,$nombre_ganador,$importe,$nro_sorteo_ganador_lic);
	@lista_return;
}

sub realizar_consulta(){
	if ($cantidad_consultas >= 1){
		print "Nueva Consulta                                                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
		print "¿Desea realizar otra consulta? Escriba cualquier letra en caso afirmativo:";
		my $respuesta = <STDIN>;
		chomp $respuesta;
		if ($respuesta ne ""){
			&menu_principal();
		}
		else{
			print "Gracias por usar el programa!\n";
		}
	}else{print "Ya no cuenta con consultas disponibles\n";}
}

	#Esta subrutina debe
sub pedir_grupo{
	print "\n";
	print "Solicitación de grupos/s a procesar\n";
	print "Si desea ingresar un rango de grupos ingrese: grupo1-grupo2\n";
	print "Si desea ingresar distinto grupos ingrese: grupo1 grupo2 grupo3\n";
	print "Si desea procesar TODOS los grupos no debe ingresar nada\n";
	print "Por favor ingrese el/los grupo/s que desea procesar:";
	$string_grupo = <STDIN>;
	chomp $string_grupo;
	if ($string_grupo=~/-/){
		@lista_aux = split ("-",$string_grupo);
		@lista = (@lista_aux[0]..@lista_aux[1]);
	}else{
		@lista = split(" ",$string_grupo);
	}
	@lista;
}

#Esta subrutina se encarga de dado un ID de sorteo y un nro de Grupo poder
#obtener el ganador del grupo por sorteo
sub obtener_ganador_grupo{
	#print "obtener_ganador_grupo...\n";
	my $ID = @_[0];
	my $GRUPO = @_[1];
	#print "id:$ID grupo:$GRUPO";
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($ID);
	#obtengo los participantes del grupo
	my %participantes_del_grupo = &buscar_grupo($GRUPO);
	#print "participantes_del_grupo\n";
	#print "$_ a $participantes_del_grupo{$_}" for (keys %participantes_del_grupo);
	$size = (keys %participantes_del_grupo);
	if ($size != 1){
		#obtengo el sorteo según el ID que me pasaron
		my %sorteo = &abrir_archivo_sorteo($nombre_archivo);
		my %nro_sorteo_participantes;
		#acá voy obteniendo el nro de sorteo de cada participante
		for(keys %participantes_del_grupo){
			$nro_sorteo = $sorteo{$_};
			$nro_sorteo_participantes{$nro_sorteo} = $_;
		}
		my @nros_sorteos = (keys %nro_sorteo_participantes);#obtengo los nros de sorteo
		my @nros_de_sorteos_sort = sort { $b <=> $a } @nros_sorteos;
		my $nro_orden_ganador = $nro_sorteo_participantes{@nros_de_sorteos_sort[0]};
		my $nombre_ganador = $participantes_del_grupo{$nro_orden_ganador};
		my @list = ($nro_orden_ganador,$nombre_ganador,@nros_de_sorteos_sort[0]);
		@list;
	}
}


#esta subrutina debe recibir el ID del sorteo y devolver el nombre del archivo
#que tiene el ID ingresado
sub obtener_nombre_archivo_sorteo{
	my $comparar = "ID".@_[0]."_";
	if(opendir(DIR,$directorio)){
		@lista = readdir(DIR);
		foreach $file (@lista){
			if ($file=~/$comparar/){
				$nombre_archivo = $file;
			}
			close(DIR);
		}
	}
	$nombre_archivo;
}


#Esta subrutina se encarga de encontrar el nombre del archivo de una licitacion
#dada una fecha
sub obtener_nombre_archivo_licitacion{
	$comparar = @_;
	if(opendir(DIR,$dir_licitacion)){
		@lista = readdir(DIR);
		foreach $file (@lista){
			if ($file=~/$comparar/){
				$nombre_archivo = $file;
			}
			close(DIR);
		}
	}
	$nombre_archivo;
}


#Esta subrutina se encarga de abrir el archivo del grupo y verificar de que el
#grupo es ABIERTO, en caso de cumplirse llama a &procesar_grupo y retorna
#lo integrantes del mismo
#Si el grupo es CERRADO sólo imprime un aviso
sub buscar_grupo{
	my %clientes = {};
	my $estado = 0;
	if (open(archivo,"<",$dir_grupo)){
		while(my $linea = <archivo>){
			chomp $linea;
			@lista = split(";",$linea);
			if (@lista[0] eq @_[0]){
				if (@lista[1] eq "ABIERTO"){
					%clientes = procesar_grupo(@lista[0]);
					$estado = 1;
					last;
				}
				else{
					print "No se puede procesar porque: El grupo @_[0] es CERRADO\n";
					last;
				}
			}
		}
	%clientes;
	}
}



sub obtener_nombre{
	$grupo_procesar = @_[0];
	$orden_procesar = @_[1];
	$nombre;
	if (open(archivo,"<",$dir_clientes)){
		while ($linea = <archivo>){
			@lista = split(";",$linea);
			if (@lista[0] eq $grupo_procesar && $orden_procesar eq @lista[1]){
				$nombre = @lista[2];
				last;
			}
		}
	$nombre;
	}
}

#Esta subrutina recibe un grupo y se encarga de cargar a los clientes que pueden
#particar en un hash para luego devolverlo
sub procesar_grupo{
	my %participantes;
	$grupo_procesar = @_[0];
	if (open(archivo,"<",$dir_clientes)){
		while ($linea = <archivo>){
			@lista = split(";",$linea);
			if (@lista[0] eq $grupo_procesar){
				$participacion = @lista[5];
				if ($participacion != 0){
					$participantes{@lista[1]} = @lista[2]
				}
			}
		}
	}
	%participantes;
}


#Esta subrutina abre el archivo de un sorteo y lo coloca todo entro de un hash
#con el formato de $sorteo{nro de orden} = nro de sorteo
sub abrir_archivo_sorteo
{
	my %sorteo;
	if (open(archivo,"<",$directorio.@_[0])){
			while(my $linea = <archivo>){
				chomp $linea;
				@lista = split(",",$linea);
				$nro_orden = sprintf("%03d",@lista[0]);
				$nro_sorteo = sprintf("%03d",@lista[1]);
				$sorteo{$nro_orden} = $nro_sorteo;
			}
			close(archivo);
			%sorteo;
	}
}


#Esta sub se encarga de abrir el archivo con la fecha indicada y carga los clientes
#de cierto grupo, el tercer parametro es el ganador por sorteo de tal manera no
#cargarlo en el hash
#abrir_archivo(ID1_13-10-2016.txt,7886)
sub abrir_archivo_licitacion
{
	my %licitacion = {};
	my $orden_ganador_sorteo = @_[2];
	my $grupo = @_[1];
	my $cadena = @_[0];
	#recibo la cadena ID1_13-10-2016.txt
	my @lista = split ("_",$cadena);
	#(ID1,13-10-2016)
	my $fecha = @lista[1];
	#fecha = 13-10-2016
	my @lista_aux = split("-",$fecha);
	#@lista_aux = (13,10,2016)
	my $direccion = @lista_aux[2].@lista_aux[1].@lista_aux[0];
	#$direccion = 20161013
	my $nom_archivo = &obtener_nombre_archivo_licitacion($direccion);
	if (open(archivo,"<",$dir_licitacion.$nom_archivo)){
		while(my $linea = <archivo>){
			@lista = split(";",$linea);
			my $orden = @lista[4];
			my $grupo_cheq = @lista[3];
			if ($grupo_cheq eq $grupo && $orden_ganador_sorteo ne $orden){
				#agrego a mi hash
				#$licitacion{importe}
				my $clientes = $licitacion{@lista[5]};
				if ($clientes eq "") {
					$licitacion{@lista[5]} = "".$orden;
				}else{
					$licitacion{@lista[5]} = $clientes.",".$orden;
				}
			}
		}
		%licitacion;
	}
}
