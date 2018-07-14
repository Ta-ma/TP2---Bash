#!/bin/bash

string1="18:29:10"
string2="04:56:50"
StartDate=$(date -u -d "$string1" +"%s")
FinalDate=$(date -u -d "$string2" +"%s")
date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S"