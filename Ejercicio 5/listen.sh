#!/bin/bash

if mkdir "/tmp/lock" &> /dev/null; then
    echo "El PID del proceso en segundo plano es $$"
else
    echo "Ya existe una instancia del script en ejecución." >&2
    exit
fi

path="$1"

remove() {
    echo 'Script en segundo plano finalizado.'
    rm -r "/tmp/lock"
    exit
}

zipear() {
    # muevo a la carpeta de entrada para operar
    cd "$PATH_ENTRADA"
    # nombre del archivo
    base=$(basename "$PATH_ENTRADA")
    fecha=$(date '+%d-%m-%Y %H:%M:%S')
    nombre="$base ($fecha).zip"
    # cuento archivos
    cont=$(ls -R -1q | awk '
    $0 && !/^[.]/ {
        print $0
    }
    ' | wc -l)
    # zipeo
    zip -r "$nombre" * > /dev/null
    # calculo el tamaño
    size=$(wc -c < "$nombre")
    tam=$(bc -l <<< "scale=6; $size/1000000")
    # muevo el archivo
    mv "$nombre" "$PATH_SALIDA"
    # imprimo en log
    echo "$fecha | Comprimidos $cont archivos en $nombre. Tamaño del .zip: $tam megabytes." >> "$path"
}

borrar() {
    # muevo a la carpeta de entrada para operar
    cd "$PATH_SALIDA"
    # obtengo fecha
    fechaf=$(date '+%d-%m-%Y %H:%M:%S')
    # cuento archivos
    contf=$(ls -R -1q | awk '
    $0 && !/^[.]/ {
        print $0
    }
    ' | wc -l)
    # obtengo tamaño de la carpeta
    sizef=$(du -b "$PATH_SALIDA" | awk '
    $1 {
        print $1
    }
    ')
    sizef=$((sizef-4096))
    tamf=$(bc -l <<< "scale=6; $sizef/1000000")
    # elimino archivos
    rm -r "$PATH_SALIDA"/*
    # imprimo en log
    echo "$fechaf | Eliminados $contf archivos. Espacio liberado: $tamf megabytes." >> "$path"
}

trap "zipear" SIGUSR1
trap "borrar" SIGUSR2
trap '' SIGINT
trap 'remove' SIGTERM
trap '' SIGHUP
trap '' SIGSTOP

while true; 
    do sleep 1
done