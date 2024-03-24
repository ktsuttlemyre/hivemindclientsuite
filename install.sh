#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME=$(basename "$0")
: > ${SCRIPT_DIR}/${SCRIPT_NAME}.prompt.history
prompt() {
  unattended_mode='no'
  message="$1"
  key="$2"
  while true; do
    if [ "$unattended_mode" = 'yes' ]; then
      yn="$3"
    elif ! [ -z "$2" ] && ! [ -z "${!2}" ]; then
      yn="${!2}"
      unattended_mode='yes'
    elif [ -z "$yn" ]; then
      read -p "$message " yn
    fi
      case $yn in
          [Yy][Ee][Ss]* )
            _prompt_history "$key" "$yn"
            return ;;
          [Nn][Oo]* )
            _prompt_history "$key" "$yn"
            return 1 ;;
          [Cc][Aa][Nn][Cc][Ee][Ll]* )
            _prompt_history "$key" "$yn"
            return 2 ;;
          [Ee][Xx][Ii][Tt]* )
            echo "user exit"
            _prompt_history "$key" "$yn"
            exit 0 ;;
          '' )
            #if theres a default value then use it
            if ! [ -z "$3" ]; then
              unattended_mode='yes'
            fi
            ;;
          * )
          echo "Please answer yes, no, cancel or exit."
          #check if we got the answer from\tan env var
          if [ "$unattended_mode" = 'yes' ]; then
            echo "Invalid response."
            echo "    $2=${!2}"
            echo "Program exiting now"
            exit 1
          fi
          ;;  
      esac
  done
}
_prompt_history() {
  echo "$1=$2"$'\n' >> ${SCRIPT_DIR}/${SCRIPT_NAME}.prompt.history
}

echo "Installing. Some of the commands will need sudo access. Please grant sudo use."
#do a sudo command to get the password out of the way
sudo echo "Thank you for granting sudo privileges" || exit 1

[ -f 'pi.config' ] && source pi.config

#Install
sudo apt update
if prompt "Upgrade the system?" 'do_upgrade';then 
  sudo apt upgrade
fi

sudo apt install unattended-upgrades fail2ban -y && sudo apt autoremove

if ! type rclone > /dev/null; then
  sudo -v ; curl https://rclone.org/install.sh | sudo bash
fi

if prompt "Replace fail2ban configs?" 'replace_fail2ban_configs'; then
  sudo cp -r ./fail2ban /etc/fail2ban
fi
sudo systemctl restart fail2ban

#save env vars
env | grep '^\(tunnel\|poll\|rclone_root\|project\|wdir\|repo\)=' > .env

if prompt "Add rclone configs?" 'replace_rclone_configs'; then
  env envsubst < ./templates/rclone.conf.tmpl > /$HOME/.config/rclone/rclone.conf
fi
 
systemd_dir='/lib/systemd/system/'
[ ! -d $systemd_dir ] && systemd_dir='/etc/systemd/system/'

env envsubst < ./templates/excludes.txt.tmpl > excludes.txt

# https://medium.com/horrible-hacks/using-systemd-as-a-better-cron-a4023eea996d
#add rclone sync commands to systemd
Description='Sync via rclone' \
Wants='rclone-sync.timer' \
ExecStart="${wdir}sync.sh sync" \
WorkingDirectory="${HOME}" \
User=$USER \
env envsubst < ./templates/general.service.tmpl > rclone-sync.service;
sudo mv rclone-sync.service ${systemd_dir}rclone-sync.service;

Description='Run Rclone sync every n minutes' \
Requires='rclone-sync.service' \
Unit='rclone-sync.service' \
Timer="${poll:-30m}" \
env envsubst < ./templates/general.timer.tmpl > rclone-sync.timer;
sudo mv rclone-sync.timer ${systemd_dir}rclone-sync.timer;

#systemctl stop
sudo systemctl daemon-reload
sudo systemctl enable rclone-sync.timer rclone-sync.service
sudo systemctl start rclone-sync.timer rclone-sync.service

#todo suggest changing default password?
#https://www.cyberciti.biz/faq/where-are-the-passwords-of-the-users-located-in-linux/
# https://linuxconfig.org/how-to-hash-passwords-on-linux
line="$(sudo grep $USER /etc/shadow)"
alg="$(echo $line | cut -f2 -d '$')"
salt="$(echo $line | cut -f3 -d '$')"
hash="$(echo $line | cut -f4 -d '$' | cut -f1 -d ':')"
test="$(openssl passwd -$alg --salt $salt HiveMind123 | cut -f4 -d '$')"
if [ "$hash" = "$test" ];  then
  echo "you should change the default password"
  if prompt "would you like to do that now?"; then
    passwd
  fi
fi

rclone config

cd $HOME
rclone mkdir GoogleDrive:${rclone_root}
sudo chmod +x ${wdir}sync.sh
if ${wdir}sync.sh init; then 
  echo "Thanks for installing"
  if ! prompt "Do you wish to remain connected to the remote?" 'remain_connected'; then
    exit 0
  fi
else
  echo "There was an error while installing";
  exit 1
fi
