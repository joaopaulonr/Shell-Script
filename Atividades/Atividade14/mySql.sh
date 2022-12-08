#!/bin/bash
#Update do apt.
apt-get update
#instalação do postgresql
apt-get -y install mysql-server
#Configuração para escutar todos os ips.
sed -i 31,32d /etc/mysql/mysql.conf.d/mysqld.cnf
echo -e "bind-address		= 0.0.0.0\nmysqlx-bind-address	= 0.0.0.0" >> /etc/mysql/mysql.conf.d/mysqld.cnf
#Criação do banco de dados e usuario.
mysql<<EOF
CREATE DATABASE scripts;
CREATE USER 'jp'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON scripts.* TO 'jp'@'%';
USE scripts;
CREATE TABLE teste(teste INT);
INSERT INTO teste(teste) VALUES(1);
EOF
