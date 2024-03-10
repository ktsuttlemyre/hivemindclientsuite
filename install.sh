#!/bin/bash

echo "Installing. Some of the commands will need sudo access. Please grant sudo use."
#do a sudo command to get the password out of the way
sudo echo "Thank you for granting sudo privileges" || exit 1

source pi.config

sudo apt install rclone fail2ban -y
#Install
sudo nano /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/filter.d/http-get-dos.conf
sudo nano /etc/fail2ban/filter.d/http-post-dos.conf
#Use these to check if everything is all right:

sudo systemctl restart fail2ban

cat << EOF > /$HOME/.config/rclone.conf
[GoogleDrive]
type = drive
client_id = $rclone_client_id
client_secret = $rclone_client_secret
scope = drive.file
EOF


rclone config && echo "Thanks for installing" || echo "There was an error while installing"
