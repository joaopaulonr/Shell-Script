#!/bin/bash
#Parâmetro-para-a-inserção-da-chave-de-acesso.
KEY=$1 
echo "Criando o servidor..."
#Variáveis-com-comandos-utilizados-no-script.
ISO="ami-052efd3df9dad4825"
VPCID=$(aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text)
#Comando-para-escolher-a-subrede-padrão.
SUBNET=$(aws ec2 describe-subnets --query "Subnets[].SubnetId[]" --output text | tr "\t" "," | tr "," "\n" | sed '2,6d')
#Criação-do-grupo-de-segurança.
aws ec2 create-security-group --group-name Script-group --description "Meu grupo de seguranca" --vpc-id ${VPCID} > /dev/null
#Pegando-o-ID-do-grudo-de-segurança.
SECGRUPID=$(aws ec2 describe-security-groups --group-names  "Script-group" --query "SecurityGroups[].GroupId[]" --output text)
#Criação-das-regras-do-grupo.
aws ec2 authorize-security-group-ingress --group-id ${SECGRUPID} --protocol tcp --port 22 --cidr 0.0.0.0/0 > /dev/null
aws ec2 authorize-security-group-ingress --group-id ${SECGRUPID} --protocol tcp --port 80 --cidr 0.0.0.0/0 > /dev/null
#Criação-da-instância.
aws ec2 run-instances --image-id ${ISO} --instance-type t2.micro --key-name ${KEY} --subnet-id ${SUBNET} --security-group-ids ${SECGRUPID} --user-data file://apache.sh >> aux.txt
#Pegando-o-ID-da-instância-em-tempo-de-execução.
InstanceId=$(grep "InstanceId" aux.txt | tr -d '"' | tr -d ','  | cut -d ":" -f2)
#Pegando-IP-público-a-partir-da-variável-InstanceId.
IPPUB=$(aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress" --instance-id ${InstanceId} --output text)
#Contador-de-segundos-para-a-configuração-do-servidor-WEB.
for ((i = 69; i >= 1; i--)) do
clear
echo "Espere alguns segundos para a inicialização do servidor." 
echo "Finalizando em ${i}s."
sleep 0.5
clear
echo "Espere alguns segundos para a inicialização do servidor.." 
echo "Finalizando em ${i}s.."
sleep 0.5
clear
echo "Espere alguns segundos para a inicialização do servidor..." 
echo "Finalizando em ${i}s..."
done
clear
#Echo-do-link-de-acesso.
echo "Acesse: http://${IPPUB}/"