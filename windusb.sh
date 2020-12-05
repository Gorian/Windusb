#!/bin/bash
# Autor: Broly
# License: GNU General Public License v3.0
# https://www.gnu.org/licenses/gpl-3.0.txt


RED="\033[1;31m\e[3m"
NOCOLOR="\e[0m\033[0m"
cleanup="rm -rf /windUSB/"
set -e
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@" 
clear
echo "  ############################ "
echo " #    WELCOME TO WINDUSB    # "
echo "############################ "
echo " "
sleep 2s
$cleanup

dependencies(){
	clear
	echo "  ################################ "
	echo " #    INSTALLING DEPENDENCIES   # "
	echo "################################ "
	echo " "
	sleep 2s
	declare -A osInfo;
	osInfo[/etc/debian_version]="apt install -y"
	osInfo[/etc/fedora-release]="dnf install -y"
	osInfo[/etc/arch-release]="pacman -Sy --noconfirm"

	for f in ${!osInfo[@]}
	do
		if [[ -f $f ]];then
			package_manager=${osInfo[$f]}
		fi
	done
	package="wimlib-utils p7zip p7zip-plugins rsync"
	package1="wimlib p7zip rsync"
	package2="wimtools p7zip-full rsync"

	if [ "${package_manager}" = "pacman -Sy --noconfirm" ]; then
		${package_manager} --needed ${package1}

	elif [ "${package_manager}" = "apt install -y" ]; then
		${package_manager} ${package2}

	elif [ "${package_manager}" = "dnf install -y" ]; then
		${package_manager} ${package}

	else
		echo -e "${RED}Your distro is not supported${NOCOLOR}!"
		exit 1
	fi
}

clear
echo " "
echo -e "  #################################################"
echo -e " #  ${RED}WARNING: THE SELECTED DRIVE WILL BE ERASED!${NOCOLOR}  # "
echo -e "#################################################"
echo " "
readarray -t lines < <(lsblk -p -no name,size,MODEL,VENDOR,TRAN | grep "usb")
echo -e "Please select the usb-drive!"
select choice in "${lines[@]}"; do
	[[ -n $choice ]] || { echo -e "${RED}>>> Invalid Selection${NOCOLOR}!" >&2; continue; }
	break
done
read -r id sn unused <<<"$choice"
if [ -z "$choice" ]; then
	echo -e "Please insert the USB Drive and try again."
	exit 1
fi
partformat(){
	clear
	echo "  ############################### "
	echo " #    PARTITIONING THE DRIVE   # "
	echo "############################### "
	echo " "
	umount $(echo $id?*) || :
	sgdisk --zap-all $id && partprobe
	sgdisk -e $id --new=0:0: -t 0:0700 && partprobe
	sleep 2s
	mkfs.fat -F32 -n WIND $(echo $id)1
	mount $(echo $id)1 /mnt/
	mkdir /windUSB
}
extract(){
	clear
	echo "  ############################# "
	echo " #    EXTRACTING ISO FILE    # "
	echo "############################# "
	echo " "
	7z x Win*.iso -o/windUSB/
	clear
	echo "  ############################### "
	echo " #    SPLITTING INSTALL.WIM    # "
	echo "############################### "
	echo " "
	wimsplit /windUSB/sources/install.wim /windUSB/sources/install.swm 1000
	rm -rf /windUSB/sources/install.wim
	clear
	echo "  #################################### "
	echo " #    COPYING FILES TO THE DRIVE    # "
	echo "#################################### "
	echo " "
	rsync -a --info=progress2 /windUSB/ /mnt/

	echo -e "umounting the drive do not remove it or cancel this process it will take a long time!"
	umount $(echo $id)1
	echo -e "Installation finished!"
	$cleanup
}

while true; do
	read -p "$(echo -e "Disk ${RED}$id${NOCOLOR} will be erased and wimlib, p7zip, rsync,
	will be installed do you wish to continue (y/n)? ")" yn
	case $yn in
		[Yy]* ) dependencies; partformat; extract; break;;
		[Nn]* ) exit;;
		* ) echo -e "Please answer yes or no.";;
	esac
done
