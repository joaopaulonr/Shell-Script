#!/bin/bash
sudo apt update > /dev/null
sudo apt install -y apache2 > /dev/null
echo -e "Nome: Joao Paulo Nobre Rodrigues.\nMatricula: 496228." > index.html
sudo mv index.html /var/www/html/