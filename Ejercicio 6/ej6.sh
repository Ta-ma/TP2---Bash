#!/bin/bash

: '  
    Nombre del script: ej3.sh
    Trabajo Practico 2 - Ejercicio 3
    Grupo: 6
    Gómez Markowicz, Federico - 38858109
    Kuczerawy, Damián - 37807869
    Mediotte, Facundo - 39436162
    Siculin, Luciano - 39213320
    Tamashiro, Santiago - 39749147
'

flagf=0
declare -A array

get_help() {
	echo 'Comando ayuda:'
	echo '--------------'
	echo
	echo './ej6.sh [PATH] [-f]'
	echo
	echo 'PATH -> directorio raiz a analizar su contenido.'
	echo '-f -> (Opcional) incluye a los archivos con espacio en su nombre'	
  echo 'esta opción debe utilizarse si algún subdirectorio tiene espacio en su nombre'
  echo 'de lo contrario los resultados pueden ser impredecibles.'	
	echo
	echo 'Ejemplos: ./ej6 /var -f'
	echo '          ./ej6 /var '
	echo '          ./ej6 -h'
	exit 
}

validar(){
if [ $# -ne 1 -a $# -ne 2 ] ; then
    echo 'La cantidad de parámetros enviados es incorrecta.'
	echo 'Utilizar -h/-?/-help para ver la ayuda.'
	exit -1
fi
if [ $1 = '-f' ] ;then
	echo '-f No se encuentra en la posicion correcta.'
	echo 'Utilizar -h/-?/-help para ver la ayuda.'
	exit -2
fi
if [ $1 = '-h' -o $1 = '-help' -o $1 = '-?' ] ;then
	get_help
	exit 1
fi
if [ ! -d $1 ] ;then
	echo "El path no existe. Ingrese un path valido."
	exit -3
fi
}

validar $1 $2 $3
dir=$1

if [ "$2" = $'-f' ]; then
  IFS=$'\n'
fi

for arch in $(find $dir -type d -links 2)
do
  sizeh=$(du -h --apparent-size "$arch" | cut -f1)
  sizeb=$(du -b --apparent-size "$arch" | cut -f1)
  cont=$(find $arch -type f | wc -l)
  echo "$arch $sizeh ($sizeb bytes) $cont archivos"
done | sort -t " " -k 3 -r | head -10
