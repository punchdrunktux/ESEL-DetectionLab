

ControlTower_IP = '192.168.38.20'
NetSec_IP = '10.10.10.27'
Win10_Unprotected_IP = '192.168.38.50'

GW = '192.168.38.1'
DNS = '192.168.38.102'

Vagrant.configure("2") do |config|
  config.vm.define "NetSec" do |cfg|
    cfg.vm.box = "bento/ubuntu-18.04"
    cfg.vm.hostname = "netsec"
    cfg.vm.provision :shell, path: "bootstrap.sh"
    cfg.vm.network :private_network, ip: NetSec_IP, gateway: GW, dns: DNS

    cfg.vm.provider "vmware_desktop" do |v, override|
      v.vmx["displayname"] = "27-netsec"
      v.memory = 4096
      v.cpus = 2
      v.gui = true
    end
  end
  config.vm.define "ControlTower" do |cfg|

      #  cfg.vm.synced_folder "~/dev/ESEL/SharedFiles", "/SharedFiles"
        cfg.vm.box = "bento/ubuntu-18.04"
        cfg.vm.hostname = "20-ControlTower"
        cfg.vm.network :private_network, ip: ControlTower_IP, gateway: GW, dns: DNS
        cfg.vm.provision :shell, path: "scripts/bootstrap_ct.sh"
        cfg.vm.provision "file", source: "~/dev/ESEL-DetectionLab/resources/ControlTower", destination: "/tmp/"
        cfg.vm.provision "file", source: "~/dev/ESEL-DetectionLab/resources/splunk_server", destination: "/tmp/"
        cfg.vm.provision "file", source: "~/dev/ESEL-DetectionLab/resources/splunk_forwarder", destination: "/tmp/"

        cfg.vm.provision "shell", inline: "sudo mv /tmp/ControlTower /opt/; dos2unix -q /opt/ControlTower/*; chmod +x /opt/ControlTower/*.sh"
        #replace the SSH configuration to allow SSH
        #cfg.vm.provision "shell", inline: "sudo cp /opt/ControlTower/sshd_config /etc/ssh/sshd_config; sudo systemctl restart ssh"
        #put covenant data file back.
        #cfg.vm.provision "reload"
        #cfg.vm.provision :shell, path: "scripts/ct_checkservices.sh"


        cfg.vm.provider "vmware_desktop" do |v, override|
     #     v.name = "ControlTower"
          v.vmx["displayname"] = "20-ControlTower"
          v.memory = 4096
          v.cpus = 2
          v.gui = true
        end
  end
  

  config.vm.define "win10-unprotected" do |cfg|
    cfg.vm.box = "StefanScherer/windows_10"
    cfg.vm.hostname = "win10-unprotected"
    cfg.vm.boot_timeout = 1200
    cfg.vm.communicator = "winrm"
    cfg.winrm.basic_auth_only = true
    cfg.winrm.timeout = 1200
    cfg.winrm.retry_limit = 20
    cfg.vm.network :private_network, ip: Win10_Unprotected_IP, gateway: GW, dns: DNS

    #cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: false, args: "-ip "+Win10_Unprotected_IP+" -dns " +DNS
    cfg.vm.provision "shell", path: "scripts/MakeWindows10GreatAgain.ps1", privileged: false
    #cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "shell", inline: "cscript c:\\windows\\system32\\slmgr.vbs -rearm", privileged: false
    cfg.vm.provision "reload"
    #cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/download_palantir_wef.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/download_palantir_osquery.ps1", privileged: false
    cfg.vm.provision "shell", inline: 'wevtutil el | Select-String -notmatch "Microsoft-Windows-LiveId" | Foreach-Object {wevtutil cl "$_"}', privileged: false
    cfg.vm.provision "shell", path: "scripts/install-utilities.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/disable-windows-defender.ps1", privileged: false
    cfg.vm.provision "reload"  # need to run the disable-windows-defender script 2 times w/reboot
    #cfg.vm.provision "shell", path: "scripts/disable-windows-defender.ps1", privileged: false
    #cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "scripts/install-redteam.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/install-choco-extras.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/install-osquery.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/install-sysinternals.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/install-autorunstowineventlog.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/install-atomicred.ps1", privileged: false
    

    cfg.vm.provider "vmware_desktop" do |v, override|
      v.vmx["displayname"] = "win10_unprotected.windomain.local"
      v.vmx["gui.fullscreenatpoweron"] = "FALSE"
      v.vmx["gui.viewModeAtPowerOn"] = "windowed"
      v.memory = 2048
      v.cpus = 1
      v.gui = true
      v.enable_vmrun_ip_lookup = false
    end

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = true
      vb.name = "win10_unprotected.windomain.local"
      vb.default_nic_type = "82545EM"
      vb.customize ["modifyvm", :id, "--memory", 2048]
      vb.customize ["modifyvm", :id, "--cpus", 1]
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
  end
  
end
