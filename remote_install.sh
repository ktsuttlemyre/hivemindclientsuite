#!/bin/bash

include () {
  d=/tmp/RogueCache/; mkdir -p $d; find $d -type f -mtime ${ROGUECACHE_TTL:-+1} -delete; f=${1##/*/}; ( ! [ -f $d$f ] && curl -s $1 > $d$f ) && env . $d$f
}
. include https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/argp.sh;


#set cleanup trigger
#https://stackoverflow.com/questions/360201/how-do-i-kill-background-processes-jobs-when-my-shell-script-exits
pgid="$(ps -o pgid= $$ | grep -o '[0-9]*')"
trap "trap - SIGTERM && kill -- -${pgid:-$$}" SIGINT SIGTERM EXIT


project='hivemindclientsuite'
repo="ktsuttlemyre/${project}/"
wdir="~/${project}/"

pi_user="$1"
pi_ip="$2"
pi_config="$3"

example_config () {
  echo "example pi.config file below"
  echo "____________________________"
  echo "tunnel=false"
  echo "poll=false"
  echo "rclone_root='XXXXX'"
  echo "rclone_client_id='XXXXX'"
  echo "rclone_client_secret='XXXXX'"
 echo "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
}


if [ -z "$pi_user" ]; then
  echo "Please provide a Pi username"
  exit 1
fi
if [ -z "$pi_ip" ]; then
  echo "Please provide a Pi IP address"
  example_config
  exit 1
fi
if [ -z "$pi_config" ]; then
  echo "Please provide a Pi config file"
  example_config
  exit 1
elif ! [ -f "$pi_config" ]; then
  echo "Pi config file is not a real file path"
  exit 1
fi

if ! type sshpass > /dev/null; then
  echo "installing sshpass"
  sudo apt install sshpass -y
fi

echo "Wecome to the remote installer for"
echo "      HiveMind Client Suite       "
echo "     Now logging into $pi_ip      "
echo -n "User $pi_user:"
read -s password
echo
#download and unzip code
sshpass -p "$password" ssh ${pi_user}@${pi_ip} "mkdir -p ${wdir}; cd ${wdir}; curl -LkSs 'https://api.github.com/repos/${repo}tarball/' | tar xz --strip=1 -C $wdir;"
#send config
#sshpass -p "$password" scp ${pi_config} ${pi_user}@${pi_ip}:${wdir}

#open tunnel and connect to it at the same time so the tunnel will close when our ssh session finishes
args="$(xargs echo -n < ${pi_config}) wdir=$wdir project=$project repo=$repo"
#https://unix.stackexchange.com/questions/83806/how-to-kill-ssh-session-that-was-started-with-the-f-option-run-in-background
sshpass -p "$password" ssh -f -L 53682:localhost:53682 -C -N -l $pi_user $pi_ip "sleep 10"; $SSH_TUNNEL_PID=$?; \
          sshpass -p "$password" ssh -t ${pi_user}@${pi_ip} "cd ${wdir}; $args bash --init-file ${wdir}install.sh"

#clean up
kill $SSH_TUNNEL_PID
password=false
unset password

