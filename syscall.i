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
volinf_CommonSize	RB	0	; the size of data in common with fs_
volinf_Free		RB	4
volinf_Used		RB	4
volinf_Size		RB	4
volinf_SIZEOF		RB	0


; -- File structure fields are read only and for information only
		RSRESET
file_System	RW	1
file_Length	RB	4
file_Offset	RB	4
file_Error	RB	1
file_Flags	RB	1
file_PRIVATE	RB	16
file_SIZEOF	RB	0

FFLAG_DIR	EQU	$01


; -- Directory structure fields are read only and for information only
		RSRESET
dir_System	RW	1
dir_Error	RB	1
dir_Flags	RB	1
dir_Length	RB	4
dir_Filename	RB	256
dir_PRIVATE	RB	16
dir_SIZEOF	RB	0

DFLAG_DIR	EQU	$01


; ---------------------------------------------------------------------------
; -- Jump vectors
; --

			RSSET	8	; skip interrupt vectors

; ---------------------------------------------------------------------------
; -- Reset machine
; --
KReset			RB	1

; ---------------------------------------------------------------------------
; -- Clear the text screen
; --
KClearScreen		RB	1

; ---------------------------------------------------------------------------
; -- Set attributes
; --
; -- Inputs:
; --   b - mask of attributes to set
; --   c - attribute value
; --
KTextSetAttributes	RB	1

; ---------------------------------------------------------------------------
; -- Output character (incl. control codes)
; --
; -- Inputs:
; --   t - character to print
; --
KCharacterOut		RB	1

; ---------------------------------------------------------------------------
; -- Execute command line
; --
; -- Inputs:
; --  bc - command line
; --
KExecute		RB	1

; ---------------------------------------------------------------------------
; -- Exit client to kernal
; --
KExit			RB	1

; ---------------------------------------------------------------------------
; -- Print debug character
; --
; -- Inputs:
; --   t - character to print
; --
; -- Outputs:
; --    f - "eq" condition if success
; --
KDebugCharacterOut	RB	1

; ---------------------------------------------------------------------------
; -- Read character
; --
; -- Outputs:
; --    f - "nz" condition if character available
; --    t - ASCII character
; --
KCharacterIn		RB	1

; ---------------------------------------------------------------------------
; -- Get block device information
; --
; -- Inputs:
; --    t - block device identifier
; --   bc - block device information structure
; --
; -- Outputs:
; --    f - "eq" condition if device exists and information structure filled
; --
KGetBlockDevice		RB	1

; ---------------------------------------------------------------------------
; -- Get block device information
; --
; -- Inputs:
; --    t - volume index
; --   bc - volume information structure
; --
; -- Outputs:
; --    f - "eq" condition if volume exists and information structure filled
; --        "ne" condition when volume index and further indices do not exist
; --
KGetVolume		RB	1

; ---------------------------------------------------------------------------
; -- Open directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --   bc - path
; --
; -- Output:
; --    f - "eq" if directory could be opened. Directory struct is filled in
; --        with information on first file
; --
KOpenDirectory		RB	1

; ---------------------------------------------------------------------------
; -- Read next file information from directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --
; -- Output:
; --    f - "eq" if next file information could be retrieved. Directory
; --        struct is filled in with information on file.
; --        "ne" when no more files present.
; --
KReadDirectory		RB	1

; ---------------------------------------------------------------------------
; -- Print error description
; --
; -- Inputs:
; --    t - Error code
; --
KPrintError		RB	1

; ---------------------------------------------------------------------------
; -- Get command line tokens. Buffer with be filled with a list of strings,
; -- an empty string denotes the end of the list
; --
; -- Inputs:
; --   ft - pointer to destination (BSS), 256 bytes
; --
KGetCommandLine		RB	1

; ---------------------------------------------------------------------------
; -- Open file
; --
; -- Inputs:
; --   ft - file name path
; --   bc - file struct
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
KOpenFile		RB	1

; ---------------------------------------------------------------------------
; -- Close file
; --
; -- Inputs:
; --   ft - file struct
; --
KCloseFile		RB	1

; ---------------------------------------------------------------------------
; -- Read from file offset
; --
; -- Inputs:
; --   ft - bytes to read
; --   bc - pointer to file struct
; --   de - destination pointer (data segment)
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
KReadFile		RB	1


; ---------------------------------------------------------------------------
; -- Close directory
; --
; -- Inputs:
; --   ft - directory struct
; --
KCloseDirectory		RB	1

; -- Set the color attribute for printing text
; -- Usage: MSetColor color
MSetColor:	MACRO
		pusha
		ld	b,$F0
		ld	c,(\1)<<4
		sys	KTextSetAttributes
		popa
		ENDM

VATTR_ITALIC	EQU	$08
VATTR_BOLD	EQU	$04
VATTR_UNDERLINE	EQU	$02

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
; -- Usage: MClearAttribute attribute
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
		ld	d,\1.length
		ld	bc,{ DB \1 }
.next\@		lco	t,(bc)
		add	bc,1
		sys	KDebugCharacterOut
		j/ne	.error\@
		dj	d,.next\@
.error\@	popa
		ENDM




	ENDC
