#!/bin/bash


source ~/remotestatsbox/.env

direction="$1"
case $direction
  init )
    rclone bisync $HOME GoogleDrive:$rclone_root/ --resync, --resync-mode newer
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
    if [ -f ./command.txt ] && [ -s ./command.txt ]; then
      echo "> $(cat ./command.txt)" > command_output.txt
      bash ./command.txt >> command_output.txt
      echo "" > command.txt
    fi
    
    curl -s ipinfo.io > ipinfo.io
    traceroute google.com > traceroute.txt
    
    #get external ip
    declare -a cmd=('curl -s -4 icanhazip.com' \
      'curl -s ifconfig.me' \
      'curl -s api.ipify.org' \
      'curl -s bot.whatismyipaddress.com' \
      'curl -s ipinfo.io/ip' \
      'curl -s ipecho.net/plain')
    ip=''
    for i in "${cmd[@]}"; do
      ip=$($i)
      if ! [ -z "$ip" ]; then
        break
      fi
    done
    echo "$ip" > ip_public.txt

    ifconfig >  ifconfig.txt
    sudo iwlist wlan0 scan > iwlist.txt
    ip route | grep -Eo '([0-9]*\.){3}[0-9]*' | sed "2q;d" > ip_private.txt
    date > date.txt
  ;;
esac

