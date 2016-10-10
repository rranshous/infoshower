#!/usr/bin/env bash

# vanilla raspian:

if grep -q "overlay" /etc/modules; then
  echo "overlay already in modules"
else
  echo "adding overlay module"
  echo "overlay" | sudo tee -a /etc/modules
fi

echo "installing apt-transport-https"
sudo apt-get install -y apt-transport-https

echo "downloading key"
wget -q https://packagecloud.io/gpg.key -O - | sudo apt-key add -

echo "adding hypriot source"
echo 'deb https://packagecloud.io/Hypriot/Schatzkiste/debian/ wheezy main' | sudo tee /etc/apt/sources.list.d/hypriot.list

echo "updating packages"
sudo apt-get update

echo "installing docker"
sudo apt-get install -y docker-hypriot

echo "enabling docker"
sudo systemctl enable docker

echo "adding docker group"
sudo usermod -a -G docker pi

echo "pulling rsync image"
sudo docker pull rranshous/rsyncd-rpi

echo "install fbi"
sudo apt-get install fbi

if grep -q "infoshower" /etc/rc.local; then
  echo "rc.local already set up"
else
  echo "update /etc/rc.local"
  sudo sed -i 's/exit 0//g' /etc/rc.local
  echo "if [ -f /home/pi/app/infoshower/shower ] && ! [ -f /home/pi/disable_infoshower ]; then" | sudo tee -a /etc/rc.local
  echo 'echo "launching infoshower"' | sudo tee -a /etc/rc.local
  echo "(sleep 10 && /home/pi/app/infoshower/shower /home/pi/infoshower-data/) &" | sudo tee -a /etc/rc.local
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

echo "turn off screen saver"

echo "set up rsync"
sudo docker run --restart=always -d --name=infoshower-rsync -v /home/pi/infoshower-data:/data -e RSYNC_PASSWORD=anonymous rranshous/rsyncd-rpi -avzh --delete  anonymous@infoshower.aws-dev.manheim.com::data/ ./

echo "done"
