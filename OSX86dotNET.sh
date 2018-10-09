#!/bin/bash

# Originally made for MacTux Project  
#
# kyndder 2014/09/03 ~ 2018
#
#Part of the script was inspired by part of the pacapt (https://github.com/icy/pacapt/blob/master/pacapt#L168)
#
#Part of the script was inspired for m13253's Clover-Linux-Installer (https://github.com/m13253/clover-linux-installer)
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

VERBOSE=""
OPTA=""
OPTC=""
OPTD=""
OPTE=""
EX1T=""
PARTITION=""

while getopts "h?cavd:l" opt; do
    case "$opt" in
    h)
        echo "Available options are:
 -a 		= Compile and install APFS-Fuse drivers
 -c 		= Install Clover Bootloader to a disk
 -d 		= Used as direct jump, needs extra argument. Use "-?"
 -h 	 	= This help
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
    v)  VERBOSE="set -x"
        ;;
    d)  EX1T="exit 0"
		OPTD="$OPTARG"
        ;;
    :)  OPTD="$OPTARG"
		EX1T="exit 0"
        ;;
    l)  OPTE="runall"
        ;;
    esac
done

${VERBOSE}

#Create working dir
DEST_PATH="OSX86dotNET"

eval mkdir -p "$HOME/$DEST_PATH"

LOG_FILE="$HOME/$DEST_PATH/logfile.log"

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
		OSTYPE="${OS[i]}" >> ${LOG_FILE}
		PACMAN="${PKM[i]}" >> ${LOG_FILE}
		echo Found $OSTYPE ! >> ${LOG_FILE}
		echo Using native package manager! >> ${LOG_FILE}
	esac
done
} 

vent()	#Exit if no known OS
{
echo "$OSTYPE" | grep ""

case "$OSTYPE" in
'')
cat /etc/os-release | echo "${NAME}" >> ${LOG_FILE}
echo "Unsupported OS, please, send a report."
exit 1
esac
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
if [[ $APFSANS = YES ]] || [[ $APFSANS = yes ]] ; then
	eval sudo ${PACMAN} ${DP[4]} ${DP[5]} >> ${LOG_FILE}
	if [ $? -eq 0 ] ; then
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
	if command -v iasl > /dev/null 2>&1 ; then >> ${LOG_FILE}
		DP2="iasl" >> ${LOG_FILE}
		eval echo "${DP2} found! You already have ACPI tools installed at your system."
		echo
		echo
	else
		DP2="acpica" >> ${LOG_FILE}
		echo "ACPI tools not found, installing package using package manager"
    	eval sudo ${PACMAN} $DP2 >> ${LOG_FILE}
    	if [ $? -eq 0 ] ; then
    		echo "ACPI tools successful instaled"
    	else
    		echo "An unknown error occured, please send a report"
    		exit 1
    	fi
    fi
fi
eval ${EX1T}
} 

deps()	#Check dependencies
{
for i in `seq 1 3`
do
	if command -v ${DP[i]} > /dev/null 2>&1 ; then >> ${LOG_FILE}
		echo "${DP[i]} found!" >> ${LOG_FILE}
	else
		echo "${DP[i]} not found, installing package using package manager"
    	eval sudo ${PACMAN} ${DP[i]} >> ${LOG_FILE}
    	if [ $? -eq 0 ] ; then
    		echo "${DP[i]} successful instaled"
    	else
    		echo "An unknown error occured, please send a report"
    		exit 1
    	fi
	fi
done
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
	if command -v iasl > /dev/null 2>&1 ; then >> ${LOG_FILE}
		DP2="iasl" >> ${LOG_FILE}
		mkdir -p "$HOME/$DEST_PATH/DAT/"
		echo "Geting tables."
		ls /sys/firmware/acpi/tables/ | grep -vwE "data|dynamic" > "$HOME/$DEST_PATH/ACPI_Table_List.txt" >> ${LOG_FILE}
		cd "$HOME/$DEST_PATH/"
		for i in $(cat ACPI_Table_List.txt) ; do
    		sudo cat "/sys/firmware/acpi/tables/$i" > "$HOME/$DEST_PATH/DAT/$i.dat" >> ${LOG_FILE}
    	done
    	echo "Decompiling tables."
    	cd "$HOME/$DEST_PATH/DAT/"
    	for i in *
    	do
      		eval iasl -d "${i}" >> ${LOG_FILE}
    	done
    	echo "Cleaning up."
    	mkdir -p "$HOME/$DEST_PATH/DSL/"
    	mv *.dsl "$HOME/$DEST_PATH/DSL/"
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
if [[ $APFSANS = YES ]] || [[ $APFSANS = yes ]] ; then
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

CHKDEPS()	#Check APFS-Fuse dependencies
{
for i in `seq 6 10`
do
	if pacman -Qk ${DP[i]} > /dev/null 2>&1 ; then >> ${LOG_FILE}
		echo "${DP[i]} found!" >> ${LOG_FILE}
	else
		echo "${DP[i]} not found, installing package using package manager"
	    eval sudo ${PACMAN} ${DP[i]} >> ${LOG_FILE}
	    if [ $? -eq 0 ] ; then
	    	echo "${DP[i]} successful instaled"
	    else
	    	echo "An unknown error occured, please send a report"
	    	exit 1
	    fi
	fi
done
eval ${EX1T}
} 

GITCLONE()	#Clone APFS-Fuse repository
{
eval git clone https://github.com/sgan81/apfs-fuse.git ${HOME}/${DEST_PATH}/apfs-fuse/ >> ${LOG_FILE}
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
} 

APFSMAKE()	#Compile APFS-Fuse driver
{
eval cd ${HOME}/${DEST_PATH}/apfs-fuse
mkdir build >> ${LOG_FILE}
cd build >> ${LOG_FILE}
cmake .. >> ${LOG_FILE}
make >> ${LOG_FILE}
if [ $? -eq 0 ] ; then
   	echo "compilation successful"
else
   	echo "An unknown error occured, please send a report"
    exit 1
fi
eval ${EX1T}
} 

MVDRIVER() #Move APFS-Fuse driver
{
clear
echo "Now, we must move the drivers to your working PATH, please, provide
your password if needed"

eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/bin/* /usr/local/bin/ >> ${LOG_FILE}
eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/lib/* /usr/lib/ >> ${LOG_FILE}
eval ${EX1T}
} 

clover_ask()	#Install Clover to disk
{
clear
echo "Do you want to install Clover Boot Loader to a disk?
You can install it to an USB Stick, for example.

Please write YES or NO"
read CLOVERANS
if [ $CLOVERANS == YES ] || [ $CLOVERANS == yes ] ; then
	cl_uefi_bios
else
    echo "Clover Bootloader will not be installed."
    echo
	echo
	echo
fi
CLVDEPS
eval ${EX1T}
} 

CLVDEPS()	#Check Clover dependencies
{
for i in `seq 11 16`
do 
	if ( command -v ${DP[i]} > /dev/null 2>&1 ) || ( pacman -Qi ${DP[i]} > /dev/null 2>&1 ) ; then >> ${LOG_FILE}
		echo "${DP[i]} found!" >> ${LOG_FILE}
	else
		echo "${DP[i]} not found, installing package using package manager"
    	eval sudo ${PACMAN} ${DP[i]} >> ${LOG_FILE}
    	if [ $? -eq 0 ] ; then
    		echo "${DP[i]} successful instaled"
    	else
    		eval sudo yay -Syyu --noconfirm ${DP[i]} >> ${LOG_FILE}
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
} 

LISTDISKS()	#Listing available disks
{
THEDISKLIST="$(lsblk -f)"
clear
echo "$THEDISKLIST"
echo
echo "Listed above, you'll find all available disks at your system.
It is strongly recommended that you install Clover to a USB Stick intead of at an internal volume.

Please, look at the list above and type in the target disk, for example, 'sdh'"
read CLOVERDANS
if [[ ${CLOVERDANS} != "^ " ]] ; then
	DISK="${CLOVERDANS}"
	echo "Now, please type in the target partition, for example, 'sdh1'"
	read CLOVERDANS22
	if [[ $CLOVERDANS22 != "^ " ]] ; then
		PARTITION="${CLOVERDANS22}"
	else
		echo "An unknown error occured, please send a report"
    	exit 1
    fi
else
	echo "An unknown error occured, please send a report"
    exit 1
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
	CLVDEPS
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
echo "You are about to install Clover for UEFI boot at /dev/${PARTITION}.
Do you want to proceed?.

Please write YES or NO"
read UEFIANS
if [[ $UEFIANS = YES ]] || [[ $UEFIANS = yes ]] ; then
    eval mkdir ${HOME}/${DEST_PATH}/Clover/
	eval cd ${HOME}/${DEST_PATH}/Clover/ 
    wget https://sourceforge.net/projects/cloverefiboot/files/latest/download >> ${LOG_FILE}
    eval mv download Clover.zip
    7z x Clover.zip >> ${LOG_FILE}
	eval mkdir ${HOME}/${DEST_PATH}/Clover/Clover.pkg
	eval mv Clover_*.pkg ${HOME}/${DEST_PATH}/Clover/Clover.pkg/
	eval cd ${HOME}/${DEST_PATH}/Clover/Clover.pkg/
	xar -xzf Clover_*.pkg >> ${LOG_FILE}
	rm -rf Clover_*.pkg
	for i in ${HOME}/${DEST_PATH}/Clover/Clover.pkg/*
	do
    	eval cd ${i}
        cat Payload | gzip -c -d | cpio -i >> ${LOG_FILE}
        rm -rf Bom PackageInfo Payload Scripts
	done
else
	echo "OK, exiting"
    exit 0

fi
eval ${EX1T}
}  >> ${LOG_FILE}

CLUEFI()	#Installing Clover for UEFI boot
{
eval sudo mkdir /run/media/${USER}/CloverEFI/ 
eval sudo mount -t msdos /dev/${PARTITION} /run/media/${USER}/CloverEFI/  
eval sudo cp -rfp ${HOME}/${DEST_PATH}/Clover/Clover.pkg/EFIFolder.pkg/EFI/ /run/media/${USER}/CloverEFI/ 
eval sudo mkdir /run/media/${USER}/CloverEFI/EFI/CLOVER/drivers64UEFI/
DRVLIST="$(ls ${HOME}/${DEST_PATH}/Clover/Clover.pkg/ | grep "64.UEFI")"
eval echo ${DRVLIST} >> ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI.txt
eval mkdir ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI >>
for i in ${HOME}/${DEST_PATH}/Clover/Clover.pkg/*
do
   	eval cd ${i}    
    eval cp -rfp *.efi ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/
done
eval cd ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/
eval sudo cp -rfp DataHubDxe-64.efi Fat-64.efi FSInject-64.efi HFSPlus-64.efi /run/media/${USER}/CloverEFI/EFI/CLOVER/drivers64UEFI/ 
eval sudo cp -rfp OsxFatBinaryDrv-64.efi PartitionDxe-64.efi VBoxExt4.efi /run/media/${USER}/CloverEFI/EFI/CLOVER/drivers64UEFI/
clear
echo "Only a basic set of EFI drivers were installed, you can find additional divers at the temp_folder
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
}  >> ${LOG_FILE}

cloudconfig()	#Open Clover Cloud Configurator
{
echo
echo "Do you want to create a new config.plist?
This option will launch Clover Cloud Configurator web app.

Please write YES or NO."
read CLCLOU
if [[ $CLCLOU = YES ]] || [[ $CLCLOU = yes ]] ; then
	xdg-open http://cloudclovereditor.altervista.org/cce/index.php
fi
eval ${EX1T}
addkexts
}

addkexts()
{
echo
echo "Do you want to add a basic set of kexts?
This option will add Lilu.kext, VirtualSMC.kext and LiluFriend.kext.

Please write YES or NO."
read KEXTANS
if [[ $KEXTANS = YES ]] || [[ $KEXTANS = yes ]] ; then
	eval cp -rf ${DIR}/kexts/LiluFriend.kext/ /run/media/${USER}/CloverEFI/EFI/CLOVER/kexts/Other/
	eval cp -rf ${DIR}/kexts/Lilu.kext/ /run/media/${USER}/CloverEFI/EFI/CLOVER/kexts/Other/
	eval cp -rf ${DIR}/kexts/VirtualSMC.kext/ /run/media/${USER}/CloverEFI/EFI/CLOVER/kexts/Other/
	echo "Kexts added!"
else
	echo "Kexts will not be added."
fi
eval ${EX1T}
UNMPART
}  >> ${LOG_FILE}

UNMPART()	#Unmounting partition
{
echo
echo "Do you want to unmount $PARTION ?

Please write YES or NO."
read EXITANS
if [[ $EXITANS = YES ]] || [[ $EXITANS = yes ]] ; then
	eval sudo umount /run/media/${USER}/CloverEFI/ >> ${LOG_FILE}
	eval sudo rm -rf /run/media/${USER}/CloverEFI/ >> ${LOG_FILE}
else
	echo "Clover Boot Loader was successfully installed! Exiting."
fi
} 

runall()	#Run all tasks
{
get_os
vent
hello
verifydeps
system_dump
acpi_tool
acpidump 
dev_tool
applefs
clover_ask
}

$OPTA
$OPTC
$OPTD
$OPTE
