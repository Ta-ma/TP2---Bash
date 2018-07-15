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
    echo '-r y -l pueden usarse en conjunto.'
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
leg_clave=
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
            elif [ -z $leg_clave ]; then
                leg_clave="$1"
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
elif [ ! -z $flagp ] && [ -z $flagr ]; then
    error_gen "El parámetro -p solo puede utilizarse en conjunto con -r."
elif [ -z $leg_clave ] && [ ! -z $flagl ]; then
    error_gen "No se ha especificado ningún legajo por parámetro."
fi

ut_hm() {
 ((h=${1}/3600))
 ((m=(${1}%3600)/60))
 printf "%02d:%02d" $h $m
}

ut_h() {
 ((h=${1}/3600))
 printf "%02d:00" $h
}

str="${nombre##*_}"
str2="${str%%.*}"
anio=${str:0:4}
mes=${str:4:2}
declare -A legajos
ttot=

while read linea; do
  IFS=';' read -r -a array <<< "$linea"
  if [ ${#array[@]} -eq 4 ]; then
    legajo=${array[0]}
    hin=$(date -u -d "${array[2]}" +"%s")
    heg=$(date -u -d "${array[3]}" +"%s")
    tt=$((heg-hin))

    if [ ! ${legajos[$legajo]+abc} ] && [ $flagr ]; then
      arch="$legajo"_"$anio$mes.reg"
      printf "" > $arch
    fi

    legajos["$legajo"]=$((legajos["$legajo"]+tt))
    ttot=$((ttotales+tt))
    if [ $flagr ]; then
      arch="$legajo"_"$anio$mes.reg"
      fecha="${array[1]}/$mes/$anio"
      ts_ttot=$(ut_hm $ttot)

      echo "$legajo;$fecha;${array[2]};${array[3]};$ts_ttot" >> $arch
    fi
  fi
done < <(grep "" "$archivo")

if [ $flagr ]; then
  for leg in "${!legajos[@]}"
  do
    arch="$leg"_"$anio$mes.reg"
    horast=$(ut_hm "${legajos[$leg]}")
    horash=
    dif=$((${legajos[$leg]} - 662400))
    if [ $dif -le 0 ]; then
      horash='0:00'
    else
      horash=$(ut_h $dif)
    fi
    echo "-----------------------------------------" >> $arch
    echo "Total de horas teóricas: 184:00" >> $arch
    echo "Total de horas trabajadas: $horast" >> $arch
    echo "Horas Extra: $horash" >> $arch
    if [ $flagp ]; then
      echo "Legajo: $leg, horas trabajadas: $horast"
    fi
  done
fi

if [ $flagl ]; then
  if [ ! ${legajos[$leg_clave]+abc} ]; then
    error_gen "El legajo especificado por parámetro no existe."
  fi

  horast=$(ut_hm "${legajos[$leg_clave]}")
  horash=
  dif=$((${legajos[$leg_clave]} - 662400))
  if [ $dif -le 0 ]; then
    horash='0:00'
  else
    horash=$(ut_h $dif)
  fi
  echo
  echo "Legajo: $leg_clave"
  echo "-----------------------------------------"
  echo "Total de horas teóricas: 184:00"
  echo "Total de horas trabajadas: $horast"
  echo "Horas Extra: $horash"
fi
