# OSX86dotNET-Linux4macOS
#### A tool to help fixing macOS from Linux


Linux4macOS, is a script to help users fix a macOS install from Linux.

This are the current features:


- Create a macOS installer.
- Install Clover Bootloader to disk for UEFI and Legacy boot.
- Download and install Basic set of kexts (work in progress).
- Install hfsprogs to access HFS and HFS+ formatted partitions.
- Compile and Install APFS-Fuse to access APFS formatted partitions.
- Mount APFS formatted partitions.
- Mount DMGs.
- Extract and decompile ACPI Tables.
- Make complete system dump including Full Audio Codec dump and EDID.


~~Currently it has full capabities Manjaro and Ubuntu but, the script
was made with the intention of make it compatible to others distros.~~

Now it's working in some of the most used distros...

> You can download Manjaro Linux from [here](https://manjaro.org/get-manjaro/)

> You can download Ubuntu Linux from [here](https://www.ubuntu.com/download/desktop)

> You can download Linux Mint from [here](https://linuxmint.com/download.php)

~~Keep inf mind that, by running the script from a LiveOS, you may need to perform a full
system upgrade. The script will automatically do this for Manjaro but, for Ubuntu, external
configuration is needed in order ro allow access to all repositories.~~

A full system upgrade isn't needed at all...

Mint and Manjaro has full repository access from the Live OS, Ubuntu needs some
interaction, you can find a better description [here](https://www.osx86.net/forums/topic/25653-osx86dotnet-linux4macos/).


The usage is simple, clone or download it, go to its directory and run;
```

./OSX86dotNET.sh -l
```
This will make the script run all tasks, an option is mandatory, it won't run without any...


The available options are:
```

-a              = Compile and install APFS-Fuse drivers
-c 		= Install Clover Bootloader to a disk
-d 		= Used as direct jump, needs extra argument.
-g 		= Mount a DMG
-h 		= This help
-i 		= Create a macOS installer
-l 		= Run all tasks
-v 		= Verbose output
```
 
Arguments are used for direct jump to a specific function and may be used 
as shown below;
```

./OSX86dotNET.sh -d ARGUMENT
```

The available arguments are:
```
system_dump         =Dump system information
acpidump            =Dump ACPI Table
applefs             =Compile and install APFS-Fuse drivers "same as -a"
clover_ask          =Install Clover to disk "same as -c"
dev_tool            =Check and install development tools"
mount_apfs_volume   =Mount an APFS Volume
```

#### This is a work in progress, so, suggestions are welcome.

The idea of this script is to create a complete environment, to fix
a macOS installation from a LiveCD, for example, or for those not so familiar
with Linux and its capabilities.


#### Thanks to;

[pacapt team](https://github.com/icy/pacapt/blob/master/pacapt#L168)

[m13253's](https://github.com/m13253/clover-linux-installer)

[sgan81](https://github.com/sgan81/apfs-fuse)

[Clover Team](https://sourceforge.net/projects/cloverefiboot/)

[Acidanthera Team](https://github.com/acidanthera)

[kylon](http://cloudclovereditor.altervista.org/cce/index.php)

[fusion71au](https://www.insanelymac.com/forum/topic/329828-making-a-bootable-high-sierra-usb-installer-entirely-from-scratch-in-windows-or-linux-mint-without-access-to-mac-or-app-store-installerapp/)

[PikeRAlpha](https://pikeralpha.wordpress.com/2017/06/06/catalogurl-for-macos-10-13-high-sierra/)
