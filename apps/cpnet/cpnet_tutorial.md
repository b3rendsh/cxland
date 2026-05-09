# Tutorial: setting up CP/NET 1.2 via serial on RomWBW systems

This guide explains how to connect a CP/M 2.2 client (RomWBW) to a modern PC server using a serial connection. This allows your vintage hardware to access storage on your PC as if it were a local disk drive.

See also the RomWBW User Guide [CP/NET section](https://wwarthen.github.io/RomWBW/UserGuide/#cpnet-networking)

## System Overview
CP/NET allows a "Slave" (the Z80 computer) to access resources on a "Master" (the PC). The communication happens over a serial link, managed by the SNIOS (Slave Network I/O System) on the client and a serial server on the PC.

## Hardware requirements
* Cabling: a serial cable supporting RTS/CTS hardware flow control.
* Server: a PC (Linux/Windows/Mac) with a Serial-to-USB (FTDI) adapter.
* Client: a Z80 computer running RomWBW (e.g. MSX with 16552 cart, SC720 RCBUS).

## Cabling and timing

The serial cable should be connected to the second serial port on the Z80 system. The timings are mostly dependent on what client system is used.

| Hardware         | Recommended baud | ACK Timeout | Port   |
|:---------------- |-----------------:|------------:|:-------|
| MSX (16552 cart) | 9600             | 200ms       | Port 2 |
| MSX 16550 DIRECT | 115200           | 200ms       | Port 2 |
| SC720 RCBUS      | 115200           | 100ms       | Port B |

## Server-side setup (Linux/PC)
We use the cpnet-z80 java-based serial server in this example.

**Installation**
1. Download the server files from [cpnet-z80](https://github.com/durgadas311/cpnet-z80)
2. Optionally download [jSerialComm v2.6.2](https://github.com/Fazecast/jSerialComm/releases/tag/v2.6.2)
3. Ensure you have CpnetSerialServer.jar and the jSerialComm library in your working folder e.g. ~/Apps/cpnet.
4. Create a folder structure for your networked drives:
```
mkdir ~/Apps/cpnet/root    # Root folder
mkdir ~/Apps/cpnet/root/a  # Maps to network drive A:
mkdir ~/Apps/cpnet/root/b  # Maps to network drive B:
```
5. Configuration: cpnetrc  
Create a server configuration file  ([cpnetrc.msx](cpnetrc.msx) / [cpnetrc.rcz80](cpnetrc.rcz80)) and set:  
- Baudrate: 9600 (MSX) or 115200 (SC720 RCBUS).
- Flow control: rts/cts.
- Protocol: DRI BINARY CRC
- Timeouts: set dri_ack_timeout and dri_char_timeout to 100ms–200ms to prevent verify errors.
- Root directory

6. Create/customize the [serialserver](serialserver) launch script for your environment.

**Start the server**
```
cd ~/Apps/cpnet
./serialserver conf=cpnetrc.msx
```

Note: all files on the PC must be lowercase to be visible to CP/M.

## Client-side setup (CP/M)
Extract the CP/NET files from the CPN12SER.LBR to your working drive (J:).

CP/NET requires CCP.SPR to be present on your local boot drive, usually A:. Since RomWBW often uses a RAM disk for drive A: you must copy it from your CP/NET drive before launching the network.

On MSX you must also lower the baudrate for the second serial port.

```
A> COPY J:CCP.SPR A0:  # Required: relocatable Console Command Processor
A> MODE COM1: 9600     # Set the port speed to match the server
```

## Launching the network
Once the server is running on the PC, execute the following on the CP/M client.

1. Start the Loader:  
`J> CPNETLDR`  
You should see "CP/NET 1.2 loading complete."  
2. Map drives:  
Map a local drive letter (like K:) to a server drive (like A:):  
`J> NETWORK K:=A:`  
3. Verify:  
`J> DIR K:` 

## Troubleshooting
| Symptom                 | Cause                | Solution                                         |
|:------------------------|:---------------------|:-------------------------------------------------|
| CCP.SPR ?               | File missing from A: | Copy CCP.SPR to your boot drive user 0.          |
| Disk full / write error | Buffer overrun       | Enable RTS/CTS flow control and lower baud rate. |
| Verify error (PIP/COPY) | Server latency       | Increase dri_ack_timeout to 100ms / 200ms.       | 
| Files not visible       | Filename case        | Ensure files on the server are lowercase.        | 

## MSX 16550 DIRECT

Check the [msx-115k readme](msx-115k2/readme.txt) howto increase the speed on MSX to 115200 baud.

