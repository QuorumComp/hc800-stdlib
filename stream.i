	IFND	STREAM_I_INCLUDED_
STREAM_I_INCLUDED_ = 1

	GLOBAL	StreamDataOut
	GLOBAL	StreamDataStringOut
	GLOBAL	StreamBssStringOut
	GLOBAL	StreamDigitOut
	GLOBAL	StreamHexByteOut
	GLOBAL	StreamHexWordOut
	GLOBAL	StreamDecimalWordOut

; -- Print a string
; -- Usage: MPrintString <"My string">
MPrintString:	MACRO
		pusha
		ld	bc,.string\@
		jal	StreamDataStringOut
		j	.end\@
.string\@	DB	.end\@-.string\@-1
		DB	\1
.end\@
		popa
		ENDM

	ENDC