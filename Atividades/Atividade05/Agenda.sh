#!/bin/bash
# Por que colocou o caminho completo do arquivo? 
# Nota: 1,0
a=$1
b=$2
c=$3
delete=$2
if [[ $1 = "adicionar" ]];
then
    if [[ -f /atividades/atividade05/agenda.db ]];
    then
    echo "${b}:${c}" >> /atividades/atividade05/agenda.db
    echo "Usuario ${nome} adicionado!"
    else
    touch agenda.db
    echo "Arquivo criado!"
    echo "${b}:${c}" >> /atividades/atividade05/agenda.db
    echo "Usuario ${b} adicionado!"
    fi 
elif [[ $1 = "remover" ]];
then
    if [[ $(cat agenda.db | grep -i "$delete") ]];
    then
    nomeDelete=$(cat agenda.db | grep -i "$delete" | cut -d':' -f 1)
    sed -i -r "/${nomeDelete}/d" /atividades/atividade05/agenda.db
    echo "Usuário ${nomeDelete} foi Removido!"
    else
    echo "Usuário não encontrado!"
    fi
elif [[ $1 = "listar" ]];
then
    if [[ $(cat agenda.db | wc -l) -gt 0 ]];
    then
    cat /atividades/atividade05/agenda.db
    else
    echo "Arquivo vazio!"
    fi
else
echo "Opção Inválida!"
fi
