# OSX86dotNET-Linux4macOS
A tool to help fixing macOS from Linux

Linux4macOS, is a script to help users fix a macOS install from Linux.

This are the current features:

  - Creates a macOS installer.
  - Installs Clover Bootloader to disk for UEFI and Legacy boot.
  - Download and installs a Basic set of kexts (work in progress).
  - Install hfsprogs to access HFS and HFS+ formatted partitions.
  - Compile and Install APFS-Fuse to access APFS formatted partitions.
  - Installs basic developments tools.
  - Installs ACPI tools.
  - Extracts and decompile ACPI Tables.
  - Makes complete system dump.

Currently it has full capabities Manjaro and Ubuntu but, the script
was made with the intention of make it compatible to others distros.

You can download Manjaro Linux from here > https://manjaro.org/get-manjaro/
You can download Ubuntu Linux from here > https://www.ubuntu.com/download/desktop

The usage is simple, clone or download it, go to its directory and run;


            ./OSX86dotNET.sh


The available options are:

  - -a 				= Compile and install APFS-Fuse drivers
  - -c 				= Install Clover Bootloader to a disk
  - -d 				= Used as direct jump, needs extra argument.
  - -h 				= This help
  - -i 				= Create a macOS installer
  - -l 				= Run all tasks
  - -v 				= Verbose output"
 
Arguments are used for direct jump to a specific function and may be used 
as shown below;


            ./OSX86dotNET.sh -d ARGUMENT


The available arguments are:

  - system_dump			=Dump system information
  - acpidump			=Dump ACPI Table
  - applefs				=Compile and install APFS-Fuse drivers "same as -a"
  - clover_ask			=Install Clover to disk "same as -c"
  - dev_tool			=Check and install development tools"
 
This is a work in progress, so, suggestions are welcome.

The idea of this script is to create a complete environment, to fix
a macOS installation from a LiveCD, for example, or for those not so familiar
with Linux and its capabilities.

Thanks to;

pacapt team > https://github.com/icy/pacapt/blob/master/pacapt#L168

m13253's > https://github.com/m13253/clover-linux-installer

sgan81 > https://github.com/sgan81/apfs-fuse

Clover Team > https://sourceforge.net/projects/cloverefiboot/

Acidanthera Team > https://github.com/acidanthera

kylon > http://cloudclovereditor.altervista.org/cce/index.php

fusion71au > https://www.insanelymac.com/forum/topic/329828-making-a-bootable-high-sierra-usb-installer-entirely-from-scratch-in-windows-or-linux-mint-without-access-to-mac-or-app-store-installerapp/

PikeRAlpha > https://pikeralpha.wordpress.com/2017/06/06/catalogurl-for-macos-10-13-high-sierra/
