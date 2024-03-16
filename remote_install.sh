#!/bin/bash
#set -ex

#set cleanup trigger
pgid="$(ps -o pgid= $$ | grep -o '[0-9]*')"
trap "trap - SIGTERM && kill -- -${pgid:-$$}" SIGINT SIGTERM EXIT


project='kqremotestatsbox'
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

echo -n "Password to log into $pi_ip with user $pi_user"
read -s password
echo
#download and unzip code
sshpass -p "$password" ssh ${pi_user}@${pi_ip} "mkdir -p ${wdir}; cd ${wdir}; curl -LkSs 'https://api.github.com/repos/${repo}tarball/' | tar xz --strip=1 -C $wdir;"
#send config
#sshpass -p "$password" scp ${pi_config} ${pi_user}@${pi_ip}:${wdir}

#open tunnel
args="$(xargs echo -n < ${pi_config}) $(env | grep '^\(wdir\|project\|repo\)=' )"

sshpass -p "$password" ssh -L 53682:localhost:53682 -C -N -l $pi_user $pi_ip &
ssh -f -L 53682:localhost:53682 -C -N -l $pi_user $pi_ip sleep 10; \
          sshpass -p "$password" ssh -t ${pi_user}@${pi_ip} "cd ${wdir}; $args bash --init-file ${wdir}install.sh"

#clean up
password=false
unset password
kill $SSH_TUNNEL_PID

