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
    cd "$PATH_ENTRADA"
    # nombre del archivo
    base=$(basename "$PATH_ENTRADA")
    fecha=$(date '+%d-%m-%Y %H:%M:%S')
    nombre="$base ($fecha).zip"
    # cuento archivos
    cont=$(find . -type f | wc -l)
    # zipeo
    zip -r "$nombre" * > /dev/null
    # calculo el tamaño
    size=$(stat --printf="%s" "$nombre")
    tam=$(echo $size | awk '
    { split("B K M G", v); s = 1; while($1 > 1024){ $1 /= 1024; s++ } print int($1) v[s] }')
    # muevo el archivo
    mv "$nombre" "$PATH_SALIDA"
    # imprimo en log
    echo "$fecha | Comprimidos $cont archivos en $nombre. Tamaño del .zip: $tam." >> "$path"
}

borrar() {
    # muevo a la carpeta de entrada para operar
    cd "$PATH_SALIDA"
    # obtengo fecha
    fechaf=$(date '+%d-%m-%Y %H:%M:%S')
    # cuento archivos
    contf=$(find . -type f | wc -l)
    # obtengo tamaño de la carpeta
    tamf=$(du -h --apparent-size "$PATH_SALIDA" | cut -f1)
    # elimino archivos
    rm -r "$PATH_SALIDA"/*
    # imprimo en log
    echo "$fechaf | Eliminados $contf archivos. Espacio liberado: $tamf." >> "$path"
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