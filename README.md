
## Overview
The ESEL build is essentially a hard-fork from DetectionLab (https://github.com/clong/DetectionLab) with tweaks, additional VM's and tooling to be used for D3 purposes.

At this time, ESEL only works with virtualbox.  It's possible to adapt the environment for VMWare, AWS or AZure but hasn't been done due to time limitations.   This extensibility is possible once all the components are stable.

NOTE: This lab has not been hardened in any way and runs with default vagrant credentials. Please do not connect or bridge it to any networks you care about.

## D3 ESEL Features & Components:
* Covenant C2 Server deployed and preconfigured
* Caldera Adversary Simulation Server deployed and preconfigured
* Windows 10 deployed with Caldera and Covenant agents preconfigured and Running

## Detection Lab Features & Components:
* Microsoft Advanced Threat Analytics (https://www.microsoft.com/en-us/cloud-platform/advanced-threat-analytics) is installed on the WEF machine, with the lightweight ATA gateway installed on the DC
* Splunk forwarders are pre-installed and all indexes are pre-created. Technology add-ons for Windows are also preconfigured.
* A custom Windows auditing configuration is set via GPO to include command line process auditing and additional OS-level logging
* [Palantir's Windows Event Forwarding](http://github.com/palantir/windows-event-forwarding)  subscriptions and custom channels are implemented
* Powershell transcript logging is enabled. All logs are saved to `\\wef\pslogs`
* osquery comes installed on each host and is pre-configured to connect to a [Fleet](https://kolide.co/fleet) server via TLS. Fleet is preconfigured with the configuration from [Palantir's osquery Configuration](https://github.com/palantir/osquery-configuration)
* Sysmon is installed and configured using SwiftOnSecurity’s open-sourced configuration
* All autostart items are logged to Windows Event Logs via [AutorunsToWinEventLog](https://github.com/palantir/windows-event-forwarding/tree/master/AutorunsToWinEventLog)
* SMBv1 Auditing is enabled

## Requirements
* 55GB+ of free disk space
* 16GB+ of RAM
* Vagrant 2.2.2 or newer
* Virtualbox


## Installing ESEL Components

For now, the best way to instantiate ESEL is by using the Vagrant components.

1. Install the Virtualbox and Vagrant, if not already installed.  
  * Vagrant https://www.vagrantup.com/
  * Virtualbox 6.0 https://www.virtualbox.org/wiki/Download_Old_Builds_6_0
    NOTE: Virtualbox 6.1 is not yet supported by Vagrant, so use 6.0

2. Using vagrant, install the ESEL components. The entire routine is scripted using the build.sh and build.ps1 scripts however there are currently some errors and "smoothing" to the process that needs to be done.  So, for now it is suggested that you manually initiate the build of each component.

`cd Vagrant`

**Install ControlTower**\n
`vagrant up ControlTower`

*Install the logger*\n
`vagrant up logger`

c. Install the Windows 2016 DC
```
vagrant up dc
```

d. Install the Windows Event Forwarder (WEF) machine
```
vagrant up wef
```

e. Install the Windows 10 user machine
```
vagrant up win10
```
---

7. Ensure you are in the base DetectionLab folder and run `./build.sh` (Mac & Linux) or `./build.ps1` (Windows). This script will do the following:
  * Provision the logger host. This host will run the [Fleet](https://kolide.co/fleet) osquery manager and a fully featured pre-configured Splunk instance.
  * Provision the DC host and configure it as a Domain Controller
  * Provision the WEF host and configure it as a Windows Event Collector in the Servers OU
  * Provision the Win10 host and configure it as a computer in the Workstations OU

8. Build logs will be present in the `Vagrant` folder as `vagrant_up_<host>.log`. If filing an issue, please paste the contents of that log into a Gist to help with debugging efforts.

9. Navigate to https://192.168.38.105:8000 in a browser to access the Splunk instance on logger. Default credentials are admin:changeme (you will have the option to change them on the next screen)
10. Navigate to https://192.168.38.105:8412 in a browser to access the Fleet server on logger. Default credentials are admin:admin123#. Query packs are pre-configured with queries from [palantir/osquery-configuration](https://github.com/palantir/osquery-configuration).

---

## Basic Vagrant Usage

Moved to the wiki: [Basic Vagrant Usage](https://github.com/clong/DetectionLab/wiki/Vagrant-Usage)

---

## Lab Information

Moved to the wiki: [Lab Information & Credentials](https://github.com/clong/DetectionLab/wiki/Lab-Information-&-Credentials)

---

#Troubleshooting

1. Using ESXi as the provier, I get the error "An active machine was found with a different provider."
Unfortunately, this is a limitation of vagrant where you control the provisioning of a single image with mulitple provisioners (e.g. ESXI and virtualbox).  You'll need to rename/delete the vagrant data in the .vagrant folder.
