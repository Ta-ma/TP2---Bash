#!/bin/bash

for (( i=1; i<=12; i++ ))
do
    for (( j=1; j<=i; j++ ))
    do
        cp "s.txt" "./hoja$i/s$j.txt"
    done
done

#cp "s.txt" "./$1/s$2.txt"