@echo off
z80asm -DMSX1 -b -o=rcmsx1.com rcmsx.asm
z80asm -DMSX2 -b -o=rcmsx2.com rcmsx.asm
del *.o
