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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

TSPACE="5"

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
FSPACE=""
OSTYPE=""
UNMLIST=""

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
		GETOS="get_os"
		GETBOOT="get_boot_device"
		RVENT="vent"
        ;;
    :)  OPTD="$OPTARG"
		EX1T="exit 0"
		GETOS="get_os"
		GETBOOT="get_boot_device"
		RVENT="vent"
        ;;
    l)  OPTE="runall"
        ;;
    i)  OPTI="domacosinstall"
        ;;
    esac
done

printf '\e[8;35;141t'

echo -e '\033]2;'$DEST_PATH'\007'

${VERBOSE}

eval mkdir -p "$HOME/$DEST_PATH"

LOG_FILE="$HOME/$DEST_PATH/logfile.log"

exec > >(tee $LOG_FILE)

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
PKM[1]="pacman -Sy --noconfirm" #Arch / Manjaro
PKM[2]="pacman -Sy --noconfirm" #Arch / Manjaro
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
DP[0]="mtools"
DP[1]="dosfstools"
DP[2]="awk"
DP[3]="pv"
DP[4]="tree"
DP[5]="inxi"
DP[6]="git"
#Arch
DP[7]="base-devel"
DP[8]="devtools"
DP[9]="cmake"
DP[10]="fuse-common"
DP[11]="icu"
DP[12]="zlib"
DP[13]="lib32-zlib"
DP[14]="ncurses"
DP[15]="acpica"
DP[16]="bzip2"
DP[17]="yay"
#Clover
DP[18]="7z"
DP[19]="curl"
DP[20]="gzip"
DP[21]="libxml2"
DP[22]="xarchiver"
DP[23]="xar"
DP[24]="hfsprogs"
DP[25]="cpio"
DP[26]="progress"
DP[27]="dmg2img"
DP[28]="hfsutils"
#Debian
DP[29]="fuse-emulator-common"
DP[30]="icu-devtools"
DP[31]="zlib1g-dev"
DP[32]="zlib1g"
DP[33]="ncurses-base"
DP[34]="ncurses-dev"
DP[35]="acpica-tools"
DP[36]="build-essential"
DP[37]="libxml2-dev"
DP[38]="libssl1.0-dev"
DP[39]="libbz2-dev"
DP[40]="libfuse-dev"
DP[41]="p7zip-full"

IFS=$'\n'

do_spin()
{
PID=$!
i=1
sp="/-\|"
echo -n "Copying, please wait... " ""
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done
}

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
}

get_boot_device()
{
BOOTDEVICE="$( df -H -P \/ | tail -n 1 | awk "/.*/ { print \$1 }" | sed "s/[0-9]//g" )" 
case $BOOTDEVICE in
	"" )
		BOOTDEVICE="$( mount | grep "boot" | awk "{print \$1}" )" 
		;;  
esac
echo
echo "Current boot device is $BOOTDEVICE ."
}

vent()	#Exit if no known OS
{
FSPACE="$( df -H -P \/ | tail -n 1 | awk "{print \$4}" | sed "s/[a-z A-Z]//g" )"		#Check free space
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
}

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
}

verifydeps()	#Verify and install dependencies
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
clear
echo "Before we start, we must check some dependencies and install it, if needed.
You can check later, all that is done by this script at the ${LOG_FILE}"
sleep 5
deps
CHKDEPS
CLVDEPS
#acpi_tool
eval ${EX1T}
}

deps()	#Check dependencies
{
for i in `seq 0 6`
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
}

CHKDEPS()	#Check dependencies by OS
{
echo "${OSTYPE}" | while IFS= read -r line ; do
case $line in
	Arch )	 echo "$OSTYPE"		 
	for i in `seq 7 17`
	do
		if pacman -Qk ${DP[i]} > /dev/null 2>&1 || pacman -Qs ${DP[i]} > /dev/null 2>&1 ; then
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
	break	
	;;
	Manjaro	)	 echo "$OSTYPE"		 
	for i in `seq 7 17`
	do
		if pacman -Qk ${DP[i]} > /dev/null 2>&1 || pacman -Qs ${DP[i]} > /dev/null 2>&1 ; then
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
	break	
	;;
	Debian ) 	echo "$OSTYPE"
	for i in `seq 29 41`
	do
		if dpkg -l | grep -i ${DP[i]} > /dev/null 2>&1 ; then
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
	build_xar
	build_cmake
	break
	;;
	Ubuntu ) 	echo "$OSTYPE"
	for i in `seq 29 41`
	do
		if dpkg -l | grep -i ${DP[i]} > /dev/null 2>&1 ; then
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
	build_xar
	build_cmake
	break
	;;
	Mint ) 	echo "$OSTYPE"
	for i in `seq 29 41`
	do
		if dpkg -l | grep -i ${DP[i]} > /dev/null 2>&1 ; then
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
	build_xar
	build_cmake
	break
	;;
esac
done
}

build_xar()		#Building xar for Deb
{
if ( command -v xar > /dev/null 2>&1 ) ; then  
	echo "xar found!"
else
	echo 
	echo
	echo "Building xar archiver for .pkg extraction"
	echo
	echo
	eval mkdir ${HOME}/${DEST_PATH}/xar
	eval cd ${HOME}/${DEST_PATH}/xar/
	wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/xar/xar-1.5.2.tar.gz
	tar -zxvf xar-1.5.2.tar.gz
	eval cd ${HOME}/${DEST_PATH}/xar/xar-1.5.2/
	./configure
	make
	sudo make install
	if [ $? == 0 ] ; then
		echo "xar archiver built successfuly!"
	else	
		echo "There were errors building xar.
	
It's impossible to create a macOS installer without this tool, please, send a report."
		read -p "Press enter to continue"
	fi
fi
}

build_cmake()		#Building Cmake for Deb
{
if ( command -v cmake > /dev/null 2>&1 ) ; then  
	echo "cmake found!"
else
	echo 
	echo
	echo "Building cmake builder."
	echo
	echo
	eval mkdir ${HOME}/${DEST_PATH}/cmake
	eval cd ${HOME}/${DEST_PATH}/cmake/
	wget https://cmake.org/files/v3.13/cmake-3.13.0-rc2.tar.gz
	tar -zxvf cmake-3.13.0-rc2.tar.gz
	eval cd ${HOME}/${DEST_PATH}/cmake/cmake-3.13.0-rc2/
	./configure
	make
	sudo make install
	if [ $? == 0 ] ; then
		echo "cmake builder built successfuly!"
	else	
		echo "There were errors building cmake.
	
It's impossible to install APFS driver without this tool, please, send a report."
		read -p "Press enter to continue"
	fi
fi
}

CLVDEPS()	#Check Clover dependencies
{
for i in `seq 18 28`
do 
	if ( command -v ${DP[i]} > /dev/null 2>&1 ) || ( pacman -Qi ${DP[i]} > /dev/null 2>&1 ) || ( dpkg -l | grep -i ${DP[i]} > /dev/null 2>&1 ) ; then  
		echo "${DP[i]} found!"    
	else
		echo "${DP[i]} not found, installing package using package manager"  
    	eval sudo ${PACMAN} ${DP[i]}  
    	if [ $? -eq 0 ] ; then
    		echo "${DP[i]} successful instaled"  
    	else
    		eval yay -Sy --noconfirm ${DP[i]}  
    		if [ $? -eq 0 ] ; then
    			echo "${DP[i]} successful instaled" 
    		else
    			echo "An unknown error occured, please send a report
${DP[i]}"				
    		fi
    	fi
	fi
done
} 

system_dump()	#Dumping system information
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to make a complete system dump?
It will get detailed information about your Hardware.

Please, write YES or NO"
read SISANS
if [[ $SISANS = YES ]] || [[ $SISANS = yes ]] ; then
	mkdir "$HOME/$DEST_PATH/Dumps"
	dmesg > "$HOME/$DEST_PATH/Dumps/dmesg.txt"
    sudo lscpu > "$HOME/$DEST_PATH/Dumps/CPU_Information.txt"
    inxi -Fx > "$HOME/$DEST_PATH/Dumps/System_Information.txt"
    lspci -nn -k >> "$HOME/$DEST_PATH/Dumps/System_Information.txt"
    sudo fdisk -l > "$HOME/$DEST_PATH/Dumps/Disk_Information.txt"
    sudo lshw -short > "$HOME/$DEST_PATH/Dumps/Hardware_Sumary.txt"
    tree -F /boot/efi/ > "$HOME/$DEST_PATH/Dumps/EFI_Info.txt"
    efivar -L > "$HOME/$DEST_PATH/Dumps/EFI_Var.txt"
    sudo dmidecode -t 0 > "$HOME/$DEST_PATH/Dumps/BIOS_Information.txt"
    sudo dmidecode -t 20 > "$HOME/$DEST_PATH/Dumps/Memory_Information.txt"
    audiocodeclist="$( ls /proc/asound/ | grep card )"
    for i in $audiocodeclist ; do
		eval sudo cat /proc/asound/$i || sudo cat /proc/asound/$i/codec\#0 | tee $HOME/$DEST_PATH/Dumps/Audio_Codec_$i.txt 
    done
    itemp=""
    for i in $( sudo find \/sys\/. | grep card | grep -i edid ) ; do
		itemp="$( echo $i | sed "s@:@_@g; s@/@_@g; s@\.@_@g" | sed -n -e "s@^.*drm@@p" )"
		eval sudo hexdump -C $i | tee $HOME/$DEST_PATH/Dumps/$itemp.txt
		eval cat $HOME/$DEST_PATH/Dumps/$itemp.txt | grep .
		if [ $? -ne 0 ] ; then
			eval sudo rm -rf $HOME/$DEST_PATH/Dumps/$itemp.txt
		fi 
    done
fi
eval ${EX1T}
} 

acpidump()	#Dumping ACPI Table
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to dump your ACPI table (DSDT, SSDT, etc..)?
You can use them to make improvements at your OS.

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
} 

applefs()	#Check dependencies, compile and install APFS-Fuse drivers
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to install OpenSource APFS-Fuse driver?
It can provide ReadOnly access to APFS formatted Volumes and DMGs.

Please write YES or NO"
read APFSANS
if [[ $APFSANS = YES ]] || [[ $APFSANS = yes ]] || [[ $APFSANS = Yes ]] ; then
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
}

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
}

MVDRIVER() #Move APFS-Fuse driver
{
clear
echo "Now, we must move the drivers to your working PATH, please, provide
your password if needed"

eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/bin/* /usr/local/bin/  
eval sudo cp ${HOME}/${DEST_PATH}/apfs-fuse/build/lib/* /usr/lib/  
eval ${EX1T}
}

mount_apfs_volume()
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to mount an APFS volume?.

Please write YES or NO"
read APFSMOUNTANS
if [[ $APFSMOUNTANS = YES ]] || [[ $APFSMOUNTANS = yes ]] || [[ $APFSMOUNTANS = Yes ]] ; then
	eval sudo fdisk -l | awk "{print \$1}" | grep "/dev/[a-z][a-z][a-z][0-9]" | sed "s@:@@g" >> ${HOME}/${DEST_PATH}/Block_Device_List.txt
	cd "$HOME/$DEST_PATH/"
	echo -e ' '
	for i in $(cat Block_Device_List.txt) ; do
    	sudo file -Ls $i | grep APFS 
    done
    echo
    echo
    while true; do
	printf '\e[?5h'  # Turn on reverse video
	sleep 0.05
	printf '\e[?5l'  # Turn on normal video
	echo "Now, please type in the target device, for example, 'sdh3'
	
Current boot device is $BOOTDEVICE."
	read -n 4 APFSDISKMOUNT
	case $APFSDISKMOUNT in
		" "" "" "" ") echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue	;;

		[1-9][1-9][1-9][1-9])	echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue		;;

		[a-z][a-z][a-z][1-9])	eval cat ${HOME}/${DEST_PATH}/Block_Device_List.txt | grep "$APFSDISKMOUNT" > /dev/null
							if [ $? != 1 ] ; then 
								echo "   <--Valid input, continuing."
								echo
								echo
								echo "Mounting $APFSDISKMOUNT as APFS volume..."
								sleep 2
								eval mkdir ${HOME}/${DEST_PATH}/APFS_Volume
								eval sudo apfs-fuse "/dev/$APFSDISKMOUNT" "${HOME}/${DEST_PATH}/APFS_Volume/"
								sleep 2
								echo "APFS volume mounted..."
								echo
								eval xdg-open ${HOME}/${DEST_PATH}/APFS_Volume/ </dev/null &>/dev/null &
								echo
								read -p "Press enter to continue"
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
fi
eval ${EX1T}
}

dousbstick()	#Prepare a USB Stick to be target of Clover and macOS installer
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
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
else
    echo "The bootable USB Stick will not be created."
    echo
	echo
fi
eval ${EX1T}
} 

clover_ask()	#Install Clover to disk
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
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
fi
eval ${EX1T}
} 

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
								echo
								echo
								echo "Are you sure? Please check carefully and press ENTER to continue or CTRL+C to abort!"
								read -p "Press enter to continue"
								echo
								DISK="$LISTDISKANS"
								UNMLIST="$(mount | grep "$DISK[1-9]" | awk "{print \$1}")"
								for i in $UNMLIST
								do
									eval udisksctl unmount -b "${i}" </dev/null &>/dev/null &
								done
								sleep 2
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
} 

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
} 

EXTRACL()	#Download and extract Clover package
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "We'll now download and prepare all necessary files."
echo
echo
echo
read -p "Press enter to continue"
eval mkdir ${HOME}/${DEST_PATH}/Clover/ 
eval cd ${HOME}/${DEST_PATH}/Clover/ 
wget https://sourceforge.net/projects/cloverefiboot/files/latest/download 
eval mv download Clover.zip 
eval cd ${HOME}/${DEST_PATH}/Clover/
eval 7z x Clover.zip 
eval mkdir ${HOME}/${DEST_PATH}/Clover/Clover.pkg 
eval cd ${HOME}/${DEST_PATH}/Clover/ 
eval mv Clover_*.pkg ${HOME}/${DEST_PATH}/Clover/Clover.pkg/
sleep 1
eval cd ${HOME}/${DEST_PATH}/Clover/Clover.pkg/ 
xar -xf Clover_*.pkg 
eval rm -rf ${HOME}/${DEST_PATH}/Clover/Clover.pkg/Clover_*.pkg 
eval rm -rf ${HOME}/${DEST_PATH}/Clover/Clover.pkg/Distribution 
for i in ${HOME}/${DEST_PATH}/Clover/Clover.pkg/*
do
   	eval cd ${i}
   	eval cat "Payload" | eval gzip -c -d -q | cpio -i 
   	rm -rf Bom PackageInfo Payload Scripts 
done
} 

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
cloudconfig
} 

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
addkexts
} 

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
	eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/kexts/LiluFriend.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ 
	eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/kexts/Lilu.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ 
	eval sudo cp -R ${HOME}/${DEST_PATH}/Clover/kexts/VirtualSMC.kext/ ${HOME}/${DEST_PATH}/Clover/EFI/CLOVER/kexts/Other/ 
	echo "Kexts added!"
	clvfinish
else
	echo "Kexts will not be added."
fi
} 

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
#eval LOOP="$( losetup -l | grep "System.img" | awk "{print \$1}" )"
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
}

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
}

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
								echo
								echo
								echo "Are you sure? Please check carefully and press ENTER to continue or CTRL+C to abort!"
								read -p "Press enter to continue"
								echo
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
eval mount | grep "${DISKX}" | awk "{print \$3}" | sed "s/ /\\\ /g" > ${HOME}/${DEST_PATH}/Clover/target.txt
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
UNMPART
} 

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
} 

domacosinstall() #macOS installer
{
eval ${GETOS}
eval ${GETBOOT}
eval ${RVENT}
FSPACE="$( df -H -P \/ | tail -n 1 | awk "{print \$4}" | sed "s/[a-z A-Z]//g" )"
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Do you want to create a macOS Mojave installer?
This option will download needed files and create a macOS installer.

This step may take some time to complete, so please, be patient...

Please write YES or NO."
read MACOSANS
if [[ $MACOSANS = YES ]] || [[ $MACOSANS = yes ]] || [[ $MACOSANS = Yes ]] ; then 
	if [[ $(echo "$FSPACE > $TSPACE" | bc) -eq 1 ]] ; then
		echo
		echo
		echo "Needed space ${TSPACE}Gb , available space ${FSPACE}Gb , OK continuing..."
		sleep 2
		copybasesystem
	else
		echo "We must have at least ${TSPACE}Gb of free space to complete this task.

Currently you have only ${FSPACE}Gb available, sorry, we are working on a way to bypass this limitation."
		exit 0
	fi
else
	echo "The installer will not be created."
	exit 0
fi
eval ${EX1T}
} 

changeinstallinfo() #Make necessary modifications to InstallInfo.plist
{
eval sudo sed -i -e "'s/<key>chunklistURL<\/key>//g'" "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist" 
sleep 1
eval sudo sed -i -e "'s/<string>InstallESDDmg.chunklist<\/string>//g'" "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist"
sleep 1
eval sudo sed -i -e "'s/<key>chunklistid\<\/key>//g'" "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist"
sleep 1
eval sudo sed -i -e "'s/<string>com.apple.chunklist.InstallESDDmg<\/string>//g'" "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist" 
sleep 1
eval sudo sed -i -e "'s/<string>InstallESDDmg.pkg<\/string>/<string>InstallESD.dmg<\/string>/g'" "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist" 
sleep 1
eval sudo sed -i -e "'s/<string>com.apple.pkg.InstallESDDmg<\/string>/<string>com.apple.dmg.InstallESD<\/string>/g'" "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallInfo.plist" 
sleep 1
}

dobasesystem() #Creates macOS installer
{
eval cd "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/"
eval sudo wget http://swcdn.apple.com/content/downloads/07/20/091-95774/awldiototubemmsbocipx0ic9lj2kcu0pt/BaseSystem.chunklist 
eval sudo wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/InstallInfo.plist 
eval sudo wget http://swcdn.apple.com/content/downloads/00/21/091-76348/67qi57g3fqpytl06cofi6bn2uuughsq2uo/InstallESDDmg.pkg 
eval sudo wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/AppleDiagnostics.dmg 
eval sudo wget http://swcdn.apple.com/content/downloads/29/03/091-94326/45lbgwa82gbgt7zbgeqlaurw2t9zxl8ku7/AppleDiagnostics.chunklist 
sleep 1
eval sudo mv "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallESDDmg.pkg" "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/InstallESD.dmg"
echo
echo
echo "Aditional downloads finished!"
echo
echo
changeinstallinfo
echo
echo
echo "Installer successful created!
		
Unplug and replug your USB Stick in order to view the files.

Thank you for using Linux4macOS tool!"
}

copybasesystem()	#Converting image to partition
{
clear
printf '\e[?5h'  # Turn on reverse video
sleep 0.05
printf '\e[?5l'  # Turn on normal video
echo "Before we proceed, we must know where to place the files.
Choose the target partition at your USB Stick, for the macOS installer

The partition must have at least 7Gb free"
echo
echo
echo
read -p "Press enter to continue"
echo
echo
eval mkdir ${HOME}/${DEST_PATH}/macOS
eval lsblk -o name,rm,hotplug,mountpoint | tee ${HOME}/${DEST_PATH}/macOS/Available_Disks_List.txt 
eval cat ${HOME}/${DEST_PATH}/macOS/Available_Disks_List.txt
echo
while true; do
	printf '\e[?5h'  # Turn on reverse video
	sleep 0.05
	printf '\e[?5l'  # Turn on normal video
	echo "Now, please type in the target device, for example, 'sdh2'
Be careful, the disk will be formatted as HFS+ and all data on it will be lost!

Current boot device is $BOOTDEVICE."
	read -n 4 CPBASEANS22
	case $CPBASEANS22 in
		" "" "" "" ") echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue	;;

		[1-9][1-9][1-9][1-9])	echo "   <--Invalid input! Try again."
			 echo
			 echo
			 continue		;;

		[a-z][a-z][a-z][1-9])	eval cat ${HOME}/${DEST_PATH}/macOS/Available_Disks_List.txt | grep "$CPBASEANS22" > /dev/null
							if [ $? != 1 ] ; then
								echo "   <--Valid input, continuing."
								echo
								echo
								echo "Are you sure? Please check carefully and press ENTER to continue or CTRL+C to abort!"
								read -p "Press enter to continue"
								echo
								DISK="${CPBASEANS22}"  
								UNMLIST="$(mount | grep "$DISK" | awk "{print \$1}")"
								for i in $UNMLIST
								do
									eval udisksctl unmount -b "${i}" </dev/null &>/dev/null &
								done
								eval cd ${HOME}/${DEST_PATH}/macOS/
								wget http://swcdn.apple.com/content/downloads/49/44/041-08708/vtip954dc6zbkpdv16iw18jmilcqdt8uot/BaseSystem.dmg
								sleep 2
								domacosimg
								eval cd ${HOME}/${DEST_PATH}/macOS/
								sleep 2
								sudo dmg2img -v -i BaseSystem.dmg -p 4 -o OS\ X\ Base\ System.img 
								sleep 2
								eval sudo udisksctl loop-setup -f "${HOME}/${DEST_PATH}/macOS/OS\ X\ Base\ System.img" 
								eval LOOP="$( losetup -l | grep "System.img" | awk "{print \$1}" )" 
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
								eval mount | grep "/dev/${DISK}" | awk "{print \$3, \$4, \$5, \$6}" | sed "s/ /\\\ /g" > ${HOME}/${DEST_PATH}/macOS/target.txt
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
								eval mount | grep "${LOOP}" | awk "{print \$3, \$4, \$5, \$6}" | sed "s/ /\\\ /g" > ${HOME}/${DEST_PATH}/macOS/loopdir.txt
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
								eval sudo cp -R "${LOODIR}"/* "${TARGET}"/ & do_spin
								sleep 3
								eval udisksctl unmount -b "${LOOP}" 
								eval udisksctl loop-delete -b "${LOOP}" 
								sleep 1
								eval sudo mkdir "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/" 
								eval sudo mv ${HOME}/${DEST_PATH}/macOS/BaseSystem.dmg "${TARGET}/Install\ macOS\ Mojave.app/Contents/SharedSupport/BaseSystem.dmg" & do_spin
								dobasesystem
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
} 

runall()	#Run all tasks -l
{
hello
verifydeps
system_dump
acpidump 
applefs
mount_apfs_volume
dousbstick
clover_ask
domacosinstall
echo
eval xdg-open ${HOME}/${DEST_PATH}/ </dev/null &>/dev/null &
}

$OPTA
$OPTC
$OPTD
$OPTE
$OPTI
