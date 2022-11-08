#!/bin/bash
path=$(dialog --stdout --inputbox "Digite o caminho do arquivo: " 0 0)
if [[ $? = 0 ]] && [[ -d $path ]]; then
    lista=$((ls -l $path) | (grep -v '^d') | (cut -d":" -f2) | (cut -d' ' -f2) | (sed '1d') | (tr ' ' '\n') > listaArq.txt);
    tags=()
    while read -r linha; do
        tags+=("${linha} off")
    done < listaArq.txt
    arquivo=$(dialog --stdout --no-items --checklist "Selecione os Arquivos:" 25 50 ${#tags[@]} ${tags[@]})
    if [[ $? = 0 ]]; then
        echo $arquivo > Select.txt
        selectFormat=$(cat Select.txt | tr " " '\n' > selectFormatado.txt)
        compactacao=$(dialog --radiolist "Selecione a o opção de compactação: " 10 10 10 "gzip" "" off "bzip2" "" off --stdout)
        if [[ $? = 0 ]]; then
            tags=()
            while read -r linha; do
                tags+=("${linha} on")
            done < selectFormatado.txt
            arquivo=$(dialog --stdout --no-items --checklist "Tem certeza deste(s) arquivo(s)? :" 25 50 ${#tags[@]} ${tags[@]}) 
            echo $arquivo > Select.txt
            selectFormat=$(cat Select.txt | tr " " '\n' > selectFormatado.txt)
            if [[ $compactacao == "gzip" ]]; then
                for linha in $(cat Select.txt); do
                echo "gzip -k $path/$linha">gzip.sh
                chmod +x gzip.sh
                ./gzip.sh
                check=$((ls -l $path) | (grep '.gz') | (cut -d":" -f2) | (cut -d' ' -f2) | (tr ' ' '\n') > checklist.txt)
                done
                tags=()
                for linha in $(cat checklist.txt); do
                    tags+=("$linha")
                done
                dialog --title 'Arquivos Compactados' --textbox checklist.txt 6 50
            elif [[ $compactacao == "bzip2" ]]; then
                for linha in $(cat Select.txt); do 
                    echo "bzip2 -k $path/$linha" > bzip2.sh
                    chmod +x bzip2.sh
                    ./bzip2.sh
                    check=$((ls -l $path) | (grep '.bz2') | (cut -d":" -f2) | (cut -d' ' -f2) | (tr ' ' '\n') > checklist.txt)
                done
                tags=()
                for linha in $(cat checklist.txt); do
                    tags+=("$linha")
                done
                dialog --title 'Arquivos Compactados' --textbox checklist.txt 6 50
            fi
        fi
    fi
fi
rm -f checklist.txt
rm -f Select.txt
rm -f selectFormatado.txt
rm -f listaArq.txt
rm -f gzip.sh
rm -f bzip2.sh
clear;
