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
  if [ -f "/tmp/covenantc2.service" ]; then
    mv /tmp/covenantc2.service /lib/systemd/system/
    chmod 644 /lib/systemd/system/covenantc2.service
    systemctl start covenantc2
    systemctl enable covenantc2
  else
    echo "ERROR: CovenantC2 service file missing."
  fi

}
enable_sshd(){
  sudo cp /tmp/sshd_config /etc/ssh/
  sudo systemctl restart sshd

}
hostname(){
  echo -e "\n127.0.0.1       controltower" >> /etc/hosts
   hostnamectl set-hostname controltower

}


install_splunk() {
  # Check if Splunk is already installed
  if [ -f "/opt/splunk/bin/splunk" ]; then
    echo "[$(date +%H:%M:%S)]: Splunk is already installed"
  else
    echo "[$(date +%H:%M:%S)]: Installing Splunk..."
    # Get download.splunk.com into the DNS cache. Sometimes resolution randomly fails during wget below
    dig @8.8.8.8 download.splunk.com >/dev/null
    dig @8.8.8.8 splunk.com >/dev/null
    dig @8.8.8.8 www.splunk.com >/dev/null

    # Try to resolve the latest version of Splunk by parsing the HTML on the downloads page
    echo "[$(date +%H:%M:%S)]: Attempting to autoresolve the latest version of Splunk..."
    LATEST_SPLUNK=$(curl https://www.splunk.com/en_us/download/splunk-enterprise.html | grep -i deb | grep -Eo "data-link=\"................................................................................................................................" | cut -d '"' -f 2)
    # Sanity check what was returned from the auto-parse attempt
    if [[ "$(echo $LATEST_SPLUNK | grep -c "^https:")" -eq 1 ]] && [[ "$(echo $LATEST_SPLUNK | grep -c "\.deb$")" -eq 1 ]]; then
      echo "[$(date +%H:%M:%S)]: The URL to the latest Splunk version was automatically resolved as: $LATEST_SPLUNK"
      echo "[$(date +%H:%M:%S)]: Attempting to download..."
      wget --progress=bar:force -P /opt "$LATEST_SPLUNK"
    else
      echo "[$(date +%H:%M:%S)]: Unable to auto-resolve the latest Splunk version. Falling back to hardcoded URL..."
      # Download Hardcoded Splunk
      wget --progress=bar:force -O /opt/splunk-8.0.2-a7f645ddaf91-linux-2.6-amd64.deb 'https://download.splunk.com/products/splunk/releases/8.0.2/linux/splunk-8.0.2-a7f645ddaf91-linux-2.6-amd64.deb&wget=true'
    fi
    if ! ls /opt/splunk*.deb 1> /dev/null 2>&1; then
      echo "Something went wrong while trying to download Splunk. This script cannot continue. Exiting."
      exit 1
    fi
    if ! dpkg -i /opt/splunk*.deb > /dev/null; then
      echo "Something went wrong while trying to install Splunk. This script cannot continue. Exiting."
      exit 1
    fi

    /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd changeme
    /opt/splunk/bin/splunk add index wineventlog -auth 'admin:changeme'
    /opt/splunk/bin/splunk add index osquery -auth 'admin:changeme'
    /opt/splunk/bin/splunk add index osquery-status -auth 'admin:changeme'
    /opt/splunk/bin/splunk add index sysmon -auth 'admin:changeme'
    /opt/splunk/bin/splunk add index powershell -auth 'admin:changeme'
    /opt/splunk/bin/splunk add index zeek -auth 'admin:changeme'
    /opt/splunk/bin/splunk add index suricata -auth 'admin:changeme'
    /opt/splunk/bin/splunk add index threathunting -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_forwarder/splunk-add-on-for-microsoft-windows_700.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/splunk-add-on-for-microsoft-sysmon_1062.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/asn-lookup-generator_110.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/lookup-file-editor_331.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/splunk-add-on-for-zeek-aka-bro_400.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/force-directed-app-for-splunk_200.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/punchcard-custom-visualization_130.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/sankey-diagram-custom-visualization_130.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/link-analysis-app-for-splunk_161.tgz -auth 'admin:changeme'
    /opt/splunk/bin/splunk install app /tmp/splunk_server/threathunting_141.tgz -auth 'admin:changeme'

    # Install the Maxmind license key for the ASNgen App
    if [ ! -z $MAXMIND_LICENSE ]; then
      mkdir /opt/splunk/etc/apps/TA-asngen/local 
      cp /opt/splunk/etc/apps/TA-asngen/default/asngen.conf /opt/splunk/etc/apps/TA-asngen/local/asngen.conf
      sed -i "s/license_key =/license_key = $MAXMIND_LICENSE/g" /opt/splunk/etc/apps/TA-asngen/local/asngen.conf
    fi

    # Add custom Macro definitions for ThreatHunting App
    cp /tmp/splunk_server/macros.conf /opt/splunk/etc/apps/ThreatHunting/default/macros.conf
    # Fix Windows TA macros
    mkdir /opt/splunk/etc/apps/Splunk_TA_windows/local
    cp /opt/splunk/etc/apps/Splunk_TA_windows/default/macros.conf /opt/splunk/etc/apps/Splunk_TA_windows/local
    sed -i 's/wineventlog_windows/wineventlog/g' /opt/splunk/etc/apps/Splunk_TA_windows/local/macros.conf
    # Fix Force Directed App until 2.0.1 is released (https://answers.splunk.com/answers/668959/invalid-key-in-stanza-default-value-light.html#answer-669418)
    rm /opt/splunk/etc/apps/force_directed_viz/default/savedsearches.conf

    # Add a Splunk TCP input on port 9997
    echo -e "[splunktcp://9997]\nconnection_host = ip" >/opt/splunk/etc/apps/search/local/inputs.conf
    # Add props.conf and transforms.conf
    cp /tmp/splunk_server/props.conf /opt/splunk/etc/apps/search/local/
    cp /tmp/splunk_server/transforms.conf /opt/splunk/etc/apps/search/local/
    cp /opt/splunk/etc/system/default/limits.conf /opt/splunk/etc/system/local/limits.conf
    # Bump the memtable limits to allow for the ASN lookup table
    sed -i.bak 's/max_memtable_bytes = 10000000/max_memtable_bytes = 30000000/g' /opt/splunk/etc/system/local/limits.conf

    # Skip Splunk Tour and Change Password Dialog
    echo "[$(date +%H:%M:%S)]: Disabling the Splunk tour prompt..."
    touch /opt/splunk/etc/.ui_login
    mkdir -p /opt/splunk/etc/users/admin/search/local
    echo -e "[search-tour]\nviewed = 1" >/opt/splunk/etc/system/local/ui-tour.conf
    # Source: https://answers.splunk.com/answers/660728/how-to-disable-the-modal-pop-up-help-us-to-improve.html
    if [ ! -d "/opt/splunk/etc/users/admin/user-prefs/local" ]; then
      mkdir -p "/opt/splunk/etc/users/admin/user-prefs/local"
    fi
    echo '[general]
render_version_messages = 1
dismissedInstrumentationOptInVersion = 4
notification_python_3_impact = false
display.page.home.dashboardId = /servicesNS/nobody/search/data/ui/views/logger_dashboard' > /opt/splunk/etc/users/admin/user-prefs/local/user-prefs.conf
    # Enable SSL Login for Splunk
    echo -e "[settings]\nenableSplunkWebSSL = true" >/opt/splunk/etc/system/local/web.conf
    # Copy over the Logger Dashboard
    if [ ! -d "/opt/splunk/etc/apps/search/local/data/ui/views" ]; then
      mkdir -p "/opt/splunk/etc/apps/search/local/data/ui/views"
    fi
    cp /tmp/splunk_server/logger_dashboard.xml /opt/splunk/etc/apps/search/local/data/ui/views || echo "Unable to find dashboard"
    # Reboot Splunk to make changes take effect
    /opt/splunk/bin/splunk restart
    /opt/splunk/bin/splunk enable boot-start
  fi
}


main() {
  #fix_eth1_static_ip
  goto_root
  hostname
  apt_update
  enable_sshd
  install_basics
 # install_covenant
 # install_caldera
#  install_services
  install_splunk
  echo "----------------------------------------------------------------------------------------------"
  echo "[$(date +%H:%M:%S)]: ControlTower provisioning complete and will be available after the machine starts!"
  echo "----------------------------------------------------------------------------------------------"

  reboot

}

main
exit 0
