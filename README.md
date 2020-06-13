# How to create a windows 10 bootble usb installer on linux

## Windusb
This is a bash script to create Windows usb installers on Linux
Supports Ubuntu, Arch Linux, and Fedora based distros.  
You probably stumbled across this post because you got an error trying to use dd command, 7zip or    
Gnome-Disk Utility when trying to make a bootable Windows USB. This might have been E_FAIL from p7zip/7zip, or a hard to spot error in the logs when you cp or 7z x the entire contents of the ISO over to a FAT32 USB. Since FAT32 can only handle files up to 4GB (it truncates anything larger), the "fluffy" install.wim that exceeds this limit gets corrupted and results in a USB that you can boot from, but fails partway through attempting to install Windows, luckily it usually stops before it deletes the partitions that currently exist on the destination hard drive, so you may still have a bootable system that you can follow these directions to salvage or properly prepare the USB drive.
## Usage:
has to be executed from the same directory as the windows iso  
``chmod +x windusb``  
as root  
``./windusb``  
This script will extract the windows iso to a folder split the fat install.wim into 5 smallerparts that fits within the fat32   limit.

[![alt text](https://raw.githubusercontent.com/Broly1/Windusb/master/ping1.png)](https://youtu.be./kLKc8EJ5Qfc "Click here")  



Credits to dragon788 for the  <a href="https://gist.github.com/dragon788/26921410d8de054366188c5c5435ae01" target="_top">win10_binary_fission.md</a>

