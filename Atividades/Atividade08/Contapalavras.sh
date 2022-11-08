#!/bin/bash
ARQUIVO=
echo "Informe o arquivo: "
read ARQUIVO
cat $ARQUIVO | echo -e "$((sed "/^$/d" |(tr -d '.')|(tr -d ',')|(tr ' ' '\n')) )" >> aux.txt
cat aux.txt | sed '/^$/d'| sort | uniq -c
rm -f aux.txt