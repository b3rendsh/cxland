# RomWBW 3.5.1 for MSX

Source: https://github.com/b3rendsh/cxland

## Introduction

This folder contains modified sources of RomWBW 3.5.1 for the MSX 1 computer or newer.

The modifications are not part of the official RomWBW distribution and are not supported. If you have any issues or questions related to this customized MSX version please create an issue in the cxland repo or write a message on MRC in this thread: https://msx.org/forum/msx-talk/development/a-modern-cpm-for-msx

RomWBW will work on MSX by using a standard MSX RAM Mapper as the RomWBW memory manager.
The RomWBW HBIOS and other banks are preloaded from a disk image with a MSX-DOS loader application.

There is no specific add-on hardware required, just a standard MSX with at least a 512KB RAM mapper.
A BEER IDE or SODA IDE cart with a 1GB CF card is recommended as a disk storage option.

The same license terms apply as the original distribution of RomWBW. The modified sources and binaries are shared in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

Official distribution of RomWBW: https://github.com/wwarthen/RomWBW

## Installation/usage

The easiest way to get started with RomWBW for MSX is to use the prebuilt disk image and/or ROM file.
1. Flash the msx_combo_256MB.dsk image to a 256MB or higher capacity storage card.
2. Boot your MSX 2 with this storage card on a supported disk system.
3. Run "rcmsx2" in the 8MB MSX FAT12 boot partition.  

Note: if you don't have a supported disk system then you can still load RomWBW but you will only have
access to the built-in ROM applications and ramdisk.

## Custom installation/configuration

1. Download and unzip RomWBW release 3.5.1 to a local folder e.g. C:\RomWBW
2. Copy the contents of the RomWBW351\Source folder into the local RomWBW\Source folder.
3. In the local RomWBW folder run the "clean" script
4. Optional: modify configuration settings in Source\HBIOS\Config\RCZ80_msx2.asm (see also RCZ80_msx.asm)
5. In the RomWBW folder run the "build rcz80 msx2" script.
6. Flash the disk image Binary\hd1k_combo.img to a CF card.
7. Format the 384 MB FAT partition on the CF card for FAT16.
8. Copy Binary\RCZ80_msx2.rom to rcmsx2.rom on the FAT16 partition of the CF card.
9. Copy msx351\rcmsx2.com to the FAT16 partition of the CF card.
10. Run "rcmsx2" from the MSX-DOS command prompt.

## RomWBW modifications for MSX

The modificiations are clearly marked in the source code with the MSX_MOD directive and/or MSX_NOTE comment.

| File         | Modification                                           |
|:-------------|:-------------------------------------------------------|
| hbios.asm    | added memory manager which uses standard MSX RAM Mapper, no ROM support |
| hbios.asm    | proxy code copy is reduced by 2 bytes to avoid writing to memory address 0xFFFF |
| std.asm      | added a few configuration options                      |
| tms.asm      | use same i/o delay as in MSX BIOS                      |
| mky.asm      | modified init routine for MSX                          |
| sn76489.asm  | added i/o port options for z180 and MSX MMM            | 
| font8x8u.bin | replaced font with standard MSX (CP 437) character set |
| ide.asm      | optimized CF IDE driver for MSX, 20% faster throughput |
| ppide.asm    | adapted for the MSX BEER cart                          |

Patches applied to external apps to use the IDENT pointer $FFFC instead of $FFFE:
| File         | Line(s)        |
|:-------------|:---------------|
| fat.com      | address 0x009B |
| assign.asm   | line 191       |
| cpuspd.asm   | line 32        |
| fdu.asm      | line 175       |
| htalk.asm    | line 34        |
| mode.asm     | line 51        |
| portscan.asm | line 229       |
| reboot.asm   | line 56        |
| rtc.asm      | line 1206      |
| slabel.asm   | line 66        |
| srom.asm     | line 40        |
| startup.asm  | line 34        |
| timer.asm    | line 55        |
| tune.asm     | line 447       |
| sysconf.asm  | line 45        |

# RomWBW 3.5.1 for MSX

Source: https://github.com/b3rendsh/cxland

## Introduction

This folder contains modified sources of RomWBW 3.5.1 for the MSX 1 computer or newer.

The modifications are not part of the official RomWBW distribution and are not supported. If you have any issues or questions related to this customized MSX version please create an issue in the cxland repo or write a message on MRC in this thread: https://msx.org/forum/msx-talk/development/a-modern-cpm-for-msx

RomWBW will work on MSX by using a standard MSX RAM Mapper as the RomWBW memory manager.
The RomWBW HBIOS and other banks are preloaded from a disk image with a MSX-DOS loader application.

There is no specific add-on hardware required, just a standard MSX with at least a 512KB RAM mapper.
A BEER IDE or SODA IDE cart with a 1GB CF card is recommended as a disk storage option.

The same license terms apply as the original distribution of RomWBW. The modified sources and binaries are shared in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

Official distribution of RomWBW: https://github.com/wwarthen/RomWBW

## Installation/usage

The easiest way to get started with RomWBW for MSX is to use the prebuilt disk image and/or ROM file.
1. Flash the msx_combo_256MB.dsk image to a 256MB or higher capacity storage card.
2. Boot your MSX 2 with this storage card on a supported disk system.
3. Run "rcmsx2" in the 8MB MSX FAT12 boot partition.  

Note: if you don't have a supported disk system then you can still load RomWBW but you will only have
access to the built-in ROM applications and ramdisk.

## Custom installation/configuration

1. Download and unzip RomWBW release 3.5.1 to a local folder e.g. C:\RomWBW
2. Copy the contents of the RomWBW351\Source folder into the local RomWBW\Source folder.
3. In the local RomWBW folder run the "clean" script
4. Optional: modify configuration settings in Source\HBIOS\Config\RCZ80_msx2.asm (see also RCZ80_msx.asm)
5. In the RomWBW folder run the "build rcz80 msx2" script.
6. Flash the disk image Binary\hd1k_combo.img to a CF card.
7. Format the 384 MB FAT partition on the CF card for FAT16.
8. Copy Binary\RCZ80_msx2.rom to rcmsx2.rom on the FAT16 partition of the CF card.
9. Copy msx351\rcmsx2.com to the FAT16 partition of the CF card.
10. Run "rcmsx2" from the MSX-DOS command prompt.

## RomWBW modifications for MSX

The modificiations are clearly marked in the source code with the MSX_MOD directive and/or MSX_NOTE comment.

| File         | Modification                                           |
|:-------------|:-------------------------------------------------------|
| hbios.asm    | added memory manager which uses standard MSX RAM Mapper, no ROM support |
| hbios.asm    | proxy code copy is reduced by 2 bytes to avoid writing to memory address 0xFFFF |
| std.asm      | added a few configuration options                      |
| tms.asm      | use same i/o delay as in MSX BIOS                      |
| mky.asm      | modified init routine for MSX                          |
| sn76489.asm  | added i/o port options for z180 and MSX MMM            | 
| font8x8u.bin | replaced font with standard MSX (CP 437) character set |
| ide.asm      | optimized CF IDE driver for MSX, 20% faster throughput |
| ppide.asm    | adapted for the MSX BEER cart                          |

Patches applied to external apps to use the IDENT pointer $FFFC instead of $FFFE:
| File         | Line(s)        |
|:-------------|:---------------|
| fat.com      | address 0x009B |
| assign.asm   | line 191       |
| cpuspd.asm   | line 32        |
| fdu.asm      | line 175       |
| htalk.asm    | line 34        |
| mode.asm     | line 51        |
| portscan.asm | line 229       |
| reboot.asm   | line 56        |
| rtc.asm      | line 1206      |
| slabel.asm   | line 66        |
| srom.asm     | line 40        |
| startup.asm  | line 34        |
| timer.asm    | line 55        |
| tune.asm     | line 447       |
| sysconf.asm  | line 45        |
