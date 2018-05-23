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

mostrar_ayuda() {
    echo './ej3.sh <archivoA> <archivoB> [-i]'
    echo 'Donde:'
    echo '<archivoA> -> es el archivo que contiene las palabras a buscar.'
    echo '<archivoB> -> es el archivo de texto donde se buscarán las palabras.'
    echo 'El primer archivo enviado por parámetro será considerado como A y el segundo como B.'
    echo 'Tales archivos solo pueden ser de formato .txt y deben tener contenido.'
    echo '[-i] -> Parámetro opcional que indica que la búsqueda será case-insensitive.'
    echo 'Ejemplo: ./ej3.sh A.txt B.txt -i'
    echo '-------------------------------------------------------------------'
    echo 'Muestra la cantidad de veces que aparecen las palabras del archivo A en el archivo B.'
    echo 'Se informa además la cantidad de palabras del archivo B que no existen en el archivo A.'
    exit
}

error_gen() {
    echo $1 >&2
    echo "Utilice la opción -h para ver como se utiliza este comando." >&2 
    exit
}

archA=
archB=
insensitive=
while [ $# -ne 0 ]; do
    case $1 in
        -h|-\?|-help)
            mostrar_ayuda
        ;;
        -i)
            if [ -z $insensitive ]; then
                insensitive=true
            else
                error_gen "Se enviaron varias veces el mismo parámetro: $1"
            fi
        ;;
        -?*)
            error_gen "Parámetro no reconocido: $1" >&2
        ;;
        *)
            if [ -z $archA ]; then
                archA="$1"
            elif [ -z $archB ]; then
                archB="$1"
            else
                error_gen "Parámetros incorrectos. Se enviaron más de 2 archivos."
            fi
    esac 
    shift
done

if [ -z $insensitive ]; then
    insensitive=false
fi

if [ -z $archA ]; then
    error_gen "No se envió ningún archivo por parámetro."
elif [ ! -s $archA ]; then
    error_gen "$archA no es un archivo o está vacío."
else
    nombreA=$(basename -- "$archA")
    extensionA="${nombreA##*.}"
    if [ ! $extensionA = 'txt' ]; then
        error_gen "El archivo A solo puede tener .txt como extensión."
    fi
fi

if [ -z $archB ]; then
    error_gen "No se envió el archivo B por parámetro."
elif [ ! -s $archB ]; then
    error_gen "$archB no es un archivo o está vacío."
else
    nombreB=$(basename -- "$archB")
    extensionB="${nombreB##*.}"
    if [ ! $extensionB = 'txt' ]; then
        error_gen "El archivo B solo puede tener .txt como extensión."
    fi
fi

contA=$(cat "$archA")
contB=$(cat "$archB")

if $insensitive; then
    contA=$(printf %s "$contA" | tr [:upper:] [:lower:])
    contB=$(printf %s "$contB" | tr [:upper:] [:lower:])
fi

palabras=$(echo $contB | tr ";" "\n")
contPalabrasB=0
for palabra in $palabras; do
    ((contPalabrasB++))
done
contNoEnA=$contPalabrasB

while read -r linea; do
    cont=0
    for palabra in $palabras; do
        if [ $palabra = $linea ]; then
            ((cont++))
            ((contNoEnA--))
        fi
    done
    echo "$linea: $cont"
done <<< "$contA"

echo "No existen en A: $contNoEnA"