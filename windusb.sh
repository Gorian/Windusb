#!/bin/bash
# Autor: Broly
# License: GNU General Public License v3.0
# https://www.gnu.org/licenses/gpl-3.0.txt
# This script is inteded to create a opencore usb-installer on linux just like
#'Makeinstall.py" does on windows there for it should be executerd
# from /gibMacOS-master/ directory.
# dependency gibmacos https://github.com/corpnewt/gibMacOS

RED="\033[1;31m\e[3m"
NOCOLOR="\e[0m\033[0m"
YELLOW="\033[01;33m\e[3m"
set -e

# Checking for root Identifying distro pkg-manager and installing dependencies.
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}This script must be executed as root!${NOCOLOR}"
  exit 1
fi

echo -e "\e[3mWe need to install some important tools to proceed!\e[0m"
sleep 3s

declare -A osInfo;
osInfo[/etc/debian_version]="apt install -y"
osInfo[/etc/alpine-release]="apk --update add"
osInfo[/etc/centos-release]="yum install -y"
osInfo[/etc/fedora-release]="dnf install -y"
osInfo[/etc/arch-release]="pacman -S --noconfirm"

for f in ${!osInfo[@]}
do
  if [[ -f $f ]];then
    package_manager=${osInfo[$f]}
  fi
done
echo -e "\e[3mInstalling Depencencies...\e[0m"
package="wimlib p7zip"
package1="wimlib p7zip"
package2="wimtools p7zip-full"

if [ "${package_manager}" = "pacman -S --noconfirm" ]; then
  ${package_manager} ${package1}

elif [ "${package_manager}" = "apt install -y" ]; then
  ${package_manager} ${package2}

elif [ "${package_manager}" = "yum install -y" ]; then
  ${package_manager} ${package1}

elif [ "${package_manager}" = "dnf install -y" ]; then
  ${package_manager} ${package}

else
  echo -e "${RED}Your distro is not supported!${NOCOLOR}"
  exit 1
fi


# Print disk devices
# Read command output line by line into array ${lines [@]}
# Bash 3.x: use the following instead:
#   IFS=$'\n' read -d '' -ra lines < <(lsblk --nodeps -no name,size | grep "sd")
readarray -t lines < <(lsblk --nodeps -no name,size | grep "sd")

# Prompt the user to select the drive.
echo -e "${RED}WARNING: THE SELECTED DRIVE WILL BE FORMATED !!!${NOCOLOR}"
echo -e "${YELLOW}Please select the usb-drive!${NOCOLOR}"
select choice in "${lines[@]}"; do
  [[ -n $choice ]] || { echo -e "${RED}>>> Invalid Selection !${NOCOLOR}" >&2; continue; }
  break # valid choice was made; exit prompt.
done

# Split the chosen line into ID and serial number.
read -r id sn unused <<<"$choice"


# Here we partition the drive and dd the raw image to it.
partformat(){
  if
  umount $(echo /dev/$id?*) > /dev/null 2>&1 || :
  sleep 3s
  sgdisk --zap-all /dev/$id > /dev/null 2>&1
  sgdisk -e /dev/$id --new=0:0:+7000MiB -t 0:0700
  partprobe $(echo /dev/$id?*)
  sleep 3s
  mkfs.fat -F32 -n WIND $(echo /dev/$id)1
  mount $(echo /dev/$id)1 /mnt/
  mkdir /winblows
  7z x Win*.iso -o/winblows/
  wimsplit /winblows/sources/install.wim /winblows/sources/install.swm 1000
  rm -rf /winblows/sources/install.wim
  mv -v /winblows/* /mnt/
  rm -rf /winblows

  then
    sleep 3s
  else
    exit 1
  fi
}

while true; do
  read -p "$(echo -e ${YELLOW}"Drive ($id) will be erased, do you wish to continue (y/n)? "${NOCOLOR})" yn
  case $yn in
    [Yy]* ) partformat; break;;
    [Nn]* ) exit;;
    * ) echo -e "${YELLOW}Please answer yes or no."${NOCOLOR};;
  esac
done
