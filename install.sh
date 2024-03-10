#!/bin/bash

echo "Installing Rogue OS. Some of the commands will need sudo access. Please grant sudo use."
#do a sudo command to get the password out of the way
sudo echo "Thank you for granting sudo privileges" || exit 1

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
client_id = $client_id
client_secret = $client_secret
scope = drive.file
token = 
EOF


rclone config && echo "Thanks for installing" || echo "There was an error while inistalling"
