#!/bin/bash
# Nota: 1,5
echo "A execução dura 30 segundos! aguarde!"
filename=$1
qtdl=$(cat $1 | wc -l)
cont=1
while [[ $cont -le $qtdl ]]; do
    ip_ping=$(cat -n $1 | grep -n ^ | grep ^$cont | cut -d ":" -f2 | cut -c 8-22)
    latencia=$(ping -c 10 $ip_ping | sed -E '1,14d' | cut -d "/" -f5)
    echo "$ip_ping.${latencia}ms" >> latencia_ip.txt
    let cont=cont+1;
done
cat latencia_ip.txt
rm -r latencia_ip.txt
