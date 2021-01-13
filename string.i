	IFND	STRING_I_INCLUDED_

STRING_I_INCLUDED_ = 1

STRING_SIZE	EQU	256

DS_STR:		MACRO	;maxLength
		DS	1+(\1)
		ENDM

DC_STR:		MACRO	;string
		DB	.end\@-.start\@
.start\@	DB	\1
.end\@		
		ENDM

; -- Inputs:
; --   bc - pointer to destination
STR_APPEND:	MACRO	;string
		pusha
		ld	de,.string\@
		jal	StringAppendDataString
		j	.end\@
.string\@	DC_STR	\1
.end\@		popa
		ENDM


	GLOBAL	StringClear
	GLOBAL	StringTrimRight
	GLOBAL	StringAppendChar
	GLOBAL	StringAppendDataString
	GLOBAL	StringCopy
	GLOBAL	DigitToAscii

	ENDC