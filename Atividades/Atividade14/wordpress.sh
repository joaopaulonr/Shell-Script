#!/bin/bash
#Parâmetro-para-a-inserção-da-chave-de-acesso.
KEY=$1;USER=$2;PASS=$3,
echo "Criando Servidor de Banco de Dados..."
#Variáveis de uso para o script.
ISO="ami-052efd3df9dad4825"
IPMAQUINA=$(echo "$(wget -qO- http://checkip.amazonaws.com/?_x_tr_sch=http&_x_tr_sl=auto&_x_tr_tl=pt&_x_tr_hl=pt-BR&_x_tr_pto=wapp)/32")
VPCID=$(aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text)
SUBNET=$(aws ec2 describe-subnets --query "Subnets[].SubnetId[]" --output text | tr "\t" "," | tr "," "\n" | sed '2,6d')
#Criação do grupo de segurança;
aws ec2 create-security-group --group-name Script-Wordpress-Group --description "Meu grupo de seguranca" --vpc-id ${VPCID} > /dev/null
SECGRUPID=$(aws ec2 describe-security-groups --group-names  "Script-Wordpress-Group" --query "SecurityGroups[].GroupId[]" --output text)
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
    sleep 2
    STATUS=$(aws ec2 describe-instances --instance-id $InstanceId --query "Reservations[0].Instances[0].State.Name" --output text)
done
echo "Servidor de Banco de Dados Criado com sucesso!"
sleep 2
clear
echo "Criando Servidor de Aplicação..."
sleep 5
#script para a configuração da pilha LAMP. utilizei o tutorial https://pt.linux-console.net/?p=457#gsc.tab=0 para a configuração.
cat<<EOF >  aplicacao.sh
#!/bin/bash
apt update -y
apt install -y apache2
apt install -y mysql-client
apt install -y php
apt install php-mysql php-curl libapache2-mod-php php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
systemctl enable mysql-client
systemctl start mysql-client
systemctl enable apache2
systemctl start apache2
echo -e "[client]\nuser="$2"\npassword="$3 > /root/.my.cnf
echo -e "[client]\nuser="$2"\npassword="$3 > /home/ubuntu/.my.cnf
cd /home/ubuntu
wget -c -P /home/ubuntu https://wordpress.org/latest.tar.gz
echo -e "<?php\ndefine( 'DB_NAME', 'scripts' );\ndefine( 'DB_USER', '$2' );\ndefine( 'DB_PASSWORD', '$3' );\ndefine( 'DB_HOST', '$IPPRIV1' );\ndefine( 'DB_CHARSET', 'utf8' );\ndefine( 'DB_COLLATE', '' );\n\$(curl -s https://api.wordpress.org/secret-key/1.1/salt)\n\\\$table_prefix= 'wp_';\ndefine( 'WP_DEBUG', false );\nif ( ! defined( 'ABSPATH' ) ) {define( 'ABSPATH', __DIR__ . '/' );}\nrequire_once ABSPATH . 'wp-settings.php';" > wp-config.php
tar -xzf /home/ubuntu/latest.tar.gz
cp wp-config.php /home/ubuntu/wordpress/
sudo cp -fr /home/ubuntu/wordpress /var/www/html/
chown -R www-data:www-data /var/www/html/wordpress
find /var/www/html/wordpress/ -type d -exec chmod 750 {} \\;
find /var/www/html/wordpress/ -type f -exec chmod 640 {} \\;
cat <<FOE > /etc/apache2/sites-available/wordpress.conf
<Directory /var/www/html/wordpress/>
    AllowOverride All
</Directory>
FOE
a2enmod rewrite
a2ensite wordpress
systemctl restart apache2
EOF
#Criação da segunda instância.
aws ec2 run-instances --image-id ${ISO} --instance-type t2.micro --key-name ${KEY} --subnet-id ${SUBNET} --security-group-ids ${SECGRUPID} --user-data file://aplicacao.sh >> aux2.txt
InstanceId2=$(grep "InstanceId" aux2.txt | tr -d '"' | tr -d ','  | cut -d ":" -f2)
IPPUB2=$(aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress" --instance-id ${InstanceId2} --output text)
#verifica se a Instância está em execução.
while [[ $STATUS2 != "running" ]]; do
    sleep 2
    STATUS2=$(aws ec2 describe-instances --instance-id $InstanceId2 --query "Reservations[].Instances[].State.Name" --output text)
done
echo "Servidor de Aplicação Criado om Sucesso!"
#Print do IP público da segunda instância.
for ((i = 90; i >= 1; i--)) do
clear
echo "Espere alguns segundos para a configuração dos serviços." 
echo "Finalizando em ${i}s."
sleep 0.33
clear
echo "Espere alguns segundos para a configuração dos serviços.." 
echo "Finalizando em ${i}s.."
sleep 0.33
clear
echo "Espere alguns segundos para a configuração dos serviços..." 
echo "Finalizando em ${i}s..."
sleep 0.33
done
clear
#print dos ips e link de acesso ao final da configuração do wordpress.
echo "IP Privado do Banco de Dados: ${IPPRIV1}"
echo "IP Público do Servidor de Aplicação: ${IPPUB2}"
echo "Acesse http://$IPPUB2/wordpress para finalizar a configuração."
rm -f aux.txt aux2.txt mysqlconf.sh aplicacao.sh