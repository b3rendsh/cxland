SNIOS for RomWBW HBIOS
======================

Optimized SNIOS for RomWBW HBIOS serial ports, using the DRI BINARY protocol.
This driver is appr. 2x faster than distributed with RomWBW release v3.6.0

The driver is optimized by temporarily switching to the HBIOS bank and directly
calling the serial functions for sending and receiving data.

It has been tested with CP/NET 1.2 on a MSX, SC720 Z80 and SC203 Z180 computer.
Features tested are network, rdate, netstat and file copy commands.


Install
-------
Copy the snios.spr file to the cp/net drive on your client computer.


Build/customize
---------------
1. Setup the build environment: see cpnet-z80/md/BUILD.md
2. Copy the sources in this folder to cpnet-z80/src/ser-hbios
3. Review settings in cpnet-z80/src/ser-hios/config.lib
4. In the cpnet-z80 folder type the command: 
   make NIC=ser-hbios HBA=null

This will create bld/ser-hbios/null/bin/cpnet12/snios.spr






