MSX CP/NET 115K2 BAUD
=====================

The baudrate can be drastically increased by directly accessing the uart
instead of using HBIOS. The ins8250 driver can be used which is compatible
with the 16550.

config.lib:
set uart port to 0x88 which is the 2nd uart port
set baudrate divider to 0x00a which is 115k2 on 18.432Mhz clock

Install
-------
copy the msx-115k2/snios.spr to the cp/net drive on the MSX
start the server with conf=msx-115k/cpnetrc.msx
on the msx you won't have to set the baudrate anymore (mode com1: 9600)

Build snios.spr
---------------
To use other uart configuration settings, rebuild snios.spr:
change the settings in config.lib
copy config.lib to cpnet-z80/src/ins8250/
make NIC=ser-dri HBA=ins8250
copy bld/ser-dri/ins8250/bin/cpnet12/snios.spr to msx-115k/
