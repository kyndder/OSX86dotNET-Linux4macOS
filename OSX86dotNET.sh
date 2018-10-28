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
DISKX=""
TARGET=""
THEDISKLIST=""
LOOP=""
BOOTDEVICE=""

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

printf '\e[8;35;141t'

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
DP[18]="hfsprogs"
DP[19]="cpio"

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
} #>&2>&1 | tee $LOG_FILE

get_boot_device()
{
BOOTDEVICE="$( df -P \/ | tail -n 1 | gawk "/.*/ { print \$1 }" | sed "s/[0-9]//g" )"
case $BOOTDEVICE in
	"" )
		BOOTDEVICE="$( mount | grep "boot" | gawk "{print \$1}" )"
		;;  
esac
echo
echo "Current boot device is $BOOTDEVICE ."
}

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
	printf '\e[?5h'  # Turn on reverse video
	sleep 0.05
	printf '\e[?5l'  # Turn on normal video
    echo "There are some files at the $DEST_PATH folder.
Do you want to cleanup or keep it?

Please press C for clean or K to keep."
	read VENTANS
	if [[ $VENTANS = C ]] || [[ $VENTANS = c ]] ; then
		eval sudo rm -rf ${HOME}/${DEST_PATH}/*
	fi
fi
} #>&2>&1 | tee $LOG_FILE

hello() #Hello!
{
clear
echo "Thank you for using $DEST_PATH Linux4macOS tool!
In order to provide you a better experience, we need to get some information
about the OS, to know if it satisfies basic dependencies for this tool. 

Note that if you are running this script from a Live media, a complete system upgrade
will be performed and it may take a while to complete at first run, please, be patient.

Do you want to proceed? Please, write YES or NO"
read WELCANS
if [[ $WELCANS = YES ]] || [[ $WELCANS = yes ]] || [[ $WELCANS = Yes ]] ; then
	get_os
	get_boot_device
	vent
else
	exit 0
fi
} #>&2>&1 | tee $LOG_FILE

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
} #>&2>&1 | tee $LOG_FILE

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
} #>&2>&1 | tee $LOG_FILE

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
} #>&2>&1 | tee $LOG_FILE

CLVDEPS()	#Check Clover dependencies
{
for i in `seq 11 19`
do 
	if ( command -v ${DP[i]} > /dev/null 2>&1 ) || ( pacman -Qi ${DP[i]} > /dev/null 2>&1 ) ; then  
		echo "${DP[i]} found!"    
	else
		echo "${DP[i]} not found, installing package using package manager"  
    	eval sudo ${PACMAN} ${DP[i]}  
    	if [ $? -eq 0 ] ; then
    		echo "${DP[i]} successful instaled"  
    	else
    		eval yay -Syyu --noconfirm ${DP[i]}  
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
} #>&2>&1 | tee $LOG_FILE

system_dump()	#Dumping system information
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
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
} #>&2>&1 | tee $LOG_FILE

dev_tool()	#Check development tools
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to install development tools?
They are necessary to, for example, build packages.

Please write YES or NO"
read APFSANS
if [[ $APFSANS = YES ]] || [[ $APFSANS = yes ]] || [[ $APFSANS = Yes ]] ; then
	eval sudo ${PACMAN} ${DP[4]} ${DP[5]}
    echo "Developer tools successfully instaled"
else
    echo "Developer tools will not be installed."
    echo
	echo
	echo
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

acpi_tool()	#Check IASL
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to install ACPI tools?
They are necessary to retrieve and decompile ACPI table from your system.

Please write YES or NO"
read ACPIANS
if [[ $ACPIANS = YES ]] || [[ $ACPIANS = yes ]] || [[ $ACPIANS = Yes ]] ; then
	if command -v iasl > /dev/null 2>&1 ; then 
		DP2="iasl" 
		eval echo "${DP2} found! You already have ACPI tools installed at your system." 
		echo
		echo
	else
		DP2="acpica" 
		echo "ACPI tools not found, installing package using package manager" 
    	eval sudo ${PACMAN} $DP2 
    	if [ $? -eq 0 ] ; then
    		echo "ACPI tools successful instaled" 
    	else
    		echo "An unknown error occured, please send a report" 
    		exit 1
    	fi
    fi
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

acpidump()	#Dumping ACPI Table
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to dump your ACPI table (DSDT, SSDT, etc..)?
You can use them to make improvements at your OS.

ATTENTION! ACPI tools are needed in order to make dumps.

Please write YES or NO"
read ACPIANS
if [[ $ACPIANS = YES ]] || [[ $ACPIANS = yes ]] || [[ $ACPIANS = Yes ]] ; then
	if command -v iasl > /dev/null 2>&1 ; then 
		DP2="iasl" 
		mkdir -p "$HOME/$DEST_PATH/DAT/" 
		echo "Geting tables." 
		ls /sys/firmware/acpi/tables/ | grep -vwE "data|dynamic" > "$HOME/$DEST_PATH/ACPI_Table_List.txt" 
		cd "$HOME/$DEST_PATH/"
		for i in $(cat ACPI_Table_List.txt) ; do
    		sudo cat "/sys/firmware/acpi/tables/$i" > "$HOME/$DEST_PATH/DAT/$i.dat" 
    	done
    	echo "Decompiling tables." 
    	cd "$HOME/$DEST_PATH/DAT/"
    	for i in *
    	do
      		eval iasl -d "${i}" 
    	done
    	echo "Cleaning up." 
    	mkdir -p "$HOME/$DEST_PATH/DSL/" 
    	mv *.dsl "$HOME/$DEST_PATH/DSL/" 
    fi
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

applefs()	#Check dependencies, compile and install APFS-Fuse drivers
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
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
		sleep 2
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
} #>&2>&1 | tee $LOG_FILE

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
} #>&2>&1 | tee $LOG_FILE

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
} #>&2>&1 | tee $LOG_FILE

MVDRIVER() #Move APFS-Fuse driver
{
clear
echo "Now, we must move the drivers to your working PATH, please, provide
your password if needed"

eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/bin/* /usr/local/bin/  
eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/lib/* /usr/lib/  
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

dousbstick()	#Prepare a USB Stick to be target of Clover and macOS installer
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to create a bootable USB Stick?
This option will prepare a USB Stick by creating a GPT disk, containing 2 partitions,
one for Clover, formatted as FAT32 and another for macOS installer, formatted as HFS+. 

Current boot device is $BOOTDEVICE, don't use this device for this function.

Please write YES or NO"
read USBSTICK
if [ $USBSTICK == YES ] || [ $USBSTICK == yes ] || [ $USBSTICK == Yes ] ; then
	LISTEXTDISKS
	printf '\e[?5h'  # Turn on reverse video
	sleep 0.05
	printf '\e[?5l'  # Turn on normal video
	read -p "Press enter to continue"
else
    echo "The bootable USB Stick will not be created."
    echo
	echo
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

clover_ask()	#Install Clover to disk
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to install Clover Boot Loader to a USB Stick?

Please write YES or NO"
read CLOVERANS
if [ $CLOVERANS == YES ] || [ $CLOVERANS == yes ] || [ $CLOVERANS == Yes ] ; then
	cl_uefi_bios
else
    echo "Clover Bootloader will not be installed."
    echo
	echo
	exit 0
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

LISTEXTDISKS()	#Listing available disks
{
clear
echo "Before we proceed, please, make sure that only the target USB Stick is plugged in.
Remove any other removable media before continue, the disk will be completely ERASED."
echo
echo
echo
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
read -p "Press enter to continue"
echo
echo
lsblk -o name,rm,hotplug,mountpoint | awk -F" " ""\$3\=\=""1"""" | tee ${HOME}/${DEST_PATH}/USB_Stick_List.txt
echo
echo
while true; do
	printf '\e[?5h'  # Turn on reverse video
	sleep 0.05
	printf '\e[?5l'  # Turn on normal video
	echo "Now, please type in the target device, for example, 'sdh'
Current boot device is $BOOTDEVICE."
	read -n 3 LISTDISKANS
	case $LISTDISKANS in
		" "" "" ") echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue	;;

		[1-9][1-9][1-9])	echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue		;;

		[a-z][a-z][a-z])	eval cat ${HOME}/${DEST_PATH}/USB_Stick_List.txt | grep "$LISTDISKANS" > /dev/null
							if [ $? != 1 ] ; then 
								echo "   <--Valid input, continuing."
								DISK="$LISTDISKANS"
								echo
								echo "Target disk is /dev/$DISK"
								echo
								dofilesystem
							else
								echo "   <--Invalid input! Try again."
								echo
								echo
								continue	
							fi
							break
							;;
	esac
done
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

cl_uefi_bios()	#Choose between UEFI or Legacy BIOS
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to install Clover for UEFI or non-UEFI (Legacy BIOS) system?.

Please write UEFI or BIOS"
read CLANS
if [[ $CLANS = UEFI ]] || [[ $CLANS = uefi ]] ; then
	EXTRACL
	CLUEFI
else
    echo "Working on it, please, if you want to try UEFI run 'OSX86dotNET.sh -c'" #This will be Legacy BIOS section
    exit 0
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

EXTRACL()	#Download and extract Clover package
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "We'll now download and prepare all necessary files.
Do you want to proceed?.

Please write YES or NO"
read UEFIANS
if [[ $UEFIANS = YES ]] || [[ $UEFIANS = yes ]] || [[ $UEFIANS = Yes ]] ; then
    eval mkdir ${HOME}/${DEST_PATH}/Clover/ 
	eval cd ${HOME}/${DEST_PATH}/Clover/ 
    wget https://sourceforge.net/projects/cloverefiboot/files/latest/download
    eval mv download Clover.zip 
    eval cd ${HOME}/${DEST_PATH}/Clover/
    eval 7z x Clover.zip 
	eval mkdir ${HOME}/${DEST_PATH}/Clover/Clover.pkg
	eval cd ${HOME}/${DEST_PATH}/Clover/
	eval mv Clover_*.pkg ${HOME}/${DEST_PATH}/Clover/Clover.pkg/Clover_*.pkg 
	sleep 1
	eval cd ${HOME}/${DEST_PATH}/Clover/Clover.pkg/ 
	xar -xzf Clover_*.pkg
	eval rm -rf ${HOME}/${DEST_PATH}/Clover/Clover.pkg/Clover_*.pkg
	eval rm -rf ${HOME}/${DEST_PATH}/Clover/Clover.pkg/Distribution
	for i in ${HOME}/${DEST_PATH}/Clover/Clover.pkg/*
	do
    	eval cd ${i}
    	eval cat "Payload" | eval gzip -c -d -q | cpio -i
    	rm -rf Bom PackageInfo Payload Scripts
	done
else
	echo "OK, exiting"
    exit 0
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

CLUEFI()	#Installing Clover for UEFI boot
{
eval cp -R ${HOME}/${DEST_PATH}/Clover/Clover.pkg/EFIFolder.pkg/EFI/ ${HOME}/${DEST_PATH}/Clover/EFI/ 
DRVLIST="$(ls ${HOME}/${DEST_PATH}/Clover/Clover.pkg/ | grep "64.UEFI")" 
eval echo ${DRVLIST} >> ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI.txt 
eval mkdir ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI 
for i in ${HOME}/${DEST_PATH}/Clover/Clover.pkg/*
do
   	eval cd ${i}    
    eval cp -R *.efi ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/ 
done
eval sudo mkdir ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/ 
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/ApfsDriverLoader-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/DataHubDxe-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/Fat-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/FSInject-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/HFSPlus-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/OsxFatBinaryDrv-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/PartitionDxe-64.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/Drivers64-UEFI/VBoxExt4.efi ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/drivers64UEFI/
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Only a basic set of EFI drivers were installed, you can find additional divers at the folder
${HOME}/${DEST_PATH}/Clover/temp_folder/EFI/CLOVER/drivers64UEFI/

Do you want to view a list of available EFI drivers? Please write YES or NO."
read CLUEFIANS90
if [[ $CLUEFIANS90 = YES ]] || [[ $CLUEFIANS90 = yes ]] || [[ $CLUEFIANS90 = Yes ]] ; then
	for i in ${DRVLIST} ; do
		echo "$i"
	done
	echo
	echo
	echo
	read -p "Press enter to continue"
fi
eval ${EX1T}
cloudconfig
} #>&2>&1 | tee $LOG_FILE

cloudconfig()	#Open Clover Cloud Configurator
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to create a new config.plist?
This option will launch Clover Cloud Configurator web app.

PS: After create your config.plist, save it at the folder ${HOME}/${DEST_PATH}/Clover/EFI/.

Please write YES or NO."
read CLCLOU
if [[ $CLCLOU = YES ]] || [[ $CLCLOU = yes ]] || [[ $CLCLOU = Yes ]] ; then
	xdg-open http://cloudclovereditor.altervista.org/cce/index.php
	echo
	echo
	echo
	read -p "Press enter to continue"
fi
eval ${EX1T}
addkexts
} #>&2>&1 | tee $LOG_FILE

addkexts() #Adding basic kexts
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to add a basic set of kexts?
This option will add Lilu.kext, VirtualSMC.kext and LiluFriend.kext.

Please write YES or NO."
read KEXTANS
if [[ $KEXTANS = YES ]] || [[ $KEXTANS = yes ]] || [[ $KEXTANS = Yes ]] ; then
	eval cp -R ${DIR}/kexts/ ${HOME}/${DEST_PATH}/Clover/ 
	eval cd ${HOME}/${DEST_PATH}/Clover/kexts/
	7z x kexts.zip 
	eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/kexts/LiluFriend.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ | pv -cN
	eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/kexts/Lilu.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ | pv -cN
	eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/kexts/VirtualSMC.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ | pv -cN
	echo "Kexts added!"
	clvfinish
else
	echo "Kexts will not be added."
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

docloverimg() #Create EFI image file #Not in use
{
eval cd ${HOME}/${DEST_PATH}/Clover/
sudo dd if=/dev/zero of=EFI.img count=199 bs=1M status=progress
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << FDISK_CMDS  | eval sudo fdisk EFI.img 
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
sudo mkfs.fat -F 32 EFI.img -n EFI 
sleep 3
eval sudo mkdir /run/media/${USER}/CloverIMG/ 
eval sudo mount -t vfat -o loop EFI.img /run/media/${USER}/CloverIMG/ 
sleep 3
} #>&2>&1 | tee $LOG_FILE

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
} #>&2>&1 | tee $LOG_FILE

dofilesystem() #Formatting USB Stick for CLover and Installer
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
sudo mkfs.fat -F 32 /dev/${DISK}1 -n EFI 
sudo mkfs.hfsplus /dev/${DISK}2 -v macOS 
} #>&2>&1 | tee $LOG_FILE

clvfinish() #Writting Clover to EFI partition
{
clear
lsblk -o name,rm,hotplug,mountpoint | tee ${HOME}/${DEST_PATH}/Clover/Available_Disks_List.txt
echo
echo
while true; do
	printf '\e[?5h'  # Turn on reverse video
	sleep 0.05
	printf '\e[?5l'  # Turn on normal video
	echo "Now, please type in the target device for Clover's files, for example, 'sdh1'.
Be careful, the disk will be formatted as FAT32 and all data on it will be lost!

Current boot device is $BOOTDEVICE."
	read -n 4 CLLISTDISKANS
	case $CLLISTDISKANS in
		" "" "" "" ") echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue	;;

		[1-9][1-9][1-9][1-9])	echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue		;;

		[a-z][a-z][a-z][1-9])	eval cat ${HOME}/${DEST_PATH}/Clover/Available_Disks_List.txt | grep "$CLLISTDISKANS" > /dev/null
							if [ $? != 1 ] ; then 
								echo "   <--Valid input, continuing."
								DISKX="$CLLISTDISKANS"
								echo
								echo "Target disk is /dev/$DISKX"
								echo "Formating..."
								sudo mkfs.fat -F 32 /dev/${DISKX} -n EFI
							else
								echo "   <--Invalid input! Try again."
								echo
								echo
								continue	
							fi
							break
							;;
	esac
done
sleep 2
eval udisksctl mount -b "/dev/${DISKX}"
sleep1
eval mount | grep "${DISKX}" | gawk "{print \$3}" | sed "s/ /\\\ /g" > ${HOME}/${DEST_PATH}/Clover/target.txt
TARGET="$(cat ${HOME}/${DEST_PATH}/Clover/target.txt)"
if [ -z "$TARGET" ]
then
	echo "\$TARGET is empty"
	exit 1
else
	echo "Target partition OK continuing..."
	echo "${TARGET}"
fi
sleep 1
eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/EFI/ "${TARGET}"/ 
echo 
echo
echo "Finished copying files." 
eval ${EX1T}
UNMPART
} #>&2>&1 | tee $LOG_FILE

UNMPART()	#Unmounting partition
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to unmount ${DISKX} ?

Please write YES or NO."
read EXITANS
if [[ $EXITANS = YES ]] || [[ $EXITANS = yes ]] || [[ $EXITANS = Yes ]] ; then
	eval udisksctl unmount -b /dev/${DISKX} 
	echo "Clover Boot Loader was successfully installed!"
else
	echo "Clover Boot Loader was successfully installed!"
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

domacosinstall() #macOS installer
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to create a macOS Mojave installer?
This option will download needed files and create a macOS installer.

Please write YES or NO."
read MACOSANS
if [[ $MACOSANS = YES ]] || [[ $MACOSANS = yes ]] || [[ $MACOSANS = Yes ]] ; then
	eval mkdir ${HOME}/${DEST_PATH}/macOS/ 
	eval cd ${HOME}/${DEST_PATH}/macOS/
	wget http://swcdn.apple.com/content/downloads/49/44/041-08708/vtip954dc6zbkpdv16iw18jmilcqdt8uot/BaseSystem.dmg 
	wget http://swcdn.apple.com/content/downloads/07/20/091-95774/awldiototubemmsbocipx0ic9lj2kcu0pt/BaseSystem.chunklist 
	wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/InstallInfo.plist 
	wget http://swcdn.apple.com/content/downloads/00/21/091-76348/67qi57g3fqpytl06cofi6bn2uuughsq2uo/InstallESDDmg.pkg 
	wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/AppleDiagnostics.dmg 
	wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/AppleDiagnostics.chunklist 
	sleep 1
	mv ${HOME}/${DEST_PATH}/macOS/InstallESDDmg.pkg ${HOME}/${DEST_PATH}/macOS/InstallESD.dmg 
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
} #>&2>&1 | tee $LOG_FILE

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
} #>&2>&1 | tee $LOG_FILE

dobasesystem() #Creates macOS installer
{
eval sudo mkdir "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/"
eval sudo mv ${HOME}/${DEST_PATH}/macOS/BaseSystem.dmg "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/BaseSystem.dmg"
eval sudo mv ${HOME}/${DEST_PATH}/macOS/BaseSystem.chunklist "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/BaseSystem.chunklist"
eval sudo mv ${HOME}/${DEST_PATH}/macOS/InstallInfo.plist "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist"
eval sudo mv ${HOME}/${DEST_PATH}/macOS/InstallESD.dmg "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallESD.dmg"
eval sudo mv ${HOME}/${DEST_PATH}/macOS/AppleDiagnostics.dmg "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/AppleDiagnostics.dmg"
eval sudo mv ${HOME}/${DEST_PATH}/macOS/AppleDiagnostics.chunklist "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/AppleDiagnostics.chunklist"
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

copybasesystem()	#Converting image to partition
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Before we proceed, we must know where to place the files.
Choose the target partition at your USB Stick, for the macOS installer

The partition must have at least 7Gb free

Do you want to proceed? Please write YES or NO"
read CPBASEANS
if [[ $CPBASEANS = YES ]] || [[ $CPBASEANS = yes ]] || [[ $CPBASEANS = Yes ]] ; then
	eval lsblk -o name,rm,hotplug,mountpoint | tee ${HOME}/${DEST_PATH}/macOS/Available_Disks_List.txt 
	eval cat ${HOME}/${DEST_PATH}/macOS/Available_Disks_List.txt
	echo
	printf '\e[?5h'  # Turn on reverse video
	sleep 0.05
	printf '\e[?5l'  # Turn on normal video
	echo "Now, please type in the target device, for example, 'sdh2'
Be careful, the disk will be formatted as HFS+ and all data on it will be lost!

Current boot device is $BOOTDEVICE."
	read CPBASEANS22
	if [[ ${CPBASEANS22} != "^ " ]] ; then
		DISK="${CPBASEANS22}" 
		domacosimg
		eval cd ${HOME}/${DEST_PATH}/macOS/
		sudo dmg2img -v -i BaseSystem.dmg -p 4 -o OS\ X\ Base\ System.img 
		sleep 3
		eval sudo udisksctl loop-setup -f "${HOME}/${DEST_PATH}/macOS/OS\ X\ Base\ System.img" 
		eval LOOP="$( losetup -l | grep "System.img" | gawk "{print \$1}" )" 
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
		eval udisksctl mount -b "${LOOP}" 
		sleep 1
		eval sudo mkfs.hfsplus "/dev/${DISK}" -v "OS\ X\ Base\ System" 
		sleep 3
		eval udisksctl mount -b "/dev/${DISK}" 
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
		eval udisksctl unmount "${LOOP}" 
		eval udisksctl loop-delete -b "${LOOP}" 
		echo "Installer successful created!
		
Unplug and replug your USB Stick in order to view the files.

Thank you for using Linux4macOS tool!"
	else
		echo "An unknown error occured, please send a report"
    	exit 1
    fi
fi
eval ${EX1T}
} #>&2>&1 | tee $LOG_FILE

runall()	#Run all tasks -l
{
hello
verifydeps
system_dump
acpi_tool
acpidump 
dev_tool
applefs
dousbstick
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
