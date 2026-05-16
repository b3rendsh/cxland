; SNIOS plug-in functions for RomWBW HBIOS serial port
;
; Entry criteria:
; All data and the stack must be in upper memory
; The HBIOS bank must be selected in lower memory

	maclib	z80		; z80 instructions
	maclib	config		; configuration

	public	sendby,check,recvby,recvbt
	
	; HBIOS serial functions
	public	HBSCFN,HB1RRFN,HB1GCFN,HB2RRFN,HB2GCFN

	cseg

	
; Destroys C, E, B
sendby:
	push	bc
	push	de
	push	hl
	mov	e,a		; e is the data byte
	call	0000h
HBSCFN	equ	$-2
	pop	hl
	pop	de
	pop	bc
	ret

; check to see if the device is present
check:	
	
; empty the input buffer befor proceeding.
chklp:	
	call	0000h
HB1RRFN	equ	$-2
	cpi	0
	jz	chklp1
	call	0000h
HB1GCFN	equ	$-2
	jmp	chklp
chklp1:	stc			; since you can't unplug the sio port its always there
	cmc
	ret

; When using this, each byte must be coming soon...
; Destroys C, B, D
; Returns character in A
recvby:	
	push	bc
	push	de
	push	hl
	lxi	d,0
recvb0:
	push	de
	call	0000h
HB2RRFN	equ	$-2
	pop	de		; prep DE for down count
	cpi	0		; zero means no bytes
	jnz	rcvb1
	dcx	d		; count down 1
	mov	a,d		; check for wrap
	ora	e
	jnz	recvb0
	pop	hl
	pop	de
	pop	bc
	stc			; carry is err
	ret			; CY, plus A not '-'
	
; Receive initial message bytes (e.g. "++")
; May need timeout, but must be long.
; Must preserve all regs (exc. A)
; May return CY on timeout.
recvbt:
	push	bc
	push	de
	push	hl
rcvb1:	
	call	0000h
HB2GCFN	equ	$-2
	mov	a,e		; copy to a
	pop	hl
	pop	de
	pop	bc
	stc
	cmc			; no errors
	ret
	
	end
