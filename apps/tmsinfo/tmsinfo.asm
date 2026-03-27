; ------------------------------------------------------------------------------
; tmsinfo.asm
; RomWBW HBIOS TMS Information
;
; (C) 2026 All rights reserved.
; ------------------------------------------------------------------------------

HB_INVOKE	equ	$fff0			; invoke HBIOS function
HB_IDENT	equ	$fffc			; pointer to HBIOS ident data block
BF_VDADEV	equ	$43			; VDA device info


		ORG	$100

		jp	main

		db	13,10
		db	"ROMWBW TMSINFO V0.1",13,10
		db	26

main:		call	check_ident
		ld	de,t_nohbios
		jp	nz,print_string		; display message and return to CP/M
		
		; get vda device information
		ld	b,BF_VDADEV		; device info
		ld	c,0			; unit 0
		call	HB_INVOKE

		; check device type
		ld	a,3			; 3=TMS
		cp	d			; is device type TMS?
		jr	z,tms_info1		; z=yes, continue

		ld	de,t_notms
		jp	print_string		; display message and return to CP/M

tms_info1:	ld	de,t_attributes
		call	print_string
		ld	de,TMS_CHIPSTR
		ld	a,c			; vdpid
		call	print_idx

		ld	de,t_vram
		call	print_string
		ld	de,TMS_VRAMSTR
		ld	a,b			; vram
		call	print_idx

		ld	de,t_iobase
		call	print_string
		ld	a,l			; i/o base
		call	print_hex

		ld	a,b
		or	a			; vram unknown?
		ld	de,t_crlf
		jr	z,tms_info2		; z=yes, skip note
		ld	de,t_note
tms_info2:	call	print_string

		jp	0

; ------------------------------------------------------------------------------
; Subroutines
; ------------------------------------------------------------------------------

; Check for RomWBW HBIOS
check_ident:	ld	hl,(HB_IDENT)
		ld	a,'W'
		cp	(hl)
		ret	nz
		inc	hl
		ld	a,~'W'
		cp	(hl)
		ret

; Print nth string in a list
; based on subroutine in RomWBW util.asm
; Input: a  = n
;        de = pointer to start of list
print_idx:	push	bc
		ld	c,a			; index count
		or	a
prtidxdea1:	jr	z,prtidxdea3
prtidxdea2:	ld	a,(de)			; loop unit
		inc	de			; we reach
		cp	'$'			; end of string
		jr	nz,prtidxdea2
		dec	c			; at string end. so go
		jr	prtidxdea1		; check for index match
prtidxdea3:	pop	bc
		jr	print_string
		; fall through to print string

; Print string
; Input: de = pointer to string
print_string:	push	bc
		push	de
		push	hl
		ld	c,9
		call	5
		pop	hl
		pop	de
		pop	bc
		ret

; Print byte value as hex
print_hex:	push	bc
		ld	b,a
		and	$f0
		rrca
		rrca
		rrca
		rrca
		add	a,'0'
		cp	'9'+1
		jr	c,digit1
		add	a,7
digit1:		ld	(t_hex+2),a
		ld	a,b
		and	$0f
		add	a,'0'
		cp	'9'+1
		jr	c,digit2
		add	a,7
digit2:		ld	(t_hex+3),a
		pop	bc
		ld	de,t_hex
		jr	print_string

; ------------------------------------------------------------------------------
; Text
; ------------------------------------------------------------------------------

t_hex:		db	"0x00$"
t_nohbios:	db	"HBIOS not detected",13,10,"$"
t_notms:	db	"Video device type is not TMS",13,10,"$"
t_attributes:	db	"HBIOS TMS Device Information"
		db	13,10,"----------------------------"
		db	13,10,10,"VDPID  : $"
t_vram:		db	13,10,"VRAM   : $"
t_iobase:	db	13,10,"IOBASE : $"
t_note:		db	13,10,10,"On FPGA the VRAM can be incorrect"
t_crlf:		db	13,10,"$"

TMS_CHIPSTR:	db	"Unknown$"	; 0
		db	"TMS9918A$"	; 1
		db	"V9938$"	; 2
		db	"V9958$"	; 3
		db	"SUPER V9958$"	; 4
		db	"F18A$"		; 5

TMS_VRAMSTR:	db	"Unknown$"	; 0
		db	"4KB$"		; 1
		db	"16KB$"		; 2
		db	"32KB$"		; 3
		db	"16KB-64KB$"	; 4
		db	"128KB$"	; 5
		db	"192KB$"	; 6
		db	"1MB$"		; 7
