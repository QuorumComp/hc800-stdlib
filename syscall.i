	IFND	SYSCALL_I_INCLUDED_

SYSCALL_I_INCLUDED_ = 1

	INCLUDE	"lowlevel/scancodes.i"

BLOCKDEVICE_SDA		EQU	0
BLOCKDEVICE_SDA0	EQU	1
BLOCKDEVICE_SDA1	EQU	2
BLOCKDEVICE_SDA2	EQU	3
BLOCKDEVICE_SDB		EQU	4
BLOCKDEVICE_SDB0	EQU	5
BLOCKDEVICE_SDB1	EQU	6
BLOCKDEVICE_SDB2	EQU	7

TOTAL_BLOCKDEVICES	EQU	8

			RSRESET
bdinf_Valid		RB	1
bdinf_Size		RB	4
bdinf_Name		RB	8
bdinf_SIZEOF		RB	0

MAX_LABEL_LENGTH	EQU	16
MAX_VOLUME_NAME_LENGTH	EQU	8

			RSRESET
volinf_Label		RB	MAX_LABEL_LENGTH
volinf_Name		RB	MAX_VOLUME_NAME_LENGTH
volinf_BlockDevice	RB	1	; $FF if not block device
volinf_Free		RB	4
volinf_Used		RB	8
volinf_Size		RB	4
volinf_SIZEOF		RB	0

			RSSET	8

; -- Reset machine
KReset			RB	1

; -- Clear the text screen
KClearScreen		RB	1

; -- Set attributes
; --   b - mask of attributes to set
; --   c - attribute value
KTextSetAttributes	RB	1

; -- Output character (incl. control codes)
; --   t - character to print
KCharacterOut		RB	1

; -- Execute command line
; --  bc - command line
KExecute		RB	1

; -- Exit client to kernal
KExit			RB	1

; -- Print debug character
; --   t - character to print
; -- Outputs:
; --    f - "eq" condition if success
KDebugCharacterOut	RB	1

; -- Read character
; -- Outputs:
; --    f - "nz" condition if character available
; --    t - ASCII character
KCharacterIn		RB	1

; -- Get block device information
; --    t - block device identifier
; --   bc - block device information structure
; -- Outputs:
; --    f - "eq" condition if device exists and information structure filled
KGetBlockDevice		RB	1

; -- Get block device information
; --    t - volume index
; --   bc - volume information structure
; -- Outputs:
; --    f - "eq" condition if volume exists and information structure filled
; --        "ne" condition when volume index and further indices do not exist
KGetVolume		RB	1

; -- Set the color attribute for printing text
; -- Usage: MSetColor color
MSetColor:	MACRO
		pusha
		ld	b,$F0
		ld	c,(\1)<<4
		sys	KTextSetAttributes
		popa
		ENDM

; -- Set attribute bits
; -- Usage: MSetAttribute attribute
MSetAttribute:	MACRO
		pusha
		ld	b,(\1)
		ld	c,(\1)
		sys	KTextSetAttributes
		popa
		ENDM

; -- Clear attribute bits
; -- Usage: MSetAttribute attribute
MClearAttribute:	MACRO
		pusha
		ld	b,(\1)
		ld	c,0
		sys	KTextSetAttributes
		popa
		ENDM

; -- Print a new line
MNewLine:	MACRO
		pusha
		ld	t,10
		sys	KCharacterOut
		popa
		ENDM

; -- Print a debug string to UART
MDebugPrint:	MACRO
		pusha
		j	.skip\@
.string\@	DB	\1
.skip\@		ld	d,.skip\@-.string\@
		ld	bc,.string\@
.next\@		lco	t,(bc)
		add	bc,1
		sys	KDebugCharacterOut
		j/ne	.error\@
		dj	d,.next\@
.error\@	popa
		ENDM




	ENDC
