#!/bin/bash

: '  
    Nombre del script: ej5.sh
    Trabajo Practico 2 - Ejercicio 5
    Grupo: 6
    Gómez Markowicz, Federico - 38858109
    Kuczerawy, Damián - 37807869
    Mediotte, Facundo - 39436162
    Siculin, Luciano - 39213320
    Tamashiro, Santiago - 39749147
'

mostrar_ayuda() {
    echo './ej5.sh <archivo>'
    echo 'Donde:'
    echo '<archivo> -> es el archivo de log donde se registrarán los eventos.'
    echo 'Ejemplo: ./ej5.sh log.txt'
    echo '-------------------------------------------------------------------'
    echo 'Invoca un script que se ejecuta en segundo plano.'
    echo 'Este script reacciona ante las señales SIGUSR1 (zipeando los contenidos de PATH_ENTRADA'
    echo 'en el directorio PATH_SALIDA) y SIGUSR2 (borrando los contenidos del directorio PATH_SALIDA).'
    echo 'El script listen.sh debe mantenerse en la misma carpeta donde se está ejecutando actualmente,'
    echo 'y solo debe ser terminado a través de la señal SIGTERM. El resto de las señales son ignoradas.'
    exit
}

error_gen() {
    echo $1 >&2
    echo "Utilice la opción -h para ver como se utiliza este comando." >&2 
    exit
}

dir=
while [ $# -ne 0 ]; do
    case $1 in
        -h|-\?|-help)
            mostrar_ayuda
        ;;
        -?*)
            error_gen "Este script no acepta ningún parámetro opcional!" >&2
        ;;
        *)
            if [ -z $dir ]; then
                dir="$1"
            else
                error_gen "Parámetros incorrectos."
            fi
    esac 
    shift
done

if [ -z $dir ]; then
  error_gen "No se envió ninguna dirección donde generar el archivo log."
fi

if [ ! -d "$PATH_ENTRADA" ]; then
  error_gen "La variable de entorno PATH_ENTRADA no ha sido asignada o no apunta a un directorio válido."
fi

if [ ! -d "$PATH_SALIDA" ]; then
  error_gen "La variable de entorno PATH_SALIDA no ha sido asignada o no apunta a un directorio válido."
fi

touch "$dir"
path=$(readlink -f "$dir")

if [ -f "./listen.sh" ]; then
    chmod 777 ./listen.sh
    ./listen.sh "$path" &
else
    error_gen "No se encontró el script lanzador."
fi

