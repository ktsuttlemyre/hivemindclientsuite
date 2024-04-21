#!/bin/bash

#force home
cd $HOME

source $HOME/.env

SEP="$(printf '%0.s-' {1..10})"
DATE="$(TZ=EST date '+%Y-%m-%d %H:%M:%S %a')"
HR="$DATE: |+"
log_dir=$HOME/logs/
mkdir $log_dir

# https://askubuntu.com/questions/799743/how-to-insert-tabs-before-output-lines-from-a-executed-command
to_log () {
  file="${log_dir}$1"
  echo "$HR" >> $file
  exec 3>&1
  exec 1> >(paste /dev/null -)
  cat - >> $file
  exec 1>&3 3>&-
  trunk $file 
}

trunk () {
  file="$1"
  size="${2-1000000}"
  echo "$(tail -c $size $file)" > $file
}

sync () {
  direction="$1"
  case $direction in
    init )
      rclone mkdir GoogleDrive:${rclone_root}
      rclone bisync $HOME GoogleDrive:${rclone_root}/ --exclude-from "$HOME/$project/excludes.txt" --resync --resync-mode newer --create-empty-src-dirs --slow-hash-sync-only --resilient -Mv --drive-skip-gdocs --fix-case | to_log rclone.log
    ;;
    sync )
      sync status
      rclone bisync $HOME GoogleDrive:${rclone_root}/ --exclude-from "$HOME/$project/excludes.txt"--resilient --recover --max-lock 2m --conflict-resolve newer | to_log rclone.log.yml
    ;;
    upload )
      rclone sync ~/ GoogleDrive:$rclone_root --exclude node_modules | to_log rclone.log.yml
    ;;
    download )
    if rclone sync GoogleDrive:$rclone_root ~/ --exclude node_modules; then #if 0 successful and files changed, 9 is successfull no file change
      $HOME/hivemindclientsuite/sync.sh restart
    fi
    ;;
    restart )
      sudo systemctl restart hivemind-client
      sudo systemctl restart hivemind-nfc-reader
      sudo cp ~/wpa_supplicant /boot/
    ;;
    status )
      #log memory
      free -h | to_log memory_load.log.yml

      #sample cpu load
      (vmstat 60 2 | to_log cpu_load.log.yml &)

      #log gpu memory
      sudo /opt/vc/bin/vcdbg reloc stats | grep '^total\|free memory' | to_log gpu_memory.log.yml

      #run external command
      file=$HOME/command.txt
      if [ -f $file ] && [ -s $file ]; then
        cat <(echo -e "> $(cat $file)\n") <(bash $file) | to_log command.output.log.yml
        echo "" > $file
      fi
      
      #log network
      curl -s ipinfo.io | to_log ipinfo.io
      traceroute google.com | to_log traceroute.log.yml
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
      echo "$ip" | to_log ip_public.log.yml
      ifconfig | to_log ifconfig.log.yml
      sudo iwlist wlan0 scan | to_log iwlist.log.yml
      ip route | grep -Eo '([0-9]*\.){3}[0-9]*' | sed "2q;d" | to_log ip_private.log.yml
      
      #log heat
      sensors | to_log sensors.log.yml

      #log ssh connections
      sudo lsof -i -n | egrep '\<ssh\>' | to_log ssh_connections.log.yml

      #log date
      echo "$DATE" | to_log sync_ran.log.yml
    ;;
    * )
      echo "unknkown direction $direction"
    ;;
  esac
}
sync "$1"
