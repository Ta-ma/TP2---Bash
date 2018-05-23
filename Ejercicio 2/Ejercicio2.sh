#!/bin/bash  

#Ejercicio 1 -TP2 Primer Entrega
#Grupo:

#Gómez Markowicz, Federico - 38858109
#Kuczerawy, Damián - 37807869
#Mediotte, Facundo - 39436162
#Siculin, Luciano - 39213320
#Tamashiro, Santiago - 39749147

mostrar_ayuda() {
	echo "./Ejercicio2.sh <archivo1> <archivo2>"
	echo "Donde:"
	echo "<archivo1> -> es el archivo de texto plano que se quiere normalizar"
	echo "<archivo2> -> es el archivo de texto que contiene las palabras que no deben cambiar en el archivo recibido como primer parametro"
	echo "Ejemplo: ./Ejercicio2.sh arch.txt pmayus.txt"
}

error_gen() {
    echo $1 >&2
    echo "Utilice la opción -h para ver como se utiliza este comando." >&2 
    exit
}

arch1=
arch2=
while [ $# -ne 0 ]; do
    case $1 in
        -h|-\?|-help)
            mostrar_ayuda
        ;;
        -?*)
            error_gen "Este script no acepta ningún parámetro opcional!" >&2
        ;;
        *)
            if [ -z $arch1 ]; then
                arch1="$1"
            elif [ -z $arch2 ]; then
                arch2="$1"
            else
                error_gen "Parámetros incorrectos. Se enviaron más de 2 archivos."
            fi
    esac 
    shift
done

if [ -z $arch1 ]; then
    error_gen "No se envió ningún archivo por parámetro."
elif [ ! -f $arch1 ]; then
    error_gen "$arch1 no existe o no es un archivo regular."
else
    nombre1=$(basename -- "$arch1")
    extension1="${nombre1##*.}"
    if [ ! $extension1 = 'txt' ]; then
        error_gen "El archivo 1 solo puede tener .txt como extensión."
    fi
fi

if [ -z $arch2 ]; then
    error_gen "No se envió el archivo 2 por parámetro."
elif [ ! -f $arch2 ]; then
    error_gen "$arch2 no existe o no es un archivo regular."
else
    nombre2=$(basename -- "$arch2")
    extension2="${nombre2##*.}"
    if [ ! $extension2 = 'txt' ]; then
        error_gen "El archivo 2 solo puede tener .txt como extensión."
    fi
fi

file -i "$arch1" | grep text/plain >> /dev/null
if [ $? != 0 ]
then
	echo "El archivo $arch1 enviado como parametro no es un archivo plano"
	exit
fi

cp "$arch1" "$arch1".bak
dest=/tmp/`basename "$arch1"`.$$

sed 's/[A-Z]*/\L&/g' "$arch1" > "$dest" # Pone las siguientes letras en minúscula
sed -i 's/^./\u&/' "$dest" # Pone la primer letra de cada linea en mayúscula
sed -i -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/' "$dest" # Elimina espacios de más
sed -i 's/\.[a-z]/\U&/g' "$dest" # Mayus después de los puntos
sed -i 's/[.,;:]/& /g' "$dest" # Agrega espacios
sed -i 's/\s$//g' "$dest" # Elimino los espacios que agregué al pedo

# dejo ciertas palabras iguales
palabras=$(echo $(cat "$arch2") | tr ";" "\n")
for palabra in $palabras; do
    sed -i "s/$palabra/$palabra/gI" "$dest"
done

mv "$dest" "$arch1"