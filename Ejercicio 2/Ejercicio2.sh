#!/bin/bash  

#Ejercicio 1 -TP2 Primer Entrega
#Grupo:

#Gómez Markowicz, Federico - 38858109
#Kuczerawy, Damián - 37807869
#Mediotte, Facundo - 39436162
#Siculin, Luciano - 39213320
#Tamashiro, Santiago - 39749147

mostrar_ayuda(){
	echo "./Ejercicio2.sh <archivo1> <archivo2>"
	echo "Donde:"
	echo "<archivo1> -> es el archivo de texto plano que se quiere normalizar"
	echo "<archivo2> -> es el archivo de texto que contiene las palabras que no deben cambiar en el archivo recibido como primer parametro"
	echo "Ejemplo: ./Ejercicio2.sh arch.txt pmayus.txt"
}

IFS=''

case $1 in
	-h|-\?|-help) 
		mostrar_ayuda
		exit;;
esac
CANTPARAMETROS=$#
RUTA=$1
echo "Cantidad de parametros: $CANTPARAMETROS"
#if [ "$CANTPARAMETROS" -gt 2 ]; then
#	do
#		RUTA+=$AUX 
#		done
#else
#	RUTA=$1
#fi
echo "Path: $RUTA"

if ! [ -f "$RUTA" ]; then
	echo "Archivo $RUTA no existe o no es un archivo regular"
	exit
fi
if ! [ -f "$2" ]; then
	echo "Archivo $2 no existe o no es un archivo regular"
	exit
fi

file -i $1 | grep text/plain >> /dev/null
if [ $? != 0 ]
then
	echo "El archivo $RUTA enviado como parametro no es un archivo plano"
	exit
fi

cp $RUTA $RUTA.bak
ARCH1=/tmp/`basename $RUTA`.$$

sed 's/[A-Z]*/\L&/g' $RUTA > $ARCH1 #Pone la primer letra de cada linea en mayuscula
sed -i 's/^./\u&/' $ARCH1 #concatena todo a la primer linea
mv $ARCH1 $RUTA
