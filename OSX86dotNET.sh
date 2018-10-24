#!/bin/bash

# Originally made for MacTux Project  
#
# kyndder 2014/09/03 ~ 2018
#
#Part of the script was inspired by part of the pacapt (https://github.com/icy/pacapt/blob/master/pacapt#L168)
#
#Part of the script was inspired for m13253's Clover-Linux-Installer (https://github.com/m13253/clover-linux-installer)
#

#Create working dir
DEST_PATH="OSX86dotNET"

LOG_FILE="$HOME/$DEST_PATH/logfile.log"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

VERBOSE=""
OPTA=""
OPTC=""
OPTD=""
OPTE=""
EX1T=""
DISK=""
TARGET=""
THEDISKLIST=""
LOOP=""

while getopts "h?cavd:il" opt; do
    case "$opt" in
    h)
        echo "Available options are:
 -a 		= Compile and install APFS-Fuse drivers
 -c 		= Install Clover Bootloader to a disk
 -d 		= Used as direct jump, needs extra argument. Use "-?"
 -h 	 	= This help
 -i 		= Create a macOS installer
 -l 		= Run all tasks
 -v 		= Verbose output"
        exit 0
        ;;
    \?)
        echo "Some available arguments are:
 system_dump		=Dump system information
 acpidump		=Dump ACPI Table
 applefs		=Compile and install APFS-Fuse drivers "-a"
 clover_ask		=Install Clover to disk "-c"
 dev_tool		=Check and install development"
        exit 0
        ;;
    c)  OPTC="clover_ask"
        ;;
    a)  OPTA="applefs"
        ;;
    v)  VERBOSE="set -v"
        ;;
    d)  EX1T="exit 0"
		OPTD="$OPTARG"
        ;;
    :)  OPTD="$OPTARG"
		EX1T="exit 0"
        ;;
    l)  OPTE="runall"
        ;;
    i)  OPTI="domacosinstall"
        ;;
    esac
done

${VERBOSE}

eval mkdir -p "$HOME/$DEST_PATH"

#Known OSs
OS[1]="Arch" #PACMAN
OS[2]="Manjaro" #PACMAN
OS[3]="Debian" #DPKG
OS[4]="Ubuntu" #DPKG
OS[5]="Mint" #DPKG
OS[6]="CentOS" #YUM
OS[7]="Red" #YUM
OS[8]="Fedora" #YUM
OS[9]="SUSE" #ZYPPER
OS[10]="Gentoo" #EMERGE

OSTYPE=""

#Package Manager
PKM[1]="pacman -Syyu --noconfirm" #Arch / Manjaro
PKM[2]="pacman -Syyu --noconfirm" #Arch / Manjaro
PKM[3]="apt-get -y install" #Debian / Ubuntu / Mint
PKM[4]="apt-get -y install" #Debian / Ubuntu / Mint
PKM[5]="apt-get -y install" #Debian / Ubuntu / Mint
PKM[6]="yum -y install" #CentOS / Reh Hat / Fedora
PKM[7]="yum -y install" #CentOS / Reh Hat / Fedora
PKM[8]="yum -y install" #CentOS / Reh Hat / Fedora
PKM[9]="zypper --non-interactive" #SUSE
PKM[10]="emerge --pretend" #Gentoo

PM=""

#Dependencies
DP2=""
DP[1]="pv"
DP[2]="tree"
DP[3]="inxi"
#Developer utilities
DP[4]="base-devel"
DP[5]="devtools"
#APFS-Fuse dependencies
DP[6]="fuse-common"
DP[7]="icu"
DP[8]="zlib"
DP[9]="lib32-zlib"
DP[10]="bzip2"
#Clover
DP[11]="7z"
DP[12]="curl"
DP[13]="gzip"
DP[14]="libxml2"
DP[15]="xarchiver"
DP[16]="yay"
DP[17]="xar"

IFS=$'\n'

get_os()	#Check OS
{
for i in `seq 1 9`
do
	grep "${OS[i]}" /etc/os-release > =TMP
	case $? in
		0 )
		OSTYPE="${OS[i]}"  
		PACMAN="${PKM[i]}"  
		echo Found $OSTYPE !  
		echo Using native package manager!  
	esac
done
} >> ${LOG_FILE}

vent()	#Exit if no known OS
{
echo "$OSTYPE" | grep ""

case "$OSTYPE" in
'')
cat /etc/os-release | echo "${NAME}"  
echo "Unsupported OS, please, send a report."
exit 1
esac
clear
eval find "/home/${USER}/OSX86dotNET/*" | grep -v "logfile.log"
if [ $? -eq 0 ] ; then
	echo
	echo
    echo "There are some files at the $DEST_PATH folder.
Do you want to cleanup or keep it?

Please press C for clean or K to keep."
	read VENTANS
	if [[ $VENTANS = C ]] || [[ $VENTANS = c ]] ; then
		eval sudo rm -rf ${HOME}/${DEST_PATH}/*
	fi
fi
}

hello() #Hello!
{
clear
echo "Thank you for using $DEST_PATH Linux4macOS tool!
In order to provide you a better experience, we need to get some informations
from your system.

Do you want to proceed? Please, write YES or NO"
read WELCANS
if [[ $WELCANS = YES ]] || [[ $WELCANS = yes ]] ; then
	get_os
	vent
else
	exit 0
fi
}

verifydeps()	#Verify and install dependencies
{
clear
echo "Before we start, we must check some dependencies and install it, if needed.
You can check later, all that is done by this script at the ${LOG_FILE}"
sleep 5
deps
CHKDEPS
CLVDEPS
eval ${EX1T}
}

deps()	#Check dependencies
{
for i in `seq 1 3`
do
	if command -v ${DP[i]} > /dev/null 2>&1 ; then 
		echo "${DP[i]} found!"  
	else
		echo "${DP[i]} not found, installing package using package manager"  
    	eval sudo ${PACMAN} ${DP[i]} 
    	if [ $? -eq 0 ] ; then
    		echo "${DP[i]} successful instaled"  
    	else
    		echo "An unknown error occured, please send a report"
    		exit 1
    	fi
	fi
done
eval ${EX1T}
} >> ${LOG_FILE}

CHKDEPS()	#Check APFS-Fuse dependencies
{
for i in `seq 6 10`
do
	if pacman -Qk ${DP[i]} > /dev/null 2>&1 ; then
		echo "${DP[i]} found!"  
	else
		echo "${DP[i]} not found, installing package using package manager"  
	    eval sudo ${PACMAN} ${DP[i]} 
	    if [ $? -eq 0 ] ; then
	    	echo "${DP[i]} successful instaled"  
	    else
	    	echo "An unknown error occured, please send a report"
	    	exit 1
	    fi
	fi
done
eval ${EX1T}
} >> ${LOG_FILE}

CLVDEPS()	#Check Clover dependencies
{
for i in `seq 11 16`
do 
	if ( command -v ${DP[i]} > /dev/null 2>&1 ) || ( pacman -Qi ${DP[i]} > /dev/null 2>&1 ) ; then  
		echo "${DP[i]} found!"    
	else
		echo "${DP[i]} not found, installing package using package manager"  
    	eval sudo ${PACMAN} ${DP[i]}  
    	if [ $? -eq 0 ] ; then
    		echo "${DP[i]} successful instaled"  
    	else
    		eval sudo yay -Syyu --noconfirm ${DP[i]}  
    		if [ $? -eq 0 ] ; then
    			echo "${DP[i]} successful instaled" 
    		else
    			echo "An unknown error occured, please send a report"
    			exit 1
    		fi
    	fi
	fi
done
eval ${EX1T}
} >> ${LOG_FILE}

system_dump()	#Dumping system information
{
clear
echo "Do you want to make a complete system dump?
It will get detailed information about your Hardware.

Please, write YES or NO"
read SISANS
if [[ $SISANS = YES ]] || [[ $SISANS = yes ]] ; then
	dmesg > "$HOME/$DEST_PATH/dmesg.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
    sudo lscpu > "$HOME/$DEST_PATH/CPU_Information.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
    inxi -Fx > "$HOME/$DEST_PATH/System_Information.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
    lspci -nn -k >> "$HOME/$DEST_PATH/System_Information.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
    sudo fdisk -l > "$HOME/$DEST_PATH/Disk_Information.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
    sudo lshw -short > "$HOME/$DEST_PATH/Hardware_Sumary.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
    tree -F /boot/efi/ > "$HOME/$DEST_PATH/EFI_Info.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
    efivar -L > "$HOME/$DEST_PATH/EFI_Var.txt"
    for i in {1..10}; do sleep 0;  done | pv -pWs10 >/dev/null
fi
eval ${EX1T}
} 

dev_tool()	#Check development tools
{
clear
echo "Do you want to install development tools?
They are necessary to, for example, build packages.

Please write YES or NO"
read ANSWER
if [[ $APFSANS = YES ]] || [[ $APFSANS = yes ]] || [[ $APFSANS = Yes ]] ; then
	if [ $? -eq 0 ] ; then
		eval sudo ${PACMAN} ${DP[4]} ${DP[5]} >> ${LOG_FILE}
    	echo "Developer tools successfully instaled"
    else
    	echo "An unknown error occured, please send a report"
    	exit 1
    fi
else
    echo "Developer tools will not be installed."
    echo
	echo
	echo
fi
eval ${EX1T}
}  

acpi_tool()	#Check IASL
{
clear
echo "Do you want to install ACPI tools?
They are necessary to retrieve and decompile ACPI table from your system.

Please write YES or NO"
read ACPIANS
if [[ $ACPIANS = YES ]] || [[ $ACPIANS = yes ]] ; then
	if command -v iasl > /dev/null 2>&1 ; then 
		DP2="iasl" 
		eval echo "${DP2} found! You already have ACPI tools installed at your system." &>> ${LOG_FILE}
		echo
		echo
	else
		DP2="acpica" 
		echo "ACPI tools not found, installing package using package manager" &>> ${LOG_FILE}
    	eval sudo ${PACMAN} $DP2 >> ${LOG_FILE}
    	if [ $? -eq 0 ] ; then
    		echo "ACPI tools successful instaled" &>> ${LOG_FILE}
    	else
    		echo "An unknown error occured, please send a report" &>> ${LOG_FILE}
    		exit 1
    	fi
    fi
fi
eval ${EX1T}
}

acpidump()	#Dumping ACPI Table
{
clear
echo "Do you want to dump your ACPI table (DSDT, SSDT, etc..)?
You can use them to make improvements at your OS.

ATTENTION! ACPI tools are needed in order to make dumps.

Please write YES or NO"
read ACPIANS
if [[ $ACPIANS = YES ]] || [[ $ACPIANS = yes ]] ; then
	if command -v iasl > /dev/null 2>&1 ; then 
		DP2="iasl" 
		mkdir -p "$HOME/$DEST_PATH/DAT/" >> ${LOG_FILE}
		echo "Geting tables." &>> ${LOG_FILE}
		ls /sys/firmware/acpi/tables/ | grep -vwE "data|dynamic" > "$HOME/$DEST_PATH/ACPI_Table_List.txt" &>> ${LOG_FILE}
		cd "$HOME/$DEST_PATH/"
		for i in $(cat ACPI_Table_List.txt) ; do
    		sudo cat "/sys/firmware/acpi/tables/$i" > "$HOME/$DEST_PATH/DAT/$i.dat" &>> ${LOG_FILE}
    	done
    	echo "Decompiling tables." &>> ${LOG_FILE}
    	cd "$HOME/$DEST_PATH/DAT/"
    	for i in *
    	do
      		eval iasl -d "${i}" &>> ${LOG_FILE}
    	done
    	echo "Cleaning up." &>> ${LOG_FILE}
    	mkdir -p "$HOME/$DEST_PATH/DSL/" &>> ${LOG_FILE}
    	mv *.dsl "$HOME/$DEST_PATH/DSL/" &>> ${LOG_FILE}
    fi
fi
eval ${EX1T}
}

applefs()	#Check dependencies, compile and install APFS-Fuse drivers
{
clear
echo "Do you want to install OpenSource APFS-Fuse driver?
It can provide ReadOnly access to APFS formatted Volumes and DMGs.

Please write YES or NO"
read APFSANS
if [[ $APFSANS = YES ]] || [[ $APFSANS = yes ]] || [[ $APFSANS = Yes ]] ; then
	CHKDEPS
	GITCLONE
	APFSMAKE
	MVDRIVER
	if [ $? -eq 0 ] ; then
    	echo "APFS-Fuse successfully compiled and installed!
For usage and useful informations, please, read the ${HOME}/${DEST_PATH}/apfs-fuse/README.md file."
    else
    	echo "An unknown error occured, please send a report"
	    exit 1
    fi
else
    echo "APFS-Fuse will not be installed."
    echo
	echo
	echo
fi
eval ${EX1T}
} 

GITCLONE()	#Clone APFS-Fuse repository
{
eval git clone https://github.com/sgan81/apfs-fuse.git ${HOME}/${DEST_PATH}/apfs-fuse/  
if [ $? -eq 0 ] ; then
   	echo "git clone successful"
else
   	echo "An unknown error occured, please send a report"
    exit 1
fi
eval cd ${HOME}/${DEST_PATH}/apfs-fuse/
git submodule init
git submodule update
eval ${EX1T}
} >> ${LOG_FILE}

APFSMAKE()	#Compile APFS-Fuse driver
{
eval cd ${HOME}/${DEST_PATH}/apfs-fuse
mkdir build 
cd build 
cmake .. 
make 
if [ $? -eq 0 ] ; then
   	echo "compilation successful"
else
   	echo "An unknown error occured, please send a report"
    exit 1
fi
eval ${EX1T}
} >> ${LOG_FILE}

MVDRIVER() #Move APFS-Fuse driver
{
clear
echo "Now, we must move the drivers to your working PATH, please, provide
your password if needed"

eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/bin/* /usr/local/bin/  
eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/lib/* /usr/lib/  
eval ${EX1T}
} >> ${LOG_FILE}

clover_ask()	#Install Clover to disk
{
clear
echo "Do you want to install Clover Boot Loader to a USB Stick?

Please write YES or NO"
read CLOVERANS
if [ $CLOVERANS == YES ] || [ $CLOVERANS == yes ] ; then
	cl_uefi_bios
else
    echo "Clover Bootloader will not be installed."
    echo
	echo
	exit 0
fi
eval ${EX1T}
} 

LISTDISKS()	#Listing available disks
{
clear
echo "Before we proceed, please, make sure that only the target USB Stick is plugged in.
Remove any other one before continue, the disk will be ERASED in order to install Clover.

Do you want to proceed? Please write YES or NO"
read CLOVERDANS
if [[ $CLOVERDANS = YES ]] || [[ $CLOVERDANS = yes ]] ; then
	THEDISKLIST="$( ls -l /dev/disk/by-id/usb* )" &>> ${LOG_FILE}
	echo "${THEDISKLIST}"
	echo
	echo "Now, please type in the target device, for example, 'sdh'"
	read CLOVERDANS22
	if [[ ${CLOVERDANS22} != "^ " ]] ; then
		DISK="${CLOVERDANS22}" &>> ${LOG_FILE}
	else
		echo "An unknown error occured, please send a report"
    	exit 1
    fi
fi
eval ${EX1T}
} 

cl_uefi_bios()	#Choose between UEFI or Legacy BIOS
{
clear
echo "Do you want to install Clover for UEFI or non-UEFI (Legacy BIOS) system?.

Please write UEFI or BIOS"
read CLANS
if [[ $CLANS = UEFI ]] || [[ $CLANS = uefi ]] ; then
	LISTDISKS
	EXTRACL
	CLUEFI
else
    echo "Working on it, please, if you want to try UEFI run 'OSX86dotNET.sh -c'" #This will be Legacy BIOS section
    exit 0
fi
eval ${EX1T}
} 

EXTRACL()	#Download and extract Clover package
{
clear
echo "You are about to install Clover for UEFI boot at /dev/${DISK}1.
Do you want to proceed?.

Please write YES or NO"
read UEFIANS
if [[ $UEFIANS = YES ]] || [[ $UEFIANS = yes ]] ; then
    eval mkdir ${HOME}/${DEST_PATH}/Clover/ &>> ${LOG_FILE}
	eval cd ${HOME}/${DEST_PATH}/Clover/ &>> ${LOG_FILE}
    wget https://sourceforge.net/projects/cloverefiboot/files/latest/download
    eval mv download Clover.zip &>> ${LOG_FILE}
    7z x Clover.zip &>> ${LOG_FILE}
	eval mkdir ${HOME}/${DEST_PATH}/Clover/Clover.pkg &>> ${LOG_FILE}
	eval mv Clover_*.pkg ${HOME}/${DEST_PATH}/Clover/Clover.pkg/ &>> ${LOG_FILE}
	eval cd ${HOME}/${DEST_PATH}/Clover/Clover.pkg/ &>> ${LOG_FILE}
	xar -xzf Clover_*.pkg &>> ${LOG_FILE}
	rm -rf Clover_*.pkg &>> ${LOG_FILE}
	for i in ${HOME}/${DEST_PATH}/Clover/Clover.pkg/*
	do
    	eval cd ${i}
        cat Payload | gzip -c -d -q | cpio -i 2> /dev/null
        rm -rf Bom PackageInfo Payload Scripts 
	done
else
	echo "OK, exiting"
    exit 0
fi
eval ${EX1T}
}  

CLUEFI()	#Installing Clover for UEFI boot
{
eval cp -R ${HOME}/${DEST_PATH}/Clover/Clover.pkg/EFIFolder.pkg/EFI/ ${HOME}/${DEST_PATH}/Clover/EFI/ &>> ${LOG_FILE}
DRVLIST="$(ls ${HOME}/${DEST_PATH}/Clover/Clover.pkg/ | grep "64.UEFI")" &>> ${LOG_FILE}
eval echo ${DRVLIST} >> ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI.txt &>> ${LOG_FILE}
eval mkdir ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI &>> ${LOG_FILE}
for i in ${HOME}/${DEST_PATH}/Clover/Clover.pkg/*
do
   	eval cd ${i}    
    eval cp -R *.efi ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/ &>> ${LOG_FILE}
done
eval sudo mkdir ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/ &>> ${LOG_FILE}
eval cd ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/ &>> ${LOG_FILE}
eval sudo cp -R DataHubDxe-64.efi Fat-64.efi FSInject-64.efi HFSPlus-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/ &>> ${LOG_FILE}
eval sudo cp -R OsxFatBinaryDrv-64.efi PartitionDxe-64.efi VBoxExt4.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/ &>> ${LOG_FILE}
clear
echo "Only a basic set of EFI drivers were installed, you can find additional divers at the folder
${HOME}/${DEST_PATH}/Clover/temp_folder/EFI/CLOVER/drivers64UEFI/

Do you want to view a list of available EFI drivers? Please write YES or NO."
read CLUEFIANS90
if [[ $CLUEFIANS90 = YES ]] || [[ $CLUEFIANS90 = yes ]] ; then
	for i in ${DRVLIST} ; do
		echo "$i"
	done
	echo
	echo "Do you want to exit? Please write YES or NO."
	read C90
	if [[ $C90 = YES ]] || [[ $C90 = yes ]] ; then
		exit 0
	else
		cloudconfig
	fi
fi
eval ${EX1T}
cloudconfig
} 

cloudconfig()	#Open Clover Cloud Configurator
{
clear
echo "Do you want to create a new config.plist?
This option will launch Clover Cloud Configurator web app.

PS: After create you config.plist, place it at the folder ${HOME}/${DEST_PATH}/Clover/EFI/.

Please write YES or NO."
read CLCLOU
if [[ $CLCLOU = YES ]] || [[ $CLCLOU = yes ]] ; then
	xdg-open http://cloudclovereditor.altervista.org/cce/index.php &>> ${LOG_FILE}
fi
eval ${EX1T}
addkexts
}

addkexts() #Adding basic kexts
{
clear
echo "Do you want to add a basic set of kexts?
This option will add Lilu.kext, VirtualSMC.kext and LiluFriend.kext.

Please write YES or NO."
read KEXTANS
if [[ $KEXTANS = YES ]] || [[ $KEXTANS = yes ]] ; then
	eval cp -R ${DIR}/kexts/ ${HOME}/${DEST_PATH}/Clover/ &>> ${LOG_FILE}
	eval cd ${HOME}/${DEST_PATH}/Clover/kexts
	7z x kexts.zip &>> ${LOG_FILE}
	eval sudo cp -R LiluFriend.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ | pv -cN
	eval sudo cp -R Lilu.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ | pv -cN
	eval sudo cp -R VirtualSMC.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ | pv -cN
	echo "Kexts added!"
	clvfinish
else
	echo "Kexts will not be added."
fi
eval ${EX1T}
}

docloverimg() #Create EFI image file
{
eval cd ${HOME}/${DEST_PATH}/Clover/
sudo dd if=/dev/zero of=EFI.img count=199 bs=1M status=progress
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << FDISK_CMDS  | eval sudo fdisk EFI.img &>> ${LOG_FILE}
g			# create new GPT partition
n			# add new partition
1			# partition number
			# default - first sector 
			# partition size
t			# change partition type
1			# EFI System partition
x			# extra features
n			# change partition name
EFI			# EFI partition name
r			# return main menu
w			# write partition table and exit
FDISK_CMDS
sudo mkfs.fat -F 32 EFI.img -n EFI &>> ${LOG_FILE}
sleep 3
eval sudo mkdir /run/media/${USER}/CloverIMG/ &>> ${LOG_FILE}
eval sudo mount -t vfat -o loop EFI.img /run/media/${USER}/CloverIMG/ &>> ${LOG_FILE}
sleep 3
}

domacosimg() #Create EFI image file
{
eval cd ${HOME}/${DEST_PATH}/macOS/
sudo dd if=/dev/zero of=OS\ X\ Base\ System.img count=2500 bs=1M status=progress
#sleep 2
#sudo parted OS\ X\ Base\ System.img mklabel gpt
#sleep 1
#eval sudo udisksctl loop-setup -f "OS\ X\ Base\ System.img"
#sleep 1
#eval LOOP="$( losetup -l | grep "System.img" | gawk "{print \$1}" )"
#sleep 1
#echo "${LOOP}"
#sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << FDISK_CMDS  | eval sudo fdisk "${LOOP}"
#n			# add new partition
#1			# partition number
#			# default - first sector 
#			# partition size
#t			# change partition type
#1			# partition number
#38			# HFS/HFS+ partition
#x			# extra features
#n			# change partition name
#macOS		# macOS partition name
#r			# return main menu
#w			# write partition table and exit
#FDISK_CMDS
#sleep 2
#eval sudo losetup -d "${LOOP}"
#sleep 1
}  >> ${LOG_FILE}

dofilesystem() #Formatting USB Stick for CLover
{
echo
echo "Creating filesystem, please, be patient, this may take a while."
echo
eval sudo dd if=/dev/zero of=/dev/${DISK} bs=512 count=1 conv=notrunc status=progress
sleep 5
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << FDISK_CMDS  | eval sudo fdisk /dev/${DISK}
g			# create new GPT partition
n			# add new partition
1			# partition number
			# default - first sector 
+200MiB 	# partition size
n			# add new partition
2			# partition number
			# default - first sector 
			# default - last sector 
t			# change partition type
1			# partition number
1			# EFI System partition
t			# change partition type
2			# partition number
38			# HFS/HFS+ partition
x			# extra features
n			# change partition name
1			# partition number
EFI			# EFI partition name
n			# change partition name
2			# partition number
macOS		# macOS partition
r			# return main menu
w			# write partition table and exit
FDISK_CMDS
sudo mkfs.fat -F 32 /dev/${DISK}1 -n EFI &>> ${LOG_FILE}
sudo mkfs.hfsplus /dev/${DISK}2 -v macOS &>> ${LOG_FILE}
} >> ${LOG_FILE}

clvfinish() #Writting Clover to EFI partition
{
clear
echo "Now, we must move everything to its own place...
It's almost finished..."
sleep 3
echo
echo
echo "Finishing tasks..."
sleep 2
docloverimg
sleep 2
eval cd ${HOME}/${DEST_PATH}/Clover/ &>> ${LOG_FILE}
eval sudo cp -R EFI/ /run/media/${USER}/CloverIMG/ &>> ${LOG_FILE}
sleep 1
eval sudo umount /run/media/${USER}/CloverIMG/ &>> ${LOG_FILE}
sleep 1
eval sudo rm -rf /run/media/${USER}/CloverIMG/ &>> ${LOG_FILE}
dofilesystem
sleep 1
eval cd ${HOME}/${DEST_PATH}/Clover/
eval sudo dd if=EFI.img | pv | dd of=/dev/${DISK}1 bs=1M
sleep 1
eval udisksctl mount -t vfat -b /dev/${DISK}1 &>> ${LOG_FILE}
eval ${EX1T}
UNMPART
} 

UNMPART()	#Unmounting partition
{
clear
echo "Do you want to unmount ${DISK}1 ?

Please write YES or NO."
read EXITANS
if [[ $EXITANS = YES ]] || [[ $EXITANS = yes ]] ; then
	eval udisksctl unmount -b /dev/${DISK}1 &>> ${LOG_FILE}
	echo "Clover Boot Loader was successfully installed!"
else
	echo "Clover Boot Loader was successfully installed!"
fi
eval ${EX1T}
}

domacosinstall() #macOS installer
{
clear
echo "Do you want to create a macOS Mojave installer?
This option will download needed files and create a macOS installer.

Please write YES or NO."
read MACOSANS
if [[ $MACOSANS = YES ]] || [[ $MACOSANS = yes ]] ; then
	eval mkdir ${HOME}/${DEST_PATH}/macOS/ &>> ${LOG_FILE}
	eval cd ${HOME}/${DEST_PATH}/macOS/
	wget http://swcdn.apple.com/content/downloads/49/44/041-08708/vtip954dc6zbkpdv16iw18jmilcqdt8uot/BaseSystem.dmg 
	wget http://swcdn.apple.com/content/downloads/07/20/091-95774/awldiototubemmsbocipx0ic9lj2kcu0pt/BaseSystem.chunklist 
	wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/InstallInfo.plist 
	wget http://swcdn.apple.com/content/downloads/00/21/091-76348/67qi57g3fqpytl06cofi6bn2uuughsq2uo/InstallESDDmg.pkg 
	wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/AppleDiagnostics.dmg 
	wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/AppleDiagnostics.chunklist 
	sleep 1
	mv InstallESDDmg.pkg InstallESD.dmg &>> ${LOG_FILE}
	echo
	echo
	echo "Downloads finished!"
	changeinstallinfo
	copybasesystem
else
	echo "The installer will not be created."
	exit 0
fi
eval ${EX1T}
}

changeinstallinfo() #Make necessary modifications to InstallInfo.plist
{
sed -i -e 's/<key>chunklistURL<\/key>//g' ${HOME}/${DEST_PATH}/macOS/InstallInfo.plist
sleep 1
sed -i -e 's/<string>InstallESDDmg.chunklist<\/string>//g' ${HOME}/${DEST_PATH}/macOS/InstallInfo.plist
sleep 1
sed -i -e 's/<key>chunklistid<\/key>//g' ${HOME}/${DEST_PATH}/macOS/InstallInfo.plist
sleep 1
sed -i -e 's/<string>com.apple.chunklist.InstallESDDmg<\/string>//g' ${HOME}/${DEST_PATH}/macOS/InstallInfo.plist
sleep 1
sed -i -e 's/<string>InstallESDDmg.pkg<\/string>/<string>InstallESD.dmg<\/string>/g' ${HOME}/${DEST_PATH}/macOS/InstallInfo.plist
sleep 1
sed -i -e 's/<string>com.apple.pkg.InstallESDDmg<\/string>/<string>com.apple.dmg.InstallESD<\/string>/g' ${HOME}/${DEST_PATH}/macOS/InstallInfo.plist
sleep 1
eval ${EX1T}
} >> ${LOG_FILE}

dobasesystem() #Creates macOS installer
{
eval cd ${HOME}/${DEST_PATH}/macOS/
eval sudo mkdir "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/"
eval sudo mv BaseSystem.dmg "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/BaseSystem.dmg"
eval sudo mv BaseSystem.chunklist "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/BaseSystem.chunklist"
eval sudo mv InstallInfo.plist "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist"
eval sudo mv InstallESD.dmg "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallESD.dmg"
eval sudo mv AppleDiagnostics.dmg "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/AppleDiagnostics.dmg"
eval sudo mv AppleDiagnostics.chunklist "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/AppleDiagnostics.chunklist"
eval ${EX1T}
} >> ${LOG_FILE}

copybasesystem()	#Converting image to partition
{
clear
echo "Before we proceed, we must know where to place the files.
Choose the target partition at your USB Stick, for the macOS installer

The partition must have at least 7Gb free.

Do you want to proceed? Please write YES or NO"
read CPBASEANS
if [[ $CPBASEANS = YES ]] || [[ $CPBASEANS = yes ]] ; then
	THEDISKLIST="$( ls -l /dev/disk/by-id/usb* )" &>> ${LOG_FILE}
	echo "${THEDISKLIST}"
	echo
	echo "Now, please type in the target device, for example, 'sdh2'"
	read CPBASEANS22
	if [[ ${CPBASEANS22} != "^ " ]] ; then
		DISK="${CPBASEANS22}" &>> ${LOG_FILE}
		domacosimg
		eval cd ${HOME}/${DEST_PATH}/macOS/
		sudo dmg2img -v -i BaseSystem.dmg -p 4 -o OS\ X\ Base\ System.img &>> ${LOG_FILE}
		sleep 3
		eval sudo udisksctl loop-setup -f "${HOME}/${DEST_PATH}/macOS/OS\ X\ Base\ System.img" &>> ${LOG_FILE}
		eval LOOP="$( losetup -l | grep "System.img" | gawk "{print \$1}" )" &>> ${LOG_FILE}
		if [ -z "$LOOP" ]
		then
			echo "\$LOOP is empty"
			exit 1
		else
			echo "Image OK continuing..."
			echo $LOOP
		fi
		eval LOOPM="$( echo ${LOOP} | tac | grep -o "l.*" )"
		if [ -z "$LOOPM" ]
		then
			echo "\$LOOPM is empty"
			exit 1
		else
			echo "Image block OK continuing..."
			echo $LOOPM
		fi
		eval udisksctl mount -b "${LOOP}" &>> ${LOG_FILE}
		sleep 1
		eval sudo mkfs.hfsplus "/dev/${DISK}" -v "OS\ X\ Base\ System" &>> ${LOG_FILE}
		sleep 3
		eval udisksctl mount -b "/dev/${DISK}" &>> ${LOG_FILE}
		sleep 1
		eval mount | grep "/dev/${DISK}" | gawk "{print \$3, \$4, \$5, \$6}" | sed "s/ /\\\ /g" > ${HOME}/${DEST_PATH}/macOS/target.txt
		TARGET="$(cat ${HOME}/${DEST_PATH}/macOS/target.txt)"
		if [ -z "$TARGET" ]
		then
			echo "\$TARGET is empty"
			exit 1
		else
			echo "Target partition OK continuing..."
			echo "${TARGET}"
		fi
		sleep 1
		eval mount | grep "${LOOP}" | gawk "{print \$3, \$4, \$5, \$6}" | sed "s/ /\\\ /g" > ${HOME}/${DEST_PATH}/macOS/loopdir.txt
		LOODIR="$(cat ${HOME}/${DEST_PATH}/macOS/loopdir.txt)"
		if [ -z "$LOODIR" ]
		then
			echo "\$LOODIR is empty"
			exit 1
		else
			echo "Source directory OK continuing..."
			echo "${LOODIR}"
		fi
		sleep 1
		eval sudo cp -R "${LOODIR}"/* "${TARGET}"/
		sleep 3
		echo "Finishing tasks, this may take some time...
		
After finishing copiyng files, it may appear that it hangs, but it is just finishing up."
		echo
		dobasesystem
		sleep 3
		eval udisksctl unmount "${LOOP}" &>> ${LOG_FILE}
		eval udisksctl loop-delete -b "${LOOP}" &>> ${LOG_FILE}
		echo "Installer successful created!
		
Unplug and replug your USB Stick in order to view the files.

Thank you for using Linux4macOS tool!"
	else
		echo "An unknown error occured, please send a report"
    	exit 1
    fi
fi
eval ${EX1T}
} 

runall()	#Run all tasks -l
{
hello
verifydeps
system_dump
acpi_tool
acpidump 
dev_tool
applefs
clover_ask
domacosinstall
echo
eval xdg-open ${HOME}/${DEST_PATH}/ 
}

$OPTA
$OPTC
$OPTD
$OPTE
$OPTI
