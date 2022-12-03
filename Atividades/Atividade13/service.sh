#!/bin/bash
sudo apt update > /dev/null
sudo timedatectl set-timezone America/Fortaleza
sudo apt install -y apache2 > /dev/null
cat <<EOF > dados.sh
#!/bin/bash
while true
do
echo "Informacoes coletadas em: [\$(date '+%d/%m/%Y %T')]." >> index.html
echo "<br>" >> index.html
echo "Tempo ativo: \$(uptime -p | cut -d " " -f2) minutos." >> index.html
echo "<br>" >> index.html
echo "Carga media do sistema: \$(uptime | cut -d" " -f12 | tr ',' ' ')" >> index.html
echo "<br>" >> index.html
echo "Memoria livre: \$(free -m | sed 1d | sed 2d | tr -s '[:space:]' ',' | cut -d ',' -f4) MB." >> index.html
echo "<br>" >> index.html
echo "Memoria Usada: \$(free -m | sed 1d | sed 2d | tr -s '[:space:]' ',' | cut -d ',' -f3) MB." >> index.html
echo "<br>" >> index.html
echo "Bytes recebidos: \$(cat /proc/net/dev | sed 1,3d | tr -s '[:space:]' ',' | cut -d ',' -f3)." >> index.html
echo "<br>" >> index.html
echo "Bytes transmitidos: \$(cat /proc/net/dev | sed 1,3d | tr -s '[:space:]' ',' | cut -d ',' -f11)." >> index.html
mv index.html /var/www/html/
sleep 5
done
EOF

mv dados.sh /home/ubuntu/
chmod +x /home/ubuntu/dados.sh

cat<<EOF2 > dados.service
[Unit]
Description=WebData - Serviço Web de informações da instância.
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/home/ubuntu/dados.sh
[Install]
WantedBy=multi-user.target
EOF2

mv dados.service /etc/systemd/system
systemctl enable dados.service
systemctl start dados.service
