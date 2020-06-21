#!/bin/bash
# Autor: Broly
# License: GNU General Public License v3.0
# https://www.gnu.org/licenses/gpl-3.0.txt


RED="\033[1;31m\e[3m"
NOCOLOR="\e[0m\033[0m"
cleanup="rm -rf /windUSB/"
set -e

# Checking for root Identifying distro pkg-manager and installing dependencies.
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}This script must be executed as root${NOCOLOR}!"
  exit 1
fi

banner() {
  msg="# $* #"
  edge=$(echo "$msg" | sed 's/./#/g')
  echo "$edge"
  echo "$msg"
  echo "$edge"
}
banner "WELCOME TO WINDUSB!!"

$cleanup

dependencies(){
  echo -e "Installing wimlib p7zip rsync!"
  sleep 2s
  declare -A osInfo;
  osInfo[/etc/debian_version]="apt install -y"
  osInfo[/etc/fedora-release]="dnf install -y"
  osInfo[/etc/arch-release]="pacman -S --noconfirm"

  for f in ${!osInfo[@]}
  do
    if [[ -f $f ]];then
      package_manager=${osInfo[$f]}
    fi
  done
  package="wimlib-utils p7zip p7zip-plugins rsync"
  package1="wimlib p7zip rsync"
  package2="wimtools p7zip-full rsync"

  if [ "${package_manager}" = "pacman -S --noconfirm" ]; then
    ${package_manager} ${package1}

  elif [ "${package_manager}" = "apt install -y" ]; then
    ${package_manager} ${package2}

  elif [ "${package_manager}" = "dnf install -y" ]; then
    ${package_manager} ${package}

  else
    echo -e "${RED}Your distro is not supported${NOCOLOR}!"
    exit 1
  fi
}

# Print disk devices
# Read command output line by line into array ${lines [@]}
# Bash 3.x: use the following instead:
#   IFS=$'\n' read -d '' -ra lines < <(lsblk --nodeps -no name,size | grep "sd")
readarray -t lines < <(lsblk --nodeps -no name,size | grep "sd")

# Prompt the user to select the drive.
echo -e "${RED}WARNING: THE SELECTED DRIVE WILL BE ERASED!!!${NOCOLOR}"
echo -e "Please select the usb-drive!"
select choice in "${lines[@]}"; do
  [[ -n $choice ]] || { echo -e "${RED}>>> Invalid Selection${NOCOLOR}!" >&2; continue; }
  break # valid choice was made; exit prompt.
done

# Split the chosen line into ID and serial number.
read -r id sn unused <<<"$choice"


# Here we partition the drive and dd the raw image to it.
partformat(){
  if
  umount $(echo /dev/$id?*) || :
  sgdisk --zap-all /dev/$id
  sgdisk -e /dev/$id --new=0:0: -t 0:0700
  partprobe $(echo /dev/$id?*)
  sleep 2s
  then
    mkfs.fat -F32 -n WIND $(echo /dev/$id)1
    mount $(echo /dev/$id)1 /mnt/
    mkdir /windUSB
  else
    exit 1
  fi
}
extract(){
  if
  7z x Win*.iso -o/windUSB/
  wimsplit /windUSB/sources/install.wim /windUSB/sources/install.swm 1000
  then
    rm -rf /windUSB/sources/install.wim
    echo -e "Copying files to $id be patient.."
    rsync -a --info=progress2 /windUSB/ /mnt/
    echo -e "umounting the drive do not remove it or cancel this process!"
    umount $(echo /dev/$id)1
    echo -e "Installation finished, reboot and boot from this drive!"
    $cleanup
    exit 1
  else
    exit 1
  fi
}

while true; do
  read -p "$(echo -e "Disk ${RED}$id${NOCOLOR} will be erased and wimlib, p7zip, rsync,
will be installed do you wish to continue (y/n)? ")" yn
  case $yn in
    [Yy]* ) dependencies; echo -e "Formating $id..."; partformat > /dev/null 2>&1 || :; extract; break;;
    [Nn]* ) exit;;
    * ) echo -e "Please answer yes or no.";;
  esac
done
