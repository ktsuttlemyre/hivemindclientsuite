#!/bin/bash

project=wdir='kqremotestatsbox'
repo="ktsuttlemyre/${project}/"
wdir="/tmp/${project}"

pi_user="$1"
pi_ip="$2"
pi_config="$3"

if [ -z "$pi_user" ]; then
  echo "Please provide a Pi username"
  exit 1
fi
if [ -z "$pi_ip" ]; then
  echo "Please provide a Pi IP address"
  exit 1
fi
if [ -z "$pi_config" ]; then
  echo "Please provide a Pi config file"
  exit 1
else ! [ -f "$pi_config" ]; then
  echo "Pi config file is not a real file path"
  exit 1
fi

echo -n "Password to log into $pi_ip with user $pi_user"
read -s password
echo
#send config
sshpass -p "$password" scp ${pi_config} ${pi_user}@${pi_ip}:${wdir}
#open tunnel
sshpass -p "$password" ssh -L 53682:localhost:53682 -C -N -l $pi_user $pi_ip &
SSH_TUNNEL_PID=$!
#open interative session
sshpass -p "$password" ssh -t ${pi_user}@${pi_ip} "cd /tmp; curl -LkSs 'https://api.github.com/repos/${repo}tarball/' | tar xz --strip=1 -C $wdir
; cd ${wdir}; bash --init-file ${wdir}/install.sh"
password=false
unset password

kill $SSH_TUNNEL_PID

