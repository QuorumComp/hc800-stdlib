	IFND	STRING_I_INCLUDED_

STRING_I_INCLUDED_ = 1

STRING_SIZE	EQU	256

DS_STR:		MACRO	;maxLength
		IF	__NARG==0
			DS	256
		ELSE
			IF	(\1)>255
				FAIL "Strings must be shorter than 255 characters"
			ENDC
			DS	1+(\1)
		ENDC
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

STR_CLEAR:	MACRO	;stringDataPtr
		pusha
		ld	bc,\1
		ld	t,0
		ld	(bc),t
		popa
		ENDM



	GLOBAL	StringClear
	GLOBAL	StringTrimRight
	GLOBAL	StringAppendChar
	GLOBAL	StringAppendDataString
	GLOBAL	StringCopy
	GLOBAL	DigitToAscii

	ENDC