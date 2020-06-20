# How to create a windows 10 bootble usb installer on linux

## Windusb
This script will install p7zip wimlib and rsync then extract the windows iso to a folder  
split the fat install.wim into 5 smaller parts that fits within the fat32 limit   
partition and format the usb drive and copy all the iso files we exracted and splited to it,  
Supports Ubuntu, Arch Linux, and Fedora based distros.    
For more details read dragon788 <a href="https://gist.github.com/dragon788/26921410d8de054366188c5c5435ae01" target="_top">win10_binary_fission.md</a>
## Usage:
has to be executed from the same directory as the windows iso  
``chmod +x windusb``  
as root  
``./windusb``  


[![alt text](https://raw.githubusercontent.com/Broly1/Windusb/master/ping1.png)](https://youtu.be./kLKc8EJ5Qfc "Click here")  



Credits to dragon788 

