#!/bin/bash

: '  
    Nombre del script: ej4.sh
    Trabajo Practico 2 - Ejercicio 4
    Grupo: 6
    Gómez Markowicz, Federico - 38858109
    Kuczerawy, Damián - 37807869
    Mediotte, Facundo - 39436162
    Siculin, Luciano - 39213320
    Tamashiro, Santiago - 39749147
'

mostrar_ayuda() {
    echo './ej4.sh <archivo> [opciones]'
    echo 'Donde:'
    echo '<archivo> -> es el archivo que contiene los horarios de los trabajadores.'
    echo '[opciones] pueden ser:'
    echo '-l: Mostrará las horas totales sin generar archivos.'
    echo '-r: Se guardarán las horas totales en un archivo por cada trabajador.'
    echo '-p: Solo puede utilizarse en conjunto con -r. Muestra por pantalla las horas totales trabajadas de cada trabajador.'
    echo '-r y -l no pueden usarse en conjunto.'
    echo 'Ejemplo: ./ej4.sh horario_201805.log -r -p'
    echo '-------------------------------------------------------------------'
    echo 'Procesa la planilla de horas trabajadas e indicará información según la opción enviada.'
    echo 'Este script requiere que se envie al menos una de las opciones -r o -l.'
    exit
}

error_gen() {
    echo $1 >&2
    echo "Utilice la opción -h para ver como se utiliza este comando." >&2 
    exit
}

flagp=
flagr=
flagl=
archivo=
while [ $# -ne 0 ]; do
    case $1 in
        -h|-\?|-help)
            mostrar_ayuda
        ;;
        -r)
            if [ -z $flagr ]; then
                flagr=1
            else
                error_gen "Se enviaron varias veces el mismo parámetro: $1"
            fi
        ;;
        -p)
            if [ -z $flagp ]; then
                flagp=1
            else
                error_gen "Se enviaron varias veces el mismo parámetro: $1"
            fi
        ;;
        -l)
            if [ -z $flagl ]; then
                flagl=1
            else
                error_gen "Se enviaron varias veces el mismo parámetro: $1"
            fi
        ;;
        -?*)
            error_gen "Parámetro no reconocido: $1" >&2
        ;;
        *)
            if [ -z $archivo ]; then
                archivo="$1"
            else
                error_gen "Parámetros incorrectos."
            fi
    esac 
    shift
done

# validar archivo
nombre=

if [ -z $archivo ]; then
    error_gen "No se envió ningún archivo como parámetro."
elif [ ! -s $archivo ]; then
    error_gen "$archivo no es un archivo o está vacío."
else
    nombre=$(basename -- "$archivo")
    extension="${nombre##*.}"
    if [ ! $extension = 'log' ]; then
        error_gen "El archivo solo puede tener .log como extensión."
    fi
fi

# validar opciones
if [ -z $flagr ] && [ -z $flagl ]; then
    error_gen "Debe utilizar alguna de las opciones -r o -l para que el script haga algo."
elif [ ! -z $flagr ] && [ ! -z $flagl ]; then
    error_gen "Sólo se puede utilizar una de las opciones -r o -l."
elif [ ! -z $flagp ] && [ -z $flagr ]; then
    error_gen "El parámetro -p solo puede utilizarse en conjunto con -r."
fi

str="${nombre##*_}"
str2="${str%%.*}"
anio=${str:0:4}
mes=${str:4:2}

contenido=$(cat $archivo)
text=$(echo $contenido | awk -v anio=$anio -v mes=$mes -v r=$flagr -v p=$flagp -v l=$flagl '
        BEGIN {
            FS = ";"
            RS = " "
        }
        {
            legajo = $1
            archivo = sprintf("%s_%.4d%.2d.reg", $1, anio, mes)

            split($3,a,":")
            split($4,b,":")
            t1 = a[1] * 3600 + a[2] * 60 + a[3]
            t2 = b[1] * 3600 + b[2] * 60 + b[3]
            resta = t2 - t1
            horas = int(resta / 3600)
            sobra = (resta % 3600)
            minutos = int(sobra / 60)

            if(legajo in vec) {
                vec[legajo] += resta
            } else {
                if (r) printf "" > archivo
                vec[legajo] = resta
            }

            if (r) {
                printf("%s;%.2d/%.2d/%.2d;", $1, $2, mes, anio) >> archivo
                printf("%.2d:%.2d:%.2d;", a[1], a[2], a[3]) >> archivo
                printf("%.2d:%.2d:%.2d;", b[1], b[2], b[3]) >> archivo
                printf("%.2d:%.2d\n", horas, minutos) >> archivo
                close(archivo)
            }
        }
        END {
            if (l) {
                for(legajo in vec) {
                    horasf = int(vec[legajo] / 3600)
                    sobraf = (vec[legajo] % 3600)
                    minutosf = int(sobraf / 60)
                    horasx = horasf - 184

                    print sprintf("Legajo: %.6d", legajo)
                    print "......................................................................"
                    print sprintf("Total de horas teóricas: 184:00")
                    print sprintf("Total de horas trabajadas: %.2d:%.2d", horasf, minutosf)
                    print sprintf("Horas extra: %.2d:00\n", horasx > 0 ? horasx : 0)
                    print ""
                }
            }
            if (r) {
                for(legajo in vec) {
                    archivof = sprintf("%.6d_%.4d%.2d.reg", legajo, anio, mes)
                    horasf = int(vec[legajo] / 3600)
                    sobraf = (vec[legajo] % 3600)
                    minutosf = int(sobraf / 60)
                    horasx = horasf - 184

                    printf "......................................................................\n" >> archivof
                    printf("Total de horas teóricas: 184:00\n") >> archivof
                    printf("Total de horas trabajadas: %.2d:%.2d\n", horasf, minutosf) >> archivof
                    printf("Horas extra: %.2d:00", horasx > 0 ? horasx : 0) >> archivof
                    close(archivof)

                    if (p)
                        print sprintf("Legajo: %.6d - Horas trabajadas: %.2d:%.2d", legajo, horasf, minutosf)
                }
            }
        }
        ')

echo "$text"