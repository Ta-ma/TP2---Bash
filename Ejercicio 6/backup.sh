: '
  if [ -f "lista.txt" ];then
    rm "lista.txt"
  fi
  aux=0
  if [ $# -eq 2 ] ;then
    if [ $2 = '-f' ] ;then
      IFS='
      '
    fi
  fi
  cont=
  for arch in $(find $dir -type d) 
  do	
    size=0
    cont=0
    for a in $(find $arch -maxdepth 1)
      do
      (( cont++ ))
      if [ -d $a -a $cont -ne 1 ] ;then
        aux=1
        #echo "$aux $a"
      else
        cont=`ls $arch | wc -l`
        size=`du -sb -h $arch | cut -f1`
              sizeb=`du -sb $arch | cut -f1`
        #echo "$aux $a"
      fi	
    done
    if [ $aux -eq 0 -a $cont -ge 1 ] ;then
      echo "$(dirname $a) $size ($sizeb bytes) $cont arch"
    fi
    aux=0
    cont=0
  done | sort -t " " -k 3 -r | head -10
'