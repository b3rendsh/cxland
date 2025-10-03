# RomWBW for MSX

## Introduction

This folder contains compiled binaries of RomWBW for MSX.

RomWBW will work on MSX by using a standard MSX RAM Mapper as the RomWBW memory manager.  
The RomWBW HBIOS and other banks are preloaded from a disk image with a MSX-DOS loader application.  
There is no specific add-on hardware required, just a standard MSX with at least a 512KB RAM mapper.  
A BEER IDE or SODA IDE cart with a 256MB CF card is recommended as a disk storage option.

The same license terms apply as for the official distribution of RomWBW. The binaries are shared in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

## Installation/usage on real MSX

1. Flash the msx_combo_256MB.dsk image to a 256MB or higher capacity storage card.
2. Boot your MSX 2 with this storage card on a supported disk system.
3. Run "msx-ldr" in the 8MB MSX FAT12 boot partition.  

Notes:  
1: If you don't have a supported disk system then you can still load RomWBW but you will only have
access to the built-in ROM applications and ramdisk.  
2: RomWBW uses the Omega keyboard driver with US international keyboard layout, using other keyboard layouts may cause incorrect key mapping.

## openMSX emulator usage

RomWBW can be used in openMSX with the following machine configuration.  
Make sure you have the required system roms installed (google systemroms for openMSX).  
1. Select the Philips NMS8255 machine (MSX 2 with international keyboard layout).
2. Insert openMSX Team Memory Mapper (512KB) extension in cart Slot A.
3. Insert SOLiD BEER IDE extension in cart Slot B.
4. For Disk Drive A select the msx_fd_720KB.dsk image.
5. For Hard Disk A select the msx_combo_256MB.dsk image.
6. Boot the machine.  

Notes:  
1: If you use the latest BEER ROM (github msxdos2s) then you can boot from the hard disk and step 4 is not required.  
2: You can boot more CP/M work-alike systems then are displayed in the boot menu e.g. CP/M 3. See RomWBW user manual.

## Custom configuration

Clone the RomWBW repository and modify the MSX platform configuration files for a custom setup.
