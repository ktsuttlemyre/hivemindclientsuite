#!/bin/bash


source ~/remotestatsbox/.env

direction="$1"
case $direction
  init )
    rclone copy ./config.json GoogleDrive:$rclone_root/
    rclone copy ./nfc-config.json GoogleDrive:$rclone_root/
    rclone copy ./config.json GoogleDrive:$rclone_root/
    cat << EOF > ./rogue_tunnel.env
tunnel=false
ssh=false
poll=false
EOF
    rclone copy ./rogue_tunnel.env GoogleDrive:$rclone_root/
  ;;
  upload )
    rclone sync ~/ GoogleDrive:$rclone_root --exclude node_modules
  ;;
  download )
  if rclone sync GoogleDrive:$rclone_root ~/ --exclude node_modules; then #if 0 successful and files changed, 9 is successfull no file change
    sudo systemctl restart hivemind-client
    sudo systemctl restart hivemind-nfc-reader
    sudo cp ~/wpa_supplicant /boot/
  fi

  ;;
  status_up ) 
    ip addr > ip.txt
    rclone copy ./ip.txt GoogleDrive:$rclone_root/
    date > date.txt
    rclone copy ./ip.txt GoogleDrive:$rclone_root/
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
