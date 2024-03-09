#!/bin/bash

#Install
sudo nano /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/filter.d/http-get-dos.conf
sudo nano /etc/fail2ban/filter.d/http-post-dos.conf
#Use these to check if everything is all right:

sudo systemctl restart fail2ban




cat << EOF > /$HOME/.config/rclone.conf
[GoogleDrive]
type = drive
client_id = $client_id
client_secret = $client_secret
scope = drive.file
token = 
EOF
