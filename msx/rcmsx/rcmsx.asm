; ------------------------------------------------------------------------------
; rcmsx.asm
; MSX RomWBW loader, requires 512KB or more RAM mapper
; ------------------------------------------------------------------------------

; The loader assumes following entry conditions:
; + 512KB RAM mapper available
; + RAM mapper slot is selected on all 4 pages
; + Segments 0 to 3 are in use for the DOS TPA
; + The last 2 segments may be in use for MSX-DOS 2 code + data
; + Standard MSX-DOS 2 RAM mapper configuration OR load from MSX-DOS 1
; Todo:
; 1. Switch the TPA RAM segments to the end of the RAM (seg 26-29) so the first 4 
;    segments can also be used by the ROMWBW memory manager.
; 2. Test if there's a RAM mapper that meets the requirements

NBANKS		equ	8			; Number of 32K ROM banks
NSEGS		equ	NBANKS * 2		; Number of 16K RAM segment
ROMWBW_SEG	equ	4			; RomWBW boot segment

P2_SEG  	equ     $f2c9	          	; current segment page 2 (MSX-DOS 2)
CSRSW		equ	$fca9			; cursor on/off flag
H_TIMI		equ	$fd9f			; timer interrupt hook (vdp vsync)
		
; ------------------------------------------------------------------------------
		
		ORG	$100

		; copy loader to page 3 and run it there
		ld	hl,LSTART
		ld	de,$c000
		ld	bc,LSIZE
		ldir
		jp	$c000
		
LSTART:
; ------------------------------------------------------------------------------

		PHASE	$c000
		
		; open ROM image file (fcb)
		ld	de,romfile
		ld	c,$0f			; FOPEN
		call	5
		or	a			; error opening file?
		jp	nz,error_open		; nz=yes

		ld	de,t_message
		ld	c,$09			; STROUT
		call	5
		
		; init fcb file read: set recordsize and disk transfer address 
		ld	hl,$0400		; use 1K blocks
		ld	(romfile+$0e),hl
		ld	de,$8000
		ld	c,$1a			; SETDTA
		call	5

		; cursor off
		xor	a
		ld	(CSRSW),a		
		
		; preload RomWBW rom into RAM Mapper segments
		ld	a,4			; starting segment
		
load_bank:	push	af
		ld	e,$0d			; set cursor te beginning of line
		ld	c,$02			; CONOUT
		call	5
		pop	bc			; reload segment number

		push	bc
		ld	a,NSEGS+4
		sub	b
		call	dspNumA
		pop	af			; reload segment number
		
		out	($fe),a			; select ram segment in page 2
		ld	(P2_SEG),a		; update system variable segment 2 (MSX-DOS 2)
		inc	a
		
		; read rom bank data from file
		push	af
		ld	hl,16			; read 16K data
		ld	de,romfile
		ld	c,$27			; RDBLK
		call	5
		or	a			; error reading file?
		jr	nz,error_read		; nz=yes
		pop	af
	
		; next rom bank
		cp	NSEGS+4
		jr	nz,load_bank
		
		; it's not necessary to close the file
		
		; call H.TIMI 256 times to motor off floppy drives
		di
		xor	a
mtcount:	call	H_TIMI			; H.TIMI handler saves register AF
		dec	a
		jr	nz,mtcount

		; select RomWBW bootloader bank and start RomWBW
		ld	a,ROMWBW_SEG
		out	($fc),a
		inc	a
		out	($fd),a
		jp	$0
		
; ---------------------------------------------------------------------------
; dspNumA - routine to display a value in A in ascii characters
; ---------------------------------------------------------------------------
dspNumA:	ld	l,a
		ld	h,0
		;ld	bc,-100
		;call	num1
		ld	bc,-10
		call	num1
		ld	bc,-01
num1:		ld	a,'0'-1
num2:		inc	a
		add	hl,bc
		jr	c,num2
		sbc	hl,bc
		push	hl
		ld	e,a
		ld	c,$02			; CONOUT
		call	5
		pop	hl
		ret
		
; ---------------------------------------------------------
; Handle errors reading rom file
; ---------------------------------------------------------
error_open:	ld	de,t_open
		jr	error_end

error_read:	pop	af
		ld	de,t_read

error_end:	ld	c,$09			; STROUT
		call	5
		jp	0			; end program
		
	IFDEF MSX1
t_message:	db	"Loading RomWBW for MSX1...",13,10,"$"
t_open:		db	"Error opening rcmsx1.rom file$"
t_read:		db	$0a,"Error reading rcmsx1.rom file$"
romfile:	db	0,"RCMSX1  ","ROM"	; fcb file
	ELSE
t_message:	db	"Loading RomWBW for MSX2...",13,10,"$"
t_open:		db	"Error opening rcmsx2.rom file$"
t_read:		db	$0a,"Error reading rcmsx2.rom file$"
romfile:	db	0,"RCMSX2  ","ROM"	; fcb file
	ENDIF
		defs	25,0			; fcb variables

		DEPHASE
		
; ------------------------------------------------------------------------------

LSIZE		EQU	$-LSTART
