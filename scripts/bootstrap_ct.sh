#! /bin/bash

export DEBIAN_FRONTEND=noninteractive

apt_update() {
  echo "[$(date +%H:%M:%S)]: Running apt-get clean..."
  apt-get clean
  echo "[$(date +%H:%M:%S)]: Running apt-get update..."
  apt-get -qq update
  apt-get -qq install -y
}

install_basics() {
    echo "[$(date +%H:%M:%S)]: Installing base software packages..."
    apt-get install -y unzip whois jq build-essential python3 python3-pip dos2unix docker.io
  #  groupadd docker
    usermod -aG docker $USER
    #set docker to run on startup (maybe no?)
    systemctl enable docker
}

install_covenant(){
  echo "[$(date +%H:%M:%S)]: Installing Covenant C2..."

  #Install Covenant
  echo "[$(date +%H:%M:%S)]: Install Covenant C2 from github..."

  cd /opt
  git clone --recurse-submodules https://github.com/cobbr/Covenant
  cd Covenant/Covenant
  echo "[$(date +%H:%M:%S)]: Building Covenant C2 Docker..."
  docker build -t covenant .
  echo "[$(date +%H:%M:%S)]: Starting Covenant C2 Docker..."
  docker run --restart always -it -d -p 7443:7443 -p 80:80 -p 443:443 --name covenant -v /opt/Covenant/Covenant/Data:/app/Data covenant

  echo "[$(date +%H:%M:%S)]: Covenant complete. Note: You will have to log in to create an initial user"

}

postinstall_tasks() {
  # Include Splunk and Bro in the PATH
  echo export PATH="$PATH:/opt/splunk/bin:/opt/bro/bin" >> ~/.bashrc
}
goto_root(){
  #goto_root
  echo "[$(date +%H:%M:%S)]: Going root..."
  sudo su -
}

install_caldera(){
  echo "-----------------------------------------------"
  echo "[$(date +%H:%M:%S)]: Installing MITRE Caldera"
  echo "-----------------------------------------------"
  echo "[$(date +%H:%M:%S)]: This will take a few minutes..."

  echo "[$(date +%H:%M:%S)]: Cloning repository..."
  cd /opt
  git clone https://github.com/mitre/caldera.git --recursive --branch master
  cd caldera

  echo "[$(date +%H:%M:%S)]: Creating Caldera docker..."
  docker build . -t caldera:server

  echo "[$(date +%H:%M:%S)]: Starting MITRE caldera docker"
  #python3 server.py&
  docker run --restart always -d -p 7010:7010 -p 7011:7011 -p 7012:7012 -p 8888:8888 caldera:server
}

install_services(){
  #move the service files from staging to the services location
  if [ -f "/opt/ControlTower/covenantc2.service" ]; then
    mv /opt/ControlTower/covenantc2.service /lib/systemd/system/
    chmod 644 /lib/systemd/system/covenantc2.service
    systemctl start covenantc2
    systemctl enable covenantc2
  else
    echo "ERROR: CovenantC2 service file missing."
  fi

}
enable_sshd(){
  sudo cp /opt/ControlTower/sshd_config /etc/ssh/
  sudo systemctl restart sshd

}
hostname(){
  echo -e "\n127.0.0.1       controltower" >> /etc/hosts
   hostnamectl set-hostname controltower

}

main() {
  #fix_eth1_static_ip
  goto_root
  hostname
  apt_update
  enable_sshd
  install_basics
  install_covenant
  install_caldera
#  install_services
  echo "----------------------------------------------------------------------------------------------"
  echo "[$(date +%H:%M:%S)]: ControlTower provisioning complete and will be available after the machine starts!"
  echo "----------------------------------------------------------------------------------------------"

  reboot

}

main
exit 0
