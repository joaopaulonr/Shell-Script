#!/bin/bash
# Nota: 0,5
a=$1
b=$2
c=$3
if [[ $1 = [0-9]* ]] && [[ $2 = [0-9]* ]] && [[ $3 = [0-9]* ]];
then
    if [ $1 -gt $2 ] && [ $1 -gt $3 ];
    then
    echo $1
    elif [ $2 -gt $1 ] && [ $2 -gt $3 ];
    then
    echo $2
    else
    echo $3
    fi
else
    if [[ $1 != [0-9]* ]];
    then
    echo "Opa!! $1 não é um número!"
    elif [[ $2 != [0-9]* ]];
    then 
    echo "Opa!! $2 não é um número!"
    else
    echo "Opa!! $3 não é um número!"
    fi
fi
