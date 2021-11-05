	IFND	STREAM_I_INCLUDED_
STREAM_I_INCLUDED_ = 1

	GLOBAL	StreamDataOut
	GLOBAL	StreamDataStringOut
	GLOBAL	StreamBssStringOut
	GLOBAL	StreamDigitOut
	GLOBAL	StreamHexByteOut
	GLOBAL	StreamHexWordOut
	GLOBAL	StreamHexLongOut
	GLOBAL	StreamDecimalWordOut
	GLOBAL	StreamMemoryDump

; -- Print a string
; -- Usage: MPrintString <"My string">
MPrintString:	MACRO
		pusha
		ld	bc,string\@__
		jal	StreamDataStringOut
		popa

		PUSHS
		SECTION "Strings\@",CODE
string\@__	DB	end\@__-string\@__-1
		DB	\1
end\@__
		POPS
		ENDM

MPrintChar:	MACRO
		pusha
		ld	t,\1
		sys	KCharacterOut
		popa
		ENDM

	ENDC