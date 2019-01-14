#!/bin/bash
# Author: Dean Woods
# Date: 1/14/19
# Description: Simple install script to use the cb-defense-syslog-tls forwarder on non-RHEL based systems.
#              Currently tested on Debian 9 (stretch).

echo 'Checking for admin rights...'
if [ $(id -u) -ne 0 ]; then
  echo 'Error: Script is not being run with admin rights.'
  exit 1
fi

echo 'Checking for required packages...'
REQUIRED_COMMANDS=(git python2.7 pip)
REQUIRED_PACKAGES=(git python2.7 python-pip)
for i in "${REQUIRED_COMMANDS[@]}"
do
    if ! [ -x "$(command -v $i)" ]; then
      echo "Error: $i is not installed." >&2
      echo 'Please ensure all required packages are installed.'
      echo 'Do you want to install required packages now? [Y/n]'
      read install_packages
        if [ "$install_packages" = "Y" ] || [ "$install_packages" = "y" ]; then
          echo 'Installing required packages...'
          apt-get update && apt-get install -y ${REQUIRED_PACKAGES[*]}
          break
        else
          echo "Required packages: ${REQUIRED_PACKAGES[*]}"
          exit 1
        fi
    
    fi
done

echo 'Checking for python virtual environment...'
virtualenv_exists=false
if ! [ -x "$(command -v virtualenv)" ]; then
    echo 'virtualenv is not installed.'
    echo 'Using a python virtual environment is recommended to ensure there are no conflicting dependencies.'
    echo 'Do you want to install virtualenv now? [Y/n]'
    read install_optional
    if [ "$install_optional" = "Y" ] || [ "$install_optional" = "y" ]; then
        echo 'Installing virtualenv...'
        apt-get update && apt-get install -y virtualenv
        virtualenv_exists=true
    fi
else
  virtualenv_exists=true
fi


git clone https://github.com/carbonblack/cb-defense-syslog-tls
cd cb-defense-syslog-tls

if [ virtualenv_exists ]; then
    virtualenv venv && source venv/bin/activate --distribute
    python_path="#!$(pwd)/venv/bin/python"
else
    python_path="#!/usr/bin/env python2"
fi

echo 'Installing python dependencies...'
pip install -r requirements.txt

echo 'Setting up directories...'
mkdir -p /etc/cb/integrations/cb-defense-syslog
cp ./root/etc/cb/integrations/cb-defense-syslog/cb-defense-syslog.conf.example /etc/cb/integrations/cb-defense-syslog/cb-defense-syslog.conf
cp ./root/etc/cron.d/cb-defense-syslog /etc/cron.d/cb-defense-syslog
mkdir -p /var/log/cb/integrations/cb-defense-syslog
mkdir -p /usr/share/cb/integrations/cb-defense-syslog
echo "$python_path" | cat - cb_defense_syslog.py > /usr/share/cb/integrations/cb-defense-syslog/cb-defense-syslog
mkdir -p /usr/share/cb/integrations/cb-defense-syslog/store
chmod +x /usr/share/cb/integrations/cb-defense-syslog/cb-defense-syslog


echo 'Everything should be in place now, just change the config as needed.'
echo 'Config is located here /etc/cb/integrations/cb-defense-syslog/cb-defense-syslog.conf'
echo 'The CB Defense forwarder is disabled by default.'
echo 'If you want to change this the crontab is located here /etc/cron.d/cb-defense-syslog'
echo 'There is a line that is commented out that will enable the forwarder to run hourly.'