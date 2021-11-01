# Headless Raspberry Pi Installation

## Goals
Provide a solution when:
* there's no access to an extra keyboard/display
* a quick hands-off, repeatable installation process is needed

## OS

Automate the creation of a bootable USB/SD-Card drive for a Raspberry Pi 4, with the required configuration to run containers.

## Usage

* Run `./os/configure` to enter the information of the new server. An ssh key will
be generated if you do not have one.
* Unplug the disk/SSD card/USB key.
* Run `sudo ./os/make_disk.sh`.
* Follow the instructions.
* Plug the drive in your Rapsberry Pi and power it on. The device should NOT be used until it has completed the first boot setup and rebooted. 
* You can monitor the first boot with `ssh $USER@$IP sudo tail -f /var/log/cloud-init-output.log` where `$USER` is the value of `default_user` in `tmp/user-data.secret` and `$IP` is the IP of the device on the network.
