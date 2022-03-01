	IFND	STRING_I_INCLUDED_

STRING_I_INCLUDED_ = 1

STRING_SIZE	EQU	256

DS_STR:		MACRO	;maxLength
		IF	__NARG==0
			DS	STRING_SIZE
		ELSE
			IF	(\1)>255
				FAIL "Strings must be shorter than {STRING_SIZE-1} characters"
			ENDC
			DS	1+(\1)
		ENDC
		ENDM

DC_STR:		MACRO	;string
		IF	\1==""
			DB	0
		ELSE
			DB	.end\@-.start\@
.start\@		DB	\1
.end\@		
		ENDC
		ENDM

; -- Inputs:
; --   bc - pointer to destination
MStringAppend:	MACRO	;string
		pusha
		ld	de,{ DC_STR \1 }
		jal	StringAppendDataString
		popa
		ENDM

MStringClear:	MACRO	;stringDataPtr
		pusha
		ld	bc,\1
		ld	t,0
		ld	(bc),t
		popa
		ENDM

MDigitToAscii:	MACRO
		cmp	t,10
		add	t,'0'
		add/geu	t,'A'-'0'
		ENDM

	GLOBAL	StringClear
	GLOBAL	StringTrimRight
	GLOBAL	StringAppendChar
	GLOBAL	StringAppendChars
	GLOBAL	StringAppendString
	GLOBAL	StringAppendDataString
	GLOBAL	StringCopy
	GLOBAL	StringSplit
	GLOBAL	StringReverseChar
	GLOBAL	DigitToAscii

	GLOBAL	MemoryCharN
	GLOBAL	MemoryReverseCharN
	GLOBAL	MemoryCompareN

	ENDC