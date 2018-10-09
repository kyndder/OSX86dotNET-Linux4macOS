# OSX86dotNET-Linux4macOS
A tool to help fixing macOS from Linux

Linux4macOS, is a script to help users fix a macOS install from Linux.

This are the current features:

  - Installs Clover Bootloader to disk for UEFI and Legacy boot.
  - Download and installs a Basic set of kexts (work in progress).
  - Install hfsprogs to access HFS and HFS+ formatted partitions.
  - Installs basic developments tools.
  - Installs ACPI tools.
  - Extracts and decompile ACPI Tables.
  - Makes complete system dump.

Currently it has full capabities only at Manjaro Linux but, the script
was made with the intention of make it compatible to others distros.

You can download Manjaro Linux from here > https://manjaro.org/get-manjaro/

The usage is simple, clone or download it, go to its directory and run;


            ./OSX86dotNET.sh


The available options are:

  - -a 				= Compile and install APFS-Fuse drivers
  - -c 				= Install Clover Bootloader to a disk
  - -d 				= Used as direct jump, needs extra argument.
  - -h 				= This help
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
