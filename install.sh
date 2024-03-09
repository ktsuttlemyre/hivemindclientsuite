#!/bin/bash

#Install

cat << EOF > /$HOME/.config/rclone.conf
[GoogleDrive]
type = drive
client_id = $client_id
client_secret = $client_secret
scope = drive.file
token = 
EOF
