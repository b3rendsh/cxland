	title	'Requester Network I/O System for CP/NET 1.2'

;***************************************************************
;***************************************************************
;**                                                           **
;**  R e q u e s t e r   N e t w o r k   I / O   S y s t e m  **
;**                                                           **
;***************************************************************
;***************************************************************

;/*
;  Copyright (C) 1980, 1981, 1982
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:  October 5, 1982
;*/

; May 24, 2020
; Modified for github/durgadas311/cpnet-z80 build environment.
; 
; Henk Berends, 2026: 
; Protocol and driver optimizations for RomWBW HBIOS

	maclib	config
	maclib	z80

	public	NTWKIN,NTWKST,CNFTBL,SNDMSG,RCVMSG,NTWKER,NTWKBT,NTWKDN,CFGTBL
	extrn	sendby,check,recvby,recvbt

	; HBIOS serial functions
	extrn	HBSCFN,HB1RRFN,HB1GCFN,HB2RRFN,HB2GCFN

	
;	 CP/M BDOS funcions
;
BDOS	equ	0005h		; BDOS call entry
print	equ	09h		; print string function

; 	Network Status Byte Equates
;
active	equ	0001$0000b	; slave logged in on network
rcverr	equ	0000$0010b	; error in received message
senderr	equ	0000$0001b	; unable to send message

;	General Equates
;
cSOH	equ	01h		; Start of Header
cSTX	equ	02h		; Start of Data
cETX	equ	03h		; End of Data
cEOT	equ	04h		; End of Transmission
cENQ	equ	05h		; Enquire
cACK	equ	06h		; Acknowledge
cNAK	equ	15h		; Negative Acknowledge

	CSEG

; -----------------------------------------------------------------------------
; 	Initial Slave Configuration Table - must be first in module
;
CFGTBL:
Network$status:
	db	0		; network status byte
	db	0ffh		; slave processor ID number
	dw	0		; A:  Disk device
	dw	0		; B:   "
	dw	0		; C:   "
	dw	0		; D:   "
	dw	0		; E:   "
	dw	0		; F:   "
	dw	0		; G:   "
	dw	0		; H:   "
	dw	0		; I:   "
	dw	0		; J:   "
	dw	0		; K:   "
	dw	0		; L:   "
	dw	0		; M:   "
	dw	0		; N:   "
	dw	0		; O:   "
	dw	0		; P:   "

	dw	0		; console device

	dw	0		; list device:
	db	0		;	buffer index
	db	0		;	FMT
	db	0		;	DID
	db	0ffh		;	SID (CP/NOS must still initialize)
	db	5		;	FNC
	db	0		;	SIZ
	db	0		;	MSG(0)  List number

msgbuf:	; temp message, do not disturb LST: header
	ds	128		;	MSG(1) ... MSG(128)
	ds	136		; extend msgbuf to max message size of 262 bytes

msg$adr:
	ds	2		; message address
retry$count:
	ds	1

;FirstPass:
;	db	0ffh

;wboot$msg:			; data for warm boot routine
;	db	'<Warm Boot>'
;	db	'$'

;networkerrmsg:
;	db	'Network Error'
;	db	'$'

; HBIOS data:
ERRAPI	db	13,10,13,10,'++ HBIOS API ERROR ++',13,10,'$'
	ds	20		; 48-byte stack space including the 28 bytes of the ERRAPI text
STACK				; temporary stack in upper memory

; -----------------------------------------------------------------------------
;	Utility Procedures
;

Pre$Char$out:
	mov	a,d
	add	c
	mov	d,a		; update the checksum in D
	mov	a,c
	jmp	sendby

Net$out:			; C = byte to be transmitted
				; D = checksum
	mov	a,d
	add	c
	mov	d,a
	mov	a,c
	jmp	sendby

Msg$in:				; HL = destination address
				; E  = # bytes to input
	call	Net$in
	rc
	mov	m,a
	inx	h
	dcr	e
	jnz	Msg$in
	ret

Net$in:				; byte returned in A register
				; D  = checksum accumulator

	call	recvby		;receive byte in Binary mode
	rc
 	mov	b,a
	add	d		; add & update checksum accum.
	mov	d,a
	ora	a		; set cond code from checksum
	mov	a,b
	ret

Msg$out:			; HL = source address
				; E  = # bytes to output
				; D  = checksum
				; C  = preamble byte
	mvi	d,0		; initialize the checksum
	call	Pre$Char$out 	; send the preamble character
Msg$out$loop:
	mov	c,m
	inx	h
	call	Net$out
	dcr	e
	jnz	Msg$out$loop
	ret

; -----------------------------------------------------------------------------
; 	Temporary switch to HBIOS bank and invoke function in IX
;

HBSER:	
	lxiy	0000h		; LD IY,HBUDAT
HBUDAT	equ	$-2		; patch data address
	sspd	STACKS		; LD (STACKS),SP
	lxi	sp,STACK	; use temporary stack in upper memory
	push	bc
	lxi	b,0f200h	; function: system set bank
BIOSBID	equ	$-2		; patch HBIOS bank id
	rst	1		; do it
	mov	a,c		; prior bank id 
	sta	PREVBID		; save it for later
	pop	bc
	call	JPIX		; call function in IX
	push	psw
	mvi	a,00h		; restore prior bank id
PREVBID	equ	$-1
	call	0fff3h		; call HBIOS select bank
	pop	psw
	lxi	sp,0000h	; restore stack
STACKS	equ	$-2
	ret

JPIX:	pcix			; JP (IX)

; -----------------------------------------------------------------------------
; 	Initialize direct calls into HBIOS bank
;

inithb:
	; Get HBIOS bank id
	lxi	b,0f8f2h	; HBIOS SYSGET, Bank Info
	rst	1
	jnz	api$err		; handle API error
	mov	a,d		; BIOS bank id to A
	sta	BIOSBID		; Plug in bank id
	
	; Patch SENDR with FastPath addresses
	lxi	b,0f801h	; Get CIO func/data adr
	mvi	d,01h		; Func=CIO OUT
	mvi	e,UNIT
	rst	1
	jnz	api$err		; handle API error
	sded	HBUDAT		; Plug in data adr	LD (HBUDAT),DE
	shld	HBSCFN		; Plug in func adr

	; Patch GETCHR with FastPath addresses
	lxi	b,0f801h	; Get CIO func/data adr
	mvi	d,00h		; Func=CIO IN
	mvi	e,UNIT
	rst	1
	jnz	api$err		; handle API error
	shld	HB1GCFN		; Plug in func adr 1
	shld	HB2GCFN		; Plug in func adr 2

	; Patch RCVRDY with FastPath addresses
	lxi	b,0f801h	; Get CIO func/data adr
	mvi	d,02h		; Func=CIO IST
	mvi	e,UNIT
	rst	1
	jnz	api$err		; handle API error
	shld	HB1RRFN		; Plug in func adr 1
	shld	HB2RRFN		; Plug in func adr 2

	; Patch SNDRDY with FastPath addresses
	; not used
	;lxi	b,0f801h	; Get CIO func/data adr
	;mvi	d,03h		; Func=CIO OST
	;mvi	e,UNIT
	;rst	1
	;jnz	api$err		; handle API error
	;shld	HBSRFN		; Plug in func adr
	
	ret
	
api$err:
	; API returned unexpected failure
	lxi	d,ERRAPI	; API error message
	mvi	c,9		; BDOS string display function
	call	5		; Do it
	jmp	0		; Bail out!
	
; -----------------------------------------------------------------------------
;	Network Initialization
;
NTWKIN:
	; first initialize direct calls into HBIOS bank
	call	inithb

	pushiy
	pushix
	lxix	ntwkin0
	call	HBSER
	popix
	popiy
	ret
	
ntwkin0:	
	; check to see if the device is present
	call	check
	jc	initerr

	; Send "BDOS Func 255" message to other end,
	; Response will tell us our, and their, node ID
	lxix	msgbuf
	mvix	0,+0		; FMT
	mvix	0ffh,+3		; BDOS Func
	mvix	0,+4		; Size
	lxi	b,msgbuf
	call	sndmsg0		; avoid active check
	ora	a
	jnz	initerr
	lxi	b,msgbuf
	call	rcvmsg0		; avoid active check
	ora	a
	jnz	initerr
	lda	msgbuf+1	; our node ID
	lxix	CFGTBL
	stx	a,+1		; our slave (client) ID
	mvix	active,+0	; network status byte
	xra	a
	stx	a,+36+7		; clear SIZ - discard LST output
	ret
	
initerr:
	mvi	a,0ffh
	ret

; -----------------------------------------------------------------------------
;	Network Status
;
NTWKST:
	lda	network$status
	mov	b,a
	ani	not (rcverr+senderr)
	sta	network$status
	mov	a,b
	ret

; -----------------------------------------------------------------------------
;	Return Configuration Table Address
;
CNFTBL:
	lxi	h,CFGTBL
	ret

; -----------------------------------------------------------------------------
;	Send Message on Network
;
SNDMSG:				; BC = message addr
	pushiy
	pushix
	bit	7,b		; msessage address in lower memory?
	cz	sndbuf		; z=yes,copy msg to msgbuf
	lxix	sndmsg0		; LD IX,sndmsg0
	call	HBSER
	popix
	popiy
	ret
	
sndbuf:	mov	h,b
	mov	l,c
	lxi	d,msgbuf
	lxi	b,262
	ldir
	lxi	b,msgbuf
	ret

sndmsg0:
	mov	h,b
	mov	l,c		; HL = message address
	shld	msg$adr
	lda	CFGTBL+1
	inx	b
	inx	b
	stax	b		; SID
re$sendmsg:
	mvi	a,max$retries
	sta	retry$count	; initialize retry count
send:
	lhld	msg$adr
	mvi	a,cENQ
	call	sendby		; send ENQ to master
	mvi	d,timeout$retries
ENQ$response:
	call	recvby
	jnc	got$ENQ$response
	dcr	d
	jnz	ENQ$response
	jmp	Char$in$timeout
got$ENQ$response:
	call	get$ACK0
	mvi	c,cSOH
	mvi	e,5
	call	Msg$out		; send SOH FMT DID SID FNC SIZ
	xra	a
	sub	d
	mov	c,a
	call	Net$out		; send HCS (header checksum)
	call	get$ACK
	dcx	h
	mov	e,m
	inx	h
	inr	e
	mvi	c,cSTX
	call	Msg$out		; send STX DB0 DB1 ...
	mvi	c,cETX
	call	Pre$Char$out	; send ETX
	xra	a
	sub	d
	mov	c,a
	call	Net$out		; send the checksum
	mvi	a,cEOT
	call	sendby		; send EOT
	call	get$ACK		; (leave these
	ret			;              two instructions)

get$ACK:
	call	recvby
	jc	send$retry 	; jump if timeout
get$ACK0:
	ani	7fh
	sui	cACK
	rz
send$retry:
	pop	h		; discard return address
	lxi	h,retry$count
	dcr	m
	jnz	send		; send again unles max retries
Char$in$timeout:
	mvi	a,senderr

 if always$retry
	call	error$return
	jmp	re$sendmsg
 else
	jmp	error$return
 endif

; -----------------------------------------------------------------------------
;	Receive Message from Network
;
RCVMSG:				; BC = message addr
	pushiy
	pushix
	bit	7,b		; msessage address in lower memory?
	jz	rcvbuf		; z=yes,use temporary message buffer
	lxix	rcvmsg0
	call	HBSER
	popix
	popiy
	ret
	
rcvbuf:	push	bc		; save message address
	lxi	b,msgbuf
	lxix	rcvmsg0
	call	HBSER
	cpi	0ffh		; receive error?
	jz	r2		; z=yes, skip buffer copy
	
	; calculate received message size
	mvi	b,0
	lda	msgbuf+4	; payload size
	ora	a		; size=0?
	jnz	r1
	inr	b		; yes, set size to 256
r1:	mov	c,a
	inx	b		; add 5 bytes for the header
	inx	b
	inx	b
	inx	b
	inx	b
	
	pop	de		; restore message address
	lxi	h,msgbuf	; messsage buffer
	ldir			; copy message buffer to message address
r2:	popix
	popiy
	ret

rcvmsg0:
	mov	h,b
	mov	l,c		; HL = message address
	shld	msg$adr
re$receivemsg:
	mvi	a,max$retries
	sta	retry$count	; initialize retry count
re$call:
	call	receive		; rtn from receive is receive error

receive$retry:
	lxi	h,retry$count
	dcr	m
	jnz	re$call
receive$timeout:
	mvi	a,rcverr

 if always$retry
	call	error$return
	jmp	re$receivemsg
 else
	jmp	error$return
 endif

receive:
	lhld	msg$adr
	mvi	d,timeout$retries
receive$firstchar:
	call	recvbt
	jnc	got$firstchar
	dcr	d
	jnz	receive$firstchar
	pop	h		; discard receive$retry rtn adr
	jmp	receive$timeout
got$firstchar:
	ani	7fh
	cpi	cENQ		; Enquire?
	jnz	receive

	mvi	a,cACK
	call	sendby	 	; acknowledge ENQ with an ACK

	call	recvby
	rc			; return to receive$retry
	ani	7fh
	cpi	cSOH		; Start of Header ?
	rnz			; return to receive$retry
	mov	d,a		; initialize the HCS
	mvi	e,5
	call	Msg$in
	rc			; return to receive$retry
	call	Net$in
	rc			; return to receive$retry
	jnz	bad$checksum
	call	send$ACK
	call	recvby
	rc			; return to receive$retry
	ani	7fh
	cpi	cSTX		; Start of Data ?
	rnz			; return to receive$retry
	mov	d,a		; initialize the CKS
	dcx	h
	mov	e,m
	inx	h
	inr	e
	call	Msg$in		; get DB0 DB1 ...
	rc			; return to receive$retry
	call	recvby		; get the ETX
	rc			; return to receive$retry
	ani	7fh
	cpi	cETX
	rnz			; return to receive$retry
	add	d
	mov	d,a		; update CKS with ETX
	call	Net$in		; get CKS
	rc			; return to receive$retry
	call	recvby		; get EOT
	rc			; return to receive$retry
	ani	7fh
	cpi	cEOT
	rnz			; return to receive$retry
	mov	a,d
	ora	a		; test CKS
	jnz	bad$checksum
	pop	h		; discard receive$retry rtn adr
	lhld	msg$adr
	inx	h
	lda	CFGTBL+1
	inr	a		; FF => 00
	jz	send$ACK
	dcr	a		; restore value
	sub	m
	jz	send$ACK 	; jump with A=0 if DID ok
	mvi	a,0ffh		; return code shows bad DID
send$ACK:
	push	psw		; save return code
	mvi	a,cACK
	call	sendby	  	; send ACK if checksum ok
	pop	psw		; restore return code
	ret

bad$checksum:
	mvi	a,cNAK
	jmp	sendby	  	; send NAK on bad chksm & not max retries
;	ret

error$return:
	lxi	h,network$status
	ora	m
	mov	m,a
	call	ntwrkerror 	; perform any required device re-init.
	mvi	a,0ffh
	ret

; -----------------------------------------------------------------------------
;	
NTWKER:
ntwrkerror:
	; perform any required device re-initialization
	ret

; -----------------------------------------------------------------------------
;
NTWKBT:

;	This procedure is called each time the CCP is
;  	reloaded from disk.  This version prints "<WARM BOOT>"
;  	on the console and then returns, but anything necessary 
;       for restart can be put here.

; 	mvi	c,print
;	lxi	d,wboot$msg
;	jmp	BDOS
	xra	a
	ret

; -----------------------------------------------------------------------------
;
NTWKDN:	; shutdown server - FNC=254 (no response)
	lxix	msgbuf
	mvix	0,+0		; FMT
	mvix	0feh,+3		; BDOS Func
	mvix	0,+4		; Size
	lxi	b,msgbuf
	
	pushiy
	pushix
	lxix	sndmsg0
	call	HBSER
	popix
	popiy

	xra	a
	ret

; -----------------------------------------------------------------------------
	
	end
