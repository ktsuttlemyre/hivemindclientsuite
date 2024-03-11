#!/bin/bash

echo "Installing. Some of the commands will need sudo access. Please grant sudo use."
#do a sudo command to get the password out of the way
sudo echo "Thank you for granting sudo privileges" || exit 1

source pi.config

sudo apt install rclone fail2ban -y
#Install
cp ./fail2ban /etc/fail2ban
sudo systemctl restart fail2ban

cat << EOF > /$HOME/.config/rclone.conf
[GoogleDrive]
type = drive
client_id = $rclone_client_id
client_secret = $rclone_client_secret
scope = drive.file
EOF

#todo suggest changing default password?
#https://www.cyberciti.biz/faq/where-are-the-passwords-of-the-users-located-in-linux/
# https://linuxconfig.org/how-to-hash-passwords-on-linux
#line="$(sudo grep $USER /etc/shadow)"
#pswd="$(openssl passwd -6 --salt 'salt' 'password')"
#if sudo grep "$pswd" /etc/shadow; then
#  echo "you should change your default password"
#fi

(rclone config && echo "Thanks for installing") || (echo "There was an error while installing; exit 1")

