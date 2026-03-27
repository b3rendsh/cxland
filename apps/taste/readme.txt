TASTE
=====

IDE disk info and test program.

This program was originally written to test the BEER and SODA interfaces on 
MSX computers. The binary version can be loaded from BASIC with the command
BLOAD "TASTE.BIN",R

The DOS version can be started from the MSX-DOS or RomWBW CP/M command prompt.

The usage on RomWBW CP/M is experimental. It should work with standard CF IDE
and 8255 PPIDE interface cards on Z80 or Z180 rcbus computers.
The RomWBW disk driver isn't used but the IDE hardware is directly accessed
so it won't work with all RomWBW compatible hardware configurations.

It is required to have a master disk unit attached to the interface.


Commandline parameters
----------------------

Test options:
/X	Include block read test.
	Note: some disk controllers don't support multi sector read.

/W	Include write test.
	This test destroys the laste 64KB of data on the harddisk! 
	On large disks the last 64KB up to 4GB is used.

/D	Print debug information.

Multiple test options can be specified.

Interface:
/B	BEER IDE (MSX)
/M	MALT / CF IDE
/S	SODA / 8255 PPIDE

If no interface is specified then the program will try to autodetect it.
