#!/bin/bash
s=$1
t=$2
cd $2
dataalter=$(date -r $2 '+%d/%m/%Y %T')
while true; do
    contarqa=$(ls | wc -l)
    sleep $s
    contarqad=$(ls | wc -l)
        if [ $contarqad -gt $contarqa ]; 
        then
            echo "[ $dataalter ] Alteração! $contarqa->$contarqad. Adicionado: $arquivoch " >>  ~/atividades/atividade07/dirSensors.log
        elif [ $contarqad -lt $contarqa ];
        then
            echo "[ $dataalter ] Alteração! $contarqa->$contarqad. removido:  $arquivoch " >>  ~/atividades/atividade07/dirSensors.log
        fi
done
