#!/bin/bash

host_name="crescentblue"

direction="$1"
case $direction
  init )
    rclone copy ./config.json GoogleDrive:$host_name/
    rclone copy ./nfc-config.json GoogleDrive:$host_name/
    rclone copy ./config.json GoogleDrive:$host_name/
  ;;
  upload )
  
  ;;
  download )

  ;;
  status_up ) 
    ip addr > ip.txt
    rclone copy ./ip.txt GoogleDrive:$host_name/
    date > date.txt
    rclone copy ./ip.txt GoogleDrive:$host_name/
  ;;
esac


## declare an array variable
declare -a cmd=('curl -4 icanhazip.com' \
  'curl ifconfig.me' \ 
  'curl api.ipify.org' \ 
  'curl bot.whatismyipaddress.com' \ 
  'curl ipinfo.io/ip' \ 
  'curl ipecho.net/plain')


## now loop through the above array
for i in "${cmd[@]}"; then
  ip=$(i)
  if [ -z "$ip" ]; then
    continue
  fi
end
