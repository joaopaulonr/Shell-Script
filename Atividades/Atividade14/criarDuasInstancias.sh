#!/bin/bash
#Parâmetro-para-a-inserção-da-chave-de-acesso.
KEY=$1;USER=$2;PASS=$3,
echo "Criando servidor de banco de dados..."
#Variáveis de uso para o script.
ISO="ami-052efd3df9dad4825"
IPMAQUINA=$(echo "$(wget -qO- http://checkip.amazonaws.com/?_x_tr_sch=http&_x_tr_sl=auto&_x_tr_tl=pt&_x_tr_hl=pt-BR&_x_tr_pto=wapp)/32")
VPCID=$(aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text)
SUBNET=$(aws ec2 describe-subnets --query "Subnets[].SubnetId[]" --output text | tr "\t" "," | tr "," "\n" | sed '2,6d')
#Criação do grupo de segurança;
aws ec2 create-security-group --group-name Script-group --description "Meu grupo de seguranca" --vpc-id ${VPCID} > /dev/null
SECGRUPID=$(aws ec2 describe-security-groups --group-names  "Script-group" --query "SecurityGroups[].GroupId[]" --output text)
aws ec2 authorize-security-group-ingress --group-id ${SECGRUPID} --protocol tcp --port 80 --cidr 0.0.0.0/0 > /dev/null
aws ec2 authorize-security-group-ingress --group-id ${SECGRUPID} --protocol tcp --port 22 --cidr ${IPMAQUINA} > /dev/null
aws ec2 authorize-security-group-ingress --group-id ${SECGRUPID} --protocol tcp --port 3306 --source-group ${SECGRUPID} > /dev/null
#script para a configuração do servidor mysql.
cat <<EOF > mysqlconf.sh
#!/bin/bash
#Update do apt.
apt update -y
#instalação do mysql.
apt-get -y install mysql-server
#Configuração para escutar todos os ips.
sed -i 31,32d /etc/mysql/mysql.conf.d/mysqld.cnf
echo -e "bind-address		= 0.0.0.0\nmysqlx-bind-address	= 0.0.0.0" >> /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql.service
#Criação do banco de dados e usuario.
echo -e "sudo mysql<<EOF\nCREATE DATABASE scripts;\nCREATE USER '"$2"'@'%' IDENTIFIED BY '"$3"';\nGRANT ALL PRIVILEGES ON scripts.* TO '"$2"'@'%';\nUSE scripts;\nEOF\nrm /home/ubuntu/mysqlconf.sh" > /home/ubuntu/mysqlconf.sh
chmod +x /home/ubuntu/mysqlconf.sh
cd /home/ubuntu
./mysqlconf.sh
EOF
#Criação da primeira instância.
aws ec2 run-instances --image-id ${ISO} --instance-type t2.micro --key-name ${KEY} --subnet-id ${SUBNET} --security-group-ids ${SECGRUPID} --user-data file://mysqlconf.sh >> aux.txt
InstanceId=$(grep "InstanceId" aux.txt | tr -d '"' | tr -d ','  | cut -d ":" -f2)
IPPUB1=$(aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress" --instance-id ${InstanceId} --output text)
IPPRIV1=$(aws ec2 describe-instances --query "Reservations[].Instances[].PrivateIpAddress" --instance-id ${InstanceId} --output text)
#verifica se a Instância esta em execução.
while [[ $STATUS != "running" ]]; do
    sleep 1
    STATUS=$(aws ec2 describe-instances --instance-id $InstanceId --query "Reservations[0].Instances[0].State.Name" --output text)
done
#Print do IP privado.
echo "IP privado ${IPPRIV1}"
###################################
echo "Criando servidor de Aplicação..."
#script para a criação do user data e do arquivo de manutenção para o mysql client.
cat<<EOF >  mysqlcliente.sh
#!/bin/bash
apt update -y
apt install -y mysql-client 
systemctl enable mysql-client
systemctl start mysql-client
echo -e "[client]\nuser="$2"\npassword="$3 > /root/.my.cnf
echo -e "[client]\nuser="$2"\npassword="$3 > /home/ubuntu/.my.cnf
echo -e "sudo mysql -u "$2" scripts -h "${IPPRIV1}"<<EOF\nUSE scripts;\nCREATE TABLE Teste (atividade INT);\nINSERT INTO Teste(atividade) VALUES(1);\nEOF\nrm /home/ubuntu/mysqlcliente.sh" > /home/ubuntu/mysqlcliente.sh
chmod +x /home/ubuntu/mysqlcliente.sh
cd /home/ubuntu
./mysqlcliente.sh
EOF
#Criação da segunda instância.
aws ec2 run-instances --image-id ${ISO} --instance-type t2.micro --key-name ${KEY} --subnet-id ${SUBNET} --security-group-ids ${SECGRUPID} --user-data file://mysqlcliente.sh >> aux2.txt
InstanceId2=$(grep "InstanceId" aux2.txt | tr -d '"' | tr -d ','  | cut -d ":" -f2)
IPPUB2=$(aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress" --instance-id ${InstanceId2} --output text)
#verifica se a Instância está em execução.
while [[ $STATUS2 != "running" ]]; do
    sleep 1
    STATUS2=$(aws ec2 describe-instances --instance-id $InstanceId2 --query "Reservations[].Instances[].State.Name" --output text)
done
#Print do IP público da segunda instância.
echo "IP publico do servidor de aplicação : ${IPPUB2}"
rm -f aux.txt aux2.txt