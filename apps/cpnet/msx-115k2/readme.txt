MSX CP/NET 115K2 BAUD
=====================

The baudrate can be drastically increased by directly accessing the uart
instead of using HBIOS. The ins8250 driver can be used which is compatible
with the 16550.


Install
-------
1. Copy the msx-115k2/snios.spr to the cp/net drive on the MSX
2. Start the server with conf=msx-115k2/cpnetrc.msx

On the MSX you won't have to set the baudrate anymore (mode com1: 9600)


Customization
-------------

To use other uart configuration settings, rebuild SNIOS.SPR

1. Setup the build environment: see cpnet-z80/md/BUILD.md
2. Review config.lib
   a. Set the uart port base address (SERPORT)
      080h = port 1
      088h = port 2
   b. Set the baudrate divider (SERBAUD)
      000ah = 115k2 for 18.432Mhz uart clock
      0001h = 115k2 for 1.8432Mhz uart clock
3. Copy config.lib to cpnet-z80/src/ins8250/
4. In the cpnet-z80 folder type the command: 
   make NIC=ser-dri HBA=ins8250

This will create bld/ser-dri/ins8250/bin/cpnet12/snios.spr




