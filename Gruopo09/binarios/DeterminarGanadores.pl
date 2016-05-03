#!/usr/bin/perl
use Data::Dumper qw(Dumper);
use Data::Dumper;
#
# #< para leer
$dir_licitacion = "/home/cristian/Dropbox/SisOp/tp/Gruopo09/procesados/validas/";
$directorio = "/home/cristian/Dropbox/SisOp/tp/Gruopo09/procesados/sorteos/";
$dir_grupo = "/home/cristian/Dropbox/SisOp/tp/Gruopo09/maestros/grupos.csv.xls";
$dir_clientes = "/home/cristian/Dropbox/SisOp/tp/Gruopo09/maestros/temaK_padron.csv.xls";
$grabar = 0; #seria falso
$cantidad_consultas = 11;

&menu_principal();

sub menu_principal(){
	$cantidad_consultas--;
	system("clear");
	print "Bienvenido al programa para Determinar ganadores                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	print "A - Resultado general del sorteo\n";
	print "B - Ganadores por sorteo\n";
	print "C - Ganadores por licitación\n";
	print "D - Resultados por grupo\n";
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
	elegir_opcion();
}

sub solicitar_id{
	print "Por favor ingrese el ID del sorteo que desea procesar:";
	my $id = <STDIN>;
	chomp $id;
	$id;
}

sub elegir_opcion(){
	print "Por favor eliga un opción: ";
	$opcion = <STDIN>;
	chomp $opcion;
	if ($opcion eq "A"){&opcion_a();}
	if ($opcion eq "B"){&opcion_b();}
	if ($opcion eq "C"){&opcion_c();}
	if ($opcion eq "D"){&opcion_d();}
	if ($opcion eq "-a"){&menu_principal_ayuda();}
	if ($opcion eq "A -a"){print "ayuda para A\n";}
	if ($opcion eq "B -a"){print "ayuda para B\n";}
	if ($opcion eq "C -a"){print "ayuda para C\n";}
	if ($opcion eq "D -a"){print "ayuda para D\n";}
}


sub opcion_a{
	system("clear");
	print "Resultado general del sorteo                                           Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	my $id = &solicitar_id();
	#sorteo tiene el formato sorteo{orden} = sorteo
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
	my %hash_sorteo = &abrir_archivo_sorteo($nombre_archivo);
	#print "$_ a $hash_sorteo{$_}\n" for (keys %hash_sorteo);
	#%hash va a seguir el formato %hash{sorteo} = orden;
	my %hash;
	$hash{$hash_sorteo{$_}} = $_ for(keys %hash_sorteo);
	system("clear");
	print "Resultado general del sorteo $id                                       Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	#print "$_ pe $hash{$_}" for (keys %hash);
	for($i = 1; $i < 169;$i++){
		$nro = sprintf("%03d",$i);
		print "Nro. de Sorteo $nro, le correspondió al número de orden $hash{$nro}\n";
	}
	print "\n";
	&realizar_consulta();
}

sub opcion_b{
	system ("clear");
	print "Ganadores por sorteo                                                   Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	#aca me pude pedir ayuda
	my $id = &solicitar_id();
	my @grupo_lista = &pedir_grupo();
	system("clear");
	foreach $grupo(@grupo_lista){
		chomp $grupo;
		my @list_sorteo = obtener_ganador_grupo($id,$grupo);
		my $size = @list_sorteo;
		#print "Size:$size";
		if ($size == 1) {print "El grupo $grupo no se encuentra en la lista\n";}
		else{
			my $cadena = "Ganador por sorteo del grupo $grupo: Nro de orden @list_sorteo[0],@list_sorteo[1](Nro de sorteo @list_sorteo[2])\n";
			print $cadena;
		}
	}
	print "\n";
	&realizar_consulta();
}


sub opcion_c{
	system ("clear");
	print "Ganadores por licitación                                               Cantidad de consultas disponibles:[$cantidad_consultas]\n";
	my $id = &solicitar_id();
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
	my %hash_sorteo = abrir_archivo_sorteo($nombre_archivo);
	my @grupo_lista = &pedir_grupo();
	system("clear");
	foreach $grupo(@grupo_lista){
		chomp $grupo;
		my @lista = obtener_ganador_licitacion($id,$grupo);
		my $cadena = "Ganador por licitación del grupo $grupo: numero de orden @lista[0], @lista[1] con @lista[2] (Nro de Sorteo @lista[3])\n";
		print $cadena;
	}
	print "\n";
	&realizar_consulta();
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
		@lista_licitacion = &obtener_ganador_licitacion($id,$grupo);
		@lista_sorteo = &obtener_ganador_grupo($id,$grupo);
		print "$grupo-@lista_sorteo[0] S ( @lista_sorteo[1])\n";
		print "$grupo-@lista_licitacion[0] L ( @lista_licitacion[1])\n";
	}
	print "\n";
	&realizar_consulta();
}


sub obtener_ganador_licitacion{
	my $id = @_[0];
	my $grupo = @_[1];
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($id);
	my %hash_sorteo = abrir_archivo_sorteo($nombre_archivo);
	#my @grupo_lista = &pedir_grupo();
	#system("clear");
	#foreach $grupo(@grupo_lista){
	#	chomp $grupo;
	#@lista_aux = (orden_ganador,nro_sorteo_ganador)
	my @list_aux = &obtener_ganador_grupo($id,$grupo);
	#print "Estoy en la opcion c y el orden del ganador es:@list_aux[0]\n";
	my %licitacion = &abrir_archivo_licitacion($nombre_archivo,$grupo,@list_aux[0]);
	my @importes = (keys %licitacion);
	my @importes_sort = sort { $b <=> $a } @importes;
	$ordenes_ganadores_cadena = $licitacion{@importes_sort[0]}; #obtengo aquellos de mayor importe
	#print "ordenes_ganadores_cadena:$ordenes_ganadores_cadena\n";
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
	print "Por favor ingrese el/los grupo/s que desea procesar:";
	my $grupo = <STDIN>;
	chomp $grupo;
	if ($grupo=~/-/){
		@lista_aux = split ("-",$grupo);
		@lista = (@lista_aux[0]..@lista_aux[1]);
	}else{
		@lista = split(" ",$grupo);
	}
	#print "Estos son los grupos\n";
	#foreach $elemento(@lista){
	#	print "el grupo es:$elemento\n";
	#}
	@lista;
}
#Esta subrutina se encarga de dado un ID de sorteo y un nro de Grupo poder
#obtener el ganador del grupo por sorteo
sub obtener_ganador_grupo{
	#print "obtener_grupo...\n";
	my $ID = @_[0];
	my $GRUPO = @_[1];
	my $nombre_archivo = &obtener_nombre_archivo_sorteo($ID);
	#obtengo los participantes del grupo
	my %participantes_del_grupo = buscar_grupo($GRUPO);
	$size = (keys %participantes_del_grupo);
	if ($size != 1){
		#obtengo el sorteo según el ID que me pasaron
		my %sorteo = &abrir_archivo_sorteo($nombre_archivo);
		my %nro_sorteo_participantes;
		#print "$_ a $sorteo{$_}\n" for (keys %sorteo);
		#acá voy obteniendo el nro de sorteo de cada participante
		for(keys %participantes_del_grupo){
			#print "los nros de ordenesasas son:$_";
			$nro_sorteo = $sorteo{$_};
			#print "nro de sorteo:$nro_sorteo\n";
			#hash{nro de sorteo} = nro de orden
			$nro_sorteo_participantes{$nro_sorteo} = $_;
		}
		#print "$_ $nro_sorteo_participantes{$_}\n" for(keys %nro_sorteo_participantes);
		my @nros_sorteos = (keys %nro_sorteo_participantes);#obtengo los nros de sorteo
		#@nros_de_sorteos_sort = sort @nros_sorteos; #ordeno
		my @nros_de_sorteos_sort = sort { $b <=> $a } @nros_sorteos;
		my $nro_orden_ganador = $nro_sorteo_participantes{@nros_de_sorteos_sort[0]};
		my $nombre_ganador = $participantes_del_grupo{$nro_orden_ganador};
		#print "Ganador por sorteo del grupo $GRUPO: Nro de orden $nro_orden_ganador,$nombre_ganador(Nro de sorteo @nros_de_sorteos_sort[0])\n";
		my @list = ($nro_orden_ganador,$nombre_ganador,@nros_de_sorteos_sort[0]);
		@list;
	}
}


#esta subrutina debe recibir el ID del sorteo y devolver el nombre del archivo
#que tiene el ID ingresado
sub obtener_nombre_archivo_sorteo{
	#print "Entre para obtener el nombre del archivo...\n";
	$comparar = "ID".@_."_";
	if(opendir(DIR,$directorio)){
		#print "Entre en la carpeta de sorteos\n";
		@lista = readdir(DIR);
		foreach $file (@lista){
			if ($file=~/$comparar/){
				$nombre_archivo = $file;
				#print "$file \n";
			}
			close(DIR);
		}
	}
	#print "El nombre del archivo es: $nombre_archivo\n";
	$nombre_archivo;
}

sub obtener_nombre_archivo_licitacion{
	#print "Entre para obtener el nombre del archivo...\n";
	#$comparar = la fecha sin el txt
	$comparar = @_;
	if(opendir(DIR,$dir_licitacion)){
		#print "Entre en la carpeta de sorteos\n";
		@lista = readdir(DIR);
		foreach $file (@lista){
			if ($file=~/$comparar/){
				$nombre_archivo = $file;
				#print "$file \n";
			}
			close(DIR);
		}
	}
	#print "El nombre del archivo de licitacion es: $nombre_archivo\n";
	$nombre_archivo;
}


#Esta subrutina se encarga de abrir el archivo del grupo y verificar de que el
#grupo es ABIERTO, en caso de cumplirse llama a &procesar_grupo y retorna
#lo integrantes del mismo
#Si el grupo es CERRADO sólo imprime un aviso
sub buscar_grupo
{
	my %clientes = {};
	my $estado = 0;
	# print "Entre para buscar el grupo...\n";
	if (open(archivo,"<",$dir_grupo)){
		while(my $linea = <archivo>){
			chomp $linea;
			@lista = split(";",$linea);
			# print "La linea del grupo es: @lista\n";
			# print "El número del grupo es: @lista[0]\n";
			#print "El estado del grupo es: @lista[1]\n";
			if (@lista[0] eq @_[0]){
				if (@lista[1] eq "ABIERTO"){
					#print "El grupo @_[0] es ABIERTO\n";
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
		#print "Abrí el archivo \n";
		while ($linea = <archivo>){
			@lista = split(";",$linea);
			#print "if(".@lista[0]."eq".$grupo_procesar;
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
	#print "Entré para procesar el grupo\n";
	#print "El grupo a procesar es: @_\n";
	my %participantes;
	$grupo_procesar = @_[0];
	if (open(archivo,"<",$dir_clientes)){
		#print "Abrí el archivo \n";
		while ($linea = <archivo>){
			@lista = split(";",$linea);
			#print "if(".@lista[0]."eq".$grupo_procesar;
			if (@lista[0] eq $grupo_procesar){
				#print "el grupo es: @lista[0]\n";
				$participacion = @lista[5];
				if ($participacion != 0){
					#$participantes{orden} = nombre;
					#print "nombre:@lista[2]\n";
					$participantes{@lista[1]} = @lista[2]
				}
			}
		}
	}
	#print "clave:$_\n" for (keys %participantes);
	%participantes;
}



#Esta subrutina abre el archivo de un sorteo y lo coloca todo entro de un hash
#con el formato de $sorteo{nro de orden} = nro de sorteo
sub abrir_archivo_sorteo
{
	#print "abrir_archivo_sorteo";
	my %sorteo;
	if (open(archivo,"<",$directorio.@_[0])){
		#print "Pude abrir el archivo de sorteo\n";
			while(my $linea = <archivo>){
				chomp $linea;
				@lista = split(",",$linea);
				$nro_orden = sprintf("%03d",@lista[0]);
				$nro_sorteo = sprintf("%03d",@lista[1]);
				#print "nro de orden:$nro_orden y nro de sorteo:$nro_sorteo\n";
				$sorteo{$nro_orden} = $nro_sorteo;
			}
			close(archivo);
			%sorteo;
	}
}

#abrir_archivo(ID1_13-10-2016.txt,7886)
sub abrir_archivo_licitacion
{
	#print "abrir_archivo_licitacion\n";
	#print "orden del ganador:@_[2]\n";
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
		#print "pude abrir el archivo de licitacion\n";
		while(my $linea = <archivo>){
			@lista = split(";",$linea);
			#print "if (@lista[3] eq $grupo){\n";
			my $orden = @lista[4];
			my $grupo_cheq = @lista[3];
			if ($grupo_cheq eq $grupo && $orden_ganador_sorteo ne $orden){
				#print "entré\n";
				#agrego a mi hash
				#$licitacion{importe}
				my $clientes = $licitacion{@lista[5]};
				if ($clientes eq "") {
					#print "vacio\n";
					#print "clientes:$clientes\n";
					#print "palabra:$palabra\n";
					$licitacion{@lista[5]} = "".$orden;
					#print "licitacion importe:$licitacion{@lista[5]}\n";
				}else{
					$licitacion{@lista[5]} = $clientes.",".$orden;
					#print "licitacion importe:$licitacion{@lista[5]}\n";
				}
			}
		}
		#print "licitacion\n";
		#print "$_ a $licitacion{$_}\n" for (keys %licitacion);
		%licitacion;
	}
}
