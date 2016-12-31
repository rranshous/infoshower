#!/usr/bin/env bash

# vanilla raspian:

echo "updating packages"
sudo apt-get update

echo "install needed packages"
sudo apt-get install fbi omxplayer kbd

if grep -q "infoshower" /etc/rc.local; then
  echo "rc.local already set up"
else
  echo "update /etc/rc.local"
  sudo sed -i 's/exit 0//g' /etc/rc.local
  echo "if [ -f /home/pi/app/infoshower/shower ] && ! [ -f /home/pi/disable_infoshower ]; then" | sudo tee -a /etc/rc.local
  echo 'echo "launching infoshower"' | sudo tee -a /etc/rc.local
  echo "(sleep 10 && cd /home/pi/app/infoshower && /home/pi/app/infoshower/shower /home/pi/infoshower-data/) &" | sudo tee -a /etc/rc.local
  echo "fi" | sudo tee -a /etc/rc.local
  echo "exit 0" | sudo tee -a /etc/rc.local
fi

echo "cloning infoshower project"
rm -rf /home/pi/app/infoshower
mkdir -p /home/pi/app
cd /home/pi/app
git clone http://github.ove.local/rranshous/infoshower.git

echo "making data dir"
mkdir -p /home/pi/infoshower-data

echo "set up rsync"
if grep -q "rsync" /etc/crontab; then
  echo "Crontab entry exists"
else
  echo "adding crontab entry"
  echo "*/5 *   * * *   root    RSYNC_PASSWORD=anonymous rsync -avzh --delete  anonymous@infoshower.aws-dev.manheim.com::data/ /home/pi/infoshower-data" | sudo tee -a /etc/crontab
fi

#echo "turn off screen saver"

echo "done"
