#!/bin/bash

echoinfo() {
    printf "%s * STATUS%s: %s\n" "${GC}" "${EC}" "$@";
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

USERID=root
REQUESTEDTAG=none

while getopts ":t:u:" opt; do
  case ${opt} in
    t )
      REQUESTEDTAG=${OPTARG}
      ;;
    u )
      USERID=${OPTARG}
      ;;
    \? ) 
      echo "Usage: install.sh -u username"
      ;;
  esac
done
shift $((OPTIND -1))

if [ "$USERID" == "root" ];
then
  echo "No username supplied, or username root not allowed."
  exit 1
fi

echoinfo " Installing git."
apt-get install -y git

echoinfo " Installing ansible."
apt-get install software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install -y ansible

#echoinfo " Getting DIWA ansible playbooks."
#git clone https://github.com/kamwoods/diwa-distro-ansible.git /srv/ansible
#cd /srv/ansible
#git fetch --tags

#if [ "$REQUESTEDTAG" == "none" ];
#then
#  echoinfo " No DIWA release requested. Getting latest release."
#  REMOTETAG=$(git describe --tags `git rev-list --tags --max-count=1`)
#  git checkout $REMOTETAG
#else
#  echoinfo " DIWA release $REQUESTEDTAG requested. Getting latest release."
#  git checkout $REQUESTEDTAG
#fi

cd ~/
echoinfo " Installing DIWA."
ansible-pull -U https://github.com/kamwoods/diwa-distro-ansible.git

echoinfo " Cleaning up."
rm -rf /srv/ansible
