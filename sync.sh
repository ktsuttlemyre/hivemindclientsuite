#!/bin/bash

#force home
cd $HOME

source ~/hivemindclientsuite/.env

SEP="$(printf '%0.s-' {1..10})"
DATE="$(TZ=EST date)"
HR="$SEP $DATE $SEP"

to_log () {
  file="$1"
  echo "$HR" >> $file
  cat - >> $file
  trunk $file
}

trunk () {
  file="$1"
  size="${2-1000000}"
  echo "$(tail -c $size $file)" > $file
}

direction="$1"
case $direction
  init )
    echo "$HR" >> rclone.log
    rclone bisync $HOME GoogleDrive:$rclone_root/ --resync --exclude ${project} --resync-mode newer --create-empty-src-dirs --slow-hash-sync-only --resilient -Mv --drive-skip-gdocs --fix-case >> rclone.log
  ;;
  sync )
    rclone --resilient --recover --max-lock 2m --conflict-resolve newer
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
    file=./command.txt
    if [ -f $file ] && [ -s $file ]; then
      echo "> $(cat $file)" | to_log ./command.output.txt
      bash $file | to_log ./command.output.txt
      echo "" > $file
    fi

    curl -s ipinfo.io | to_log ipinfo.io
    traceroute google.com | to_log traceroute.txt
    
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
    echo "$ip" | to_log ip_public.txt

    ifconfig | to_log ifconfig.txt
    sudo iwlist wlan0 scan | to_log iwlist.txt
    ip route | grep -Eo '([0-9]*\.){3}[0-9]*' | sed "2q;d" | to_log ip_private.txt
    echo "$DATE" | to_log sync_ran.txt
  ;;
esac

